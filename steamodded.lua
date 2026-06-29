if SMODS and SMODS.current_mod then


	if Handy then
		if not Handy.current_mod then
			Handy.emplace_steamodded()
		end
	else
		Handy_Preload = {
			current_mod = SMODS.current_mod,
		}
	end

	SMODS.Atlas({
		key = "modicon",
		path = "icon.png",
		px = 32,
		py = 32,
	})
end
