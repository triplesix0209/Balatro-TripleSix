# PowerShell Build Script for Balatro Android APK with Mods
# Designed to be run from Visual Studio Code tasks.

$ErrorActionPreference = "Stop"

# Configuration
$BalatroExe = "E:\Program Files\Steam\steamapps\common\Balatro\Balatro.exe"
if (!(Test-Path $BalatroExe)) {
    $BalatroExe = "C:\Program Files (x86)\Steam\steamapps\common\Balatro\Balatro.exe"
}

# Directories
$CacheDir = Join-Path $PSScriptRoot ".build_cache"
$TmpApkDir = Join-Path $PSScriptRoot ".tmp_apk"
$TmpGameDir = Join-Path $PSScriptRoot ".tmp_game"

$ApktoolJar = Join-Path $CacheDir "apktool.jar"
$UberSignerJar = Join-Path $CacheDir "uber-apk-signer.jar"
$BaseApk = Join-Path $CacheDir "base.apk"
$UnsignedApk = Join-Path $PSScriptRoot "balatro-unsigned.apk"
$FinalApk = Join-Path $PSScriptRoot "balatro.apk"

# Ensure clean temp folders
function Clean-TempDirectories {
    if (Test-Path $TmpApkDir) {
        Write-Host "Cleaning up old temp APK directory..."
        Remove-Item -Recurse -Force $TmpApkDir
    }
    if (Test-Path $TmpGameDir) {
        Write-Host "Cleaning up old temp game directory..."
        Remove-Item -Recurse -Force $TmpGameDir
    }
    if (Test-Path $UnsignedApk) {
        Remove-Item -Force $UnsignedApk
    }
}

# Recursively copy directories excluding dev folders
function Copy-FilteredDirectory($src, $dest) {
    if ($src -is [System.Management.Automation.PathInfo]) {
        $src = $src.Path
    }
    $src = $src.ToString().TrimEnd('\')
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
    Get-ChildInstanceRecursively $src | ForEach-Object {
        $relPath = $_.FullName.Substring($src.Length + 1)
        if ($relPath -like "*.git*" -or $relPath -like "*.vscode*" -or $relPath -like "*.build_cache*" -or $relPath -like "*.tmp_apk*" -or $relPath -like "*.tmp_game*" -or $relPath -like "*build_android.ps1*" -or $relPath -like "*balatro-unsigned.apk*" -or $relPath -like "*balatro.apk*") {
            return
        }
        $destPath = Join-Path $dest $relPath
        if ($_.PSIsContainer) {
            New-Item -ItemType Directory -Force -Path $destPath | Out-Null
        } else {
            # Make sure parent directory exists
            $parentDir = Split-Path $destPath
            if (!(Test-Path $parentDir)) {
                New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
            }
            Copy-Item -Path $_.FullName -Destination $destPath -Force
        }
    }
}

function Get-ChildInstanceRecursively($path) {
    return Get-ChildItem -Path $path -Recurse
}

# Main build logic
try {
    Clean-TempDirectories

    # 1. Check prerequisites
    Write-Host "=== Step 1: Checking Prerequisites ==="
    if (!(Get-Command java -ErrorAction SilentlyContinue)) {
        Write-Error "Java (JDK) is not installed or not in PATH! Please install Java 17+ to run the APK build tools."
        exit 1
    }
    if (!(Test-Path $BalatroExe)) {
        Write-Error "Balatro.exe not found at $BalatroExe! Please open this script and edit the `$BalatroExe` path."
        exit 1
    }
    Write-Host "Prerequisites check passed. Java and Balatro.exe located."

    # 2. Download tools to cache
    Write-Host "`n=== Step 2: Downloading Build Tools ==="
    New-Item -ItemType Directory -Force -Path $CacheDir | Out-Null
    
    if (!(Test-Path $ApktoolJar)) {
        Write-Host "Downloading apktool v2.9.3..."
        Invoke-WebRequest -Uri "https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar" -OutFile $ApktoolJar
    } else {
        Write-Host "apktool.jar already cached."
    }

    if (!(Test-Path $UberSignerJar)) {
        Write-Host "Downloading uber-apk-signer v1.3.0..."
        Invoke-WebRequest -Uri "https://github.com/patrickfav/uber-apk-signer/releases/download/v1.3.0/uber-apk-signer-1.3.0.jar" -OutFile $UberSignerJar
    } else {
        Write-Host "uber-apk-signer.jar already cached."
    }

    $ExpectedSize = 12900000
    if (Test-Path $BaseApk) {
        $ActualSize = (Get-Item $BaseApk).Length
        if ($ActualSize -lt $ExpectedSize) {
            Write-Host "Cached base.apk is incomplete ($ActualSize bytes). Deleting cache to redownload..."
            Remove-Item $BaseApk
        }
    }

    if (!(Test-Path $BaseApk)) {
        Write-Host "Downloading Lovely base APK (LÖVE 11.5)..."
        # Download from WilsontheWolf's lovely-mobile-maker hosted assets
        # Silence progress bar to prevent PowerShell slow-down
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri "https://lmm.shorty.systems/base.apk" -OutFile $BaseApk
    } else {
        Write-Host "base.apk already cached."
    }

    # 3. Decompile base APK
    Write-Host "`n=== Step 3: Decoding Base APK ==="
    Write-Host "Decoding APK structure (no sources) using apktool..."
    java -jar $ApktoolJar d -s -f -o $TmpApkDir $BaseApk

    # 4. Extract Game Files from Balatro.exe
    Write-Host "`n=== Step 4: Extracting Game Files from Balatro.exe ==="
    New-Item -ItemType Directory -Force -Path $TmpGameDir | Out-Null
    tar -xf $BalatroExe -C $TmpGameDir
    Write-Host "Vanilla files successfully extracted."

    # 5. Inject Prepackaged Mods Auto-Copy routine into conf.lua
    Write-Host "`n=== Step 5: Injecting Mod Bootstrap in conf.lua ==="
    $ConfPath = Join-Path $TmpGameDir "conf.lua"
    if (!(Test-Path $ConfPath)) {
        Write-Error "conf.lua not found in extracted game files!"
        exit 1
    }

    $LuaInjectBlock = @"
-- Prepackaged Mods copy script injected by Antigravity
local function setup_prepackaged_mods()
    local function copy_dir(src, dest)
        love.filesystem.createDirectory(dest)
        for _, item in ipairs(love.filesystem.getDirectoryItems(src)) do
            local src_path = src .. "/" .. item
            local dest_path = dest .. "/" .. item
            local info = love.filesystem.getInfo(src_path)
            if info then
                if info.type == "directory" then
                    copy_dir(src_path, dest_path)
                elseif info.type == "file" then
                    local data, size = love.filesystem.read(src_path)
                    if data then
                        love.filesystem.write(dest_path, data)
                    end
                end
            end
        end
    end
    if love.filesystem.getInfo("PrepackagedMods") then
        local needs_restart = not love.filesystem.getInfo("Mods")
        copy_dir("PrepackagedMods", "Mods")
        if needs_restart then
            require("love.event").quit("restart")
        end
    end
end
setup_prepackaged_mods()


"@

    $ConfContent = Get-Content -Path $ConfPath -Raw
    $NewConfContent = $LuaInjectBlock + $ConfContent
    Set-Content -Path $ConfPath -Value $NewConfContent -NoNewline
    Write-Host "Bootstrap successfully injected into conf.lua."

    # 6. Copy files to APK assets directory
    Write-Host "`n=== Step 6: Bundling Game Files and Mods into APK assets ==="
    $ApkAssetsDir = Join-Path $TmpApkDir "assets"
    
    # Copy vanilla game files
    Write-Host "Copying Balatro game assets..."
    Copy-FilteredDirectory $TmpGameDir $ApkAssetsDir

    # Copy smods and Balatro-TripleSix into PrepackagedMods
    $PrepackagedModsDir = Join-Path $ApkAssetsDir "PrepackagedMods"
    $SmodsSource = Resolve-Path (Join-Path $PSScriptRoot "..\smods")
    $TripleSixSource = $PSScriptRoot

    Write-Host "Bundling Steamodded (smods)..."
    Copy-FilteredDirectory $SmodsSource (Join-Path $PrepackagedModsDir "smods")
    
    Write-Host "Bundling Balatro-TripleSix..."
    Copy-FilteredDirectory $TripleSixSource (Join-Path $PrepackagedModsDir "Balatro-TripleSix")

    # 7. Modify AndroidManifest.xml for custom label and package id
    Write-Host "`n=== Step 7: Configuring Android Manifest ==="
    $ManifestPath = Join-Path $TmpApkDir "AndroidManifest.xml"
    if (Test-Path $ManifestPath) {
        $ManifestContent = Get-Content -Path $ManifestPath -Raw
        $ManifestContent = $ManifestContent -replace 'package="systems.shorty.lmm"', 'package="com.unofficial.balatro"'
        $ManifestContent = $ManifestContent -replace 'android:label="Lovely Mobile Maker"', 'android:label="Balatro"'
        $ManifestContent = $ManifestContent -replace 'android:name="org.love2d.android.GameActivity"\s+android:label="[^"]+"', 'android:name="org.love2d.android.GameActivity" android:label="Balatro"'
        Set-Content -Path $ManifestPath -Value $ManifestContent -NoNewline
        Write-Host "Package ID set to: com.unofficial.balatro"
        Write-Host "App Label set to: Balatro"
    }

    # 8. Rebuild APK using apktool
    Write-Host "`n=== Step 8: Rebuilding APK ==="
    java -jar $ApktoolJar b -o $UnsignedApk $TmpApkDir
    Write-Host "Unsigned APK built."

    # 9. Sign APK using uber-apk-signer
    Write-Host "`n=== Step 9: Signing and Aligning APK ==="
    java -jar $UberSignerJar --apks $UnsignedApk --out $PSScriptRoot
    
    # Locate signed APK
    $SignedApkPath = Get-ChildItem -Path $PSScriptRoot -Filter "*aligned-debugSigned.apk" | Select-Object -First 1
    if ($SignedApkPath) {
        if (Test-Path $FinalApk) { Remove-Item $FinalApk }
        Move-Item -Path $SignedApkPath.FullName -Destination $FinalApk -Force
        Write-Host "`n========================================="
        Write-Host "SUCCESS! Modded APK built at: $FinalApk"
        Write-Host "========================================="
    } else {
        Write-Error "Could not find signed APK file!"
    }

} catch {
    Write-Host "`nERROR occurred during build pipeline:"
    Write-Host $_.Exception.Message
    exit 1
} finally {
    Clean-TempDirectories
}
