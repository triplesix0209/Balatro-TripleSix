# Balatro Mobile Modded APK Builder for Android phone
# Requires Java 17+ on PATH and a legal installation of Balatro on Steam.

$ErrorActionPreference = "Stop"

# Helper function to download files safely (re-downloads if file is 0 bytes)
function Download-File($Url, $TargetPath) {
    if (Test-Path $TargetPath) {
        $file = Get-Item $TargetPath
        if ($file.Length -eq 0) {
            Remove-Item $TargetPath -Force
        }
    }
    if (-not (Test-Path $TargetPath)) {
        Write-Host "Downloading $Url..."
        Invoke-WebRequest -Uri $Url -OutFile $TargetPath
    }
}

# 1. Verification of Java
$javaCheck = Get-Command java -ErrorAction SilentlyContinue
if (-not $javaCheck) {
    Write-Error "Java is required but was not found on your system PATH. Please install OpenJDK/Java and restart."
    exit 1
}

# 2. Define Paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$BuildDir = Join-Path $ScriptDir "build"
if (-not (Test-Path $BuildDir)) {
    New-Item -ItemType Directory -Path $BuildDir | Out-Null
}

$ApkSignerJar = Join-Path $BuildDir "uber-apk-signer.jar"
$ApktoolJar = Join-Path $BuildDir "apktool.jar"
$BaseApkPath = Join-Path $BuildDir "love-11.5-android-embed.apk"

# 3. Download Dependencies
Write-Host "Checking build dependencies..."
Download-File "https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar" $ApkSignerJar
Download-File "https://github.com/iBotPeaches/Apktool/releases/download/v2.10.0/apktool_2.10.0.jar" $ApktoolJar
Download-File "https://github.com/love2d/love-android/releases/download/11.5/love-11.5-android-embed.apk" $BaseApkPath

# 4. Search for Balatro.exe
$exePaths = @(
    "E:\Program Files\Steam\steamapps\common\Balatro\Balatro.exe",
    "C:\Program Files (x86)\Steam\steamapps\common\Balatro\Balatro.exe",
    "C:\Program Files\Steam\steamapps\common\Balatro\Balatro.exe"
)

# Registry Steam fallback
$steamPath = (Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -ErrorAction SilentlyContinue).SteamPath
if ($steamPath) {
    $steamExe = Join-Path $steamPath "steamapps\common\Balatro\Balatro.exe"
    if ($exePaths -notcontains $steamExe) {
        $exePaths += $steamExe
    }
}

$BalatroExe = $null
foreach ($path in $exePaths) {
    if (Test-Path $path) {
        $BalatroExe = $path
        break
    }
}

if (-not $BalatroExe) {
    Write-Error "Balatro.exe could not be found. Ensure Balatro is installed via Steam."
    exit 1
}
Write-Host "Using Balatro executable: $BalatroExe"

# 5. Extract game.love from EXE
Write-Host "Extracting game.love from Balatro.exe..."
$bytes = [System.IO.File]::ReadAllBytes($BalatroExe)
$sig = [byte[]](0x50, 0x4B, 0x03, 0x04)
$offset = -1
for ($i = 0; $i -lt $bytes.Length - 3; $i++) {
    if ($bytes[$i] -eq $sig[0] -and $bytes[$i+1] -eq $sig[1] -and $bytes[$i+2] -eq $sig[2] -and $bytes[$i+3] -eq $sig[3]) {
        $offset = $i
        break
    }
}

if ($offset -lt 0) {
    Write-Error "Failed to extract game.love: ZIP signature not found."
    exit 1
}

$zipBytes = New-Object byte[] ($bytes.Length - $offset)
[Array]::Copy($bytes, $offset, $zipBytes, 0, $zipBytes.Length)
$ExtractedLovePath = Join-Path $BuildDir "extracted_game.love"
[System.IO.File]::WriteAllBytes($ExtractedLovePath, $zipBytes)
Write-Host "Extracted game.love successfully (Offset: $offset)."

# 6. Unzip extracted_game.love
$TempExtractDir = Join-Path $BuildDir "game_src"
if (Test-Path $TempExtractDir) {
    Remove-Item -Recurse -Force $TempExtractDir
}
New-Item -ItemType Directory -Path $TempExtractDir | Out-Null

Add-Type -AssemblyName System.IO.Compression.FileSystem
Write-Host "Decompressing game assets..."
[System.IO.Compression.ZipFile]::ExtractToDirectory($ExtractedLovePath, $TempExtractDir)

# 7. Apply Lovely patched dump files
$DumpDir = "$env:appdata\Balatro\Mods\lovely\dump"
if (-not (Test-Path $DumpDir)) {
    Write-Error "Lovely dump folder not found at $DumpDir. Run Balatro on PC with Lovely/Steamodded enabled first to dump files."
    exit 1
}
Write-Host "Injecting Lovely patches from PC dump directory..."
Copy-Item -Path "$DumpDir\*" -Destination $TempExtractDir -Recurse -Force

# 8. Embed Steamodded (SMODS)
$SmodsSource = "$env:appdata\Balatro\Mods\smods"
if (-not (Test-Path $SmodsSource)) {
    Write-Error "Steamodded not found in $SmodsSource. Install Steamodded on PC first."
    exit 1
}

$SmodsDest = Join-Path $TempExtractDir "SMODS"
if (Test-Path $SmodsDest) {
    Remove-Item -Recurse -Force $SmodsDest
}
New-Item -ItemType Directory -Path $SmodsDest | Out-Null

Write-Host "Embedding Steamodded framework into package..."
Copy-Item -Path "$SmodsSource\*" -Destination $SmodsDest -Recurse -Force

# 9. Patch Steamodded to load embedded VFS mods
Write-Host "Configuring Steamodded VFS redirects..."
$coreLuaPath = Join-Path $SmodsDest "src\preflight\core.lua"
if (Test-Path $coreLuaPath) {
    $coreLuaText = [System.IO.File]::ReadAllText($coreLuaPath)
    
    $targetLine = 'SMODS.MODS_DIR = lovely_mod_dir:gsub("\\", "/")'
    $replaceLine = "SMODS.MODS_DIR = `"Mods`"`r`nNFS.smodsAddRedirect(`"Mods`", `"Mods`")`r`nNFS.smodsAddRedirect(`"SMODS`", `"SMODS`")"
    
    $targetPathLine = "local lovely_path = false -- This line is patched, don't edit it"
    $replacePathLine = 'local lovely_path = "SMODS/"'
    
    if ($coreLuaText.Contains($targetLine)) {
        $coreLuaText = $coreLuaText.Replace($targetLine, $replaceLine)
    }
    if ($coreLuaText.Contains($targetPathLine)) {
        $coreLuaText = $coreLuaText.Replace($targetPathLine, $replacePathLine)
    }
    [System.IO.File]::WriteAllText($coreLuaPath, $coreLuaText)
    Write-Host "Patched core.lua to map virtual Mods/SMODS folders and path."
}

# 10. Embed user's TripleSix mod
$ModsDest = Join-Path $TempExtractDir "Mods\Balatro-TripleSix"
if (Test-Path $ModsDest) {
    Remove-Item -Recurse -Force $ModsDest
}
New-Item -ItemType Directory -Path $ModsDest | Out-Null

Write-Host "Embedding TripleSix mod..."
Get-ChildItem -Path $ScriptDir | Where-Object { $_.Name -ne "build" -and $_.Name -ne ".git" -and $_.Name -ne ".vscode" -and $_.Extension -ne ".apk" } | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $ModsDest -Recurse -Force
}

# 10.5. Patch main.lua to bootstrap SMODS and preloads on Android
Write-Host "Injecting SMODS/Lovely preloads bootstrap into main.lua..."
$mainLuaPath = Join-Path $TempExtractDir "main.lua"
if (Test-Path $mainLuaPath) {
    $bootstrapBlock = @"
-- Android SMODS & Lovely Bootstrap
package.preload["json"] = function() return require("SMODS.libs.json.json") end
package.preload["nativefs"] = function() return require("SMODS.libs.nativefs.nativefs") end
package.preload["SMODS.nativefs"] = function() return require("SMODS.libs.nativefs.nativefs") end
package.preload["SMODS.https"] = function() return require("SMODS.libs.https.smods-https") end
package.preload["lovely"] = function()
    return {
        mod_dir = "Mods",
        reload_patches = function() return true end,
        version = "0.9.0"
    }
end
package.preload["SMODS.preflight.sharedUtil"] = function() return require("SMODS.src.preflight.sharedUtil") end
package.preload["SMODS.preflight.logging"] = function() return require("SMODS.src.preflight.logging") end
package.preload["SMODS.preflight.loader"] = function() return require("SMODS.src.preflight.loader") end
package.preload["SMODS.preflight.sharedUI"] = function() return require("SMODS.src.preflight.sharedUI") end
package.preload["SMODS.preflight.core"] = function() return require("SMODS.src.preflight.core") end
package.preload["SMODS.version"] = function() return require("SMODS.version") end
package.preload["SMODS.release"] = function() return require("SMODS.release") end

-- Run core bootstrap
require("SMODS.preflight.core")


"@
    $originalText = [System.IO.File]::ReadAllText($mainLuaPath)
    [System.IO.File]::WriteAllText($mainLuaPath, $bootstrapBlock + $originalText)
    Write-Host "Successfully injected preloads into main.lua."
}

# 11. Skipped zip packaging (will copy raw files directly in step 15)

# 12. Decompile base APK using Apktool to customize app name & icon
$decompiledDir = Join-Path $BuildDir "decompiled"
if (Test-Path $decompiledDir) {
    Remove-Item -Recurse -Force $decompiledDir
}
Write-Host "Decompiling base APK for customization..."
java -jar "$ApktoolJar" d "$BaseApkPath" -o "$decompiledDir"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Apktool failed to decompile the APK."
    exit 1
}

# 13. Replace Icons in Decompiled Resources
$iconSource = Join-Path $SmodsSource "icon.png"
if (Test-Path $iconSource) {
    Write-Host "Customizing application icons..."
    $drawableDirs = Get-ChildItem -Path (Join-Path $decompiledDir "res") -Filter "drawable-*"
    foreach ($dir in $drawableDirs) {
        $lovePng = Join-Path $dir.FullName "love.png"
        if (Test-Path $lovePng) {
            Copy-Item -Path $iconSource -Destination $lovePng -Force
        }
    }
}

# 14. Patch AndroidManifest.xml for custom app name, package ID, permissions and authorities
Write-Host "Patching Android Manifest..."
$manifestPath = Join-Path $decompiledDir "AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifestText = [System.IO.File]::ReadAllText($manifestPath)
    
    # Update application properties using regex to bypass any encoding issue with Ö character
    $manifestText = $manifestText -replace 'package="org\.love2d\.android"', 'package="com.triplesix.balatro"'
    $manifestText = $manifestText -replace 'org\.love2d\.android\.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION', 'com.triplesix.balatro.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION'
    $manifestText = $manifestText -replace 'org\.love2d\.android\.androidx-startup', 'com.triplesix.balatro.androidx-startup'
    $manifestText = $manifestText -replace 'android:label="L.VE for Android"', 'android:label="Balatro"'
    
    [System.IO.File]::WriteAllText($manifestPath, $manifestText)
}

# 15. Embed game files directly and clean up default files in assets
Write-Host "Injecting unpacked game files into assets..."
$assetsDir = Join-Path $decompiledDir "assets"

# Remove default assets
Get-ChildItem -Path $assetsDir | Where-Object { $_.Name -ne "dexopt" } | ForEach-Object {
    Remove-Item -Path $_.FullName -Recurse -Force
}

# Copy all game files unpacked
Copy-Item -Path "$TempExtractDir\*" -Destination $assetsDir -Recurse -Force


# 16. Compile customized APK using Apktool
Write-Host "Compiling customized APK..."
$UnsignedApk = Join-Path $BuildDir "balatro-unsigned.apk"
java -jar "$ApktoolJar" b "$decompiledDir" -o "$UnsignedApk"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Apktool failed to compile the customized APK."
    exit 1
}

# 17. Sign the compiled APK using uber-apk-signer
Write-Host "Aligning and signing APK..."
java -jar "$ApkSignerJar" --apks "$UnsignedApk" --out "$BuildDir"
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to sign APK."
    exit 1
}

# 18. Relocate signed APK
$SignedApkSource = Get-ChildItem -Path $BuildDir -Filter "*debugSigned.apk" | Select-Object -First 1 -ExpandProperty FullName
if (-not $SignedApkSource) {
    $SignedApkSource = Get-ChildItem -Path $BuildDir -Filter "*aligned-*.apk" | Select-Object -First 1 -ExpandProperty FullName
}

if (-not $SignedApkSource) {
    Write-Error "Signed APK file was not created by the signer tool."
    exit 1
}

$FinalApkDest = Join-Path $ScriptDir "Balatro.apk"
if (Test-Path $FinalApkDest) {
    Remove-Item -Force $FinalApkDest
}
Move-Item -Path $SignedApkSource -Destination $FinalApkDest
Write-Host "Successfully generated APK: Balatro.apk"

# 19. Cleanup
Write-Host "Cleaning up temporary build assets..."
Remove-Item -Recurse -Force $TempExtractDir
Remove-Item -Recurse -Force $decompiledDir
Remove-Item -Force $ExtractedLovePath
Remove-Item -Force $UnsignedApk

Write-Host "Build complete! You can now transfer Balatro.apk to your Android phone."
