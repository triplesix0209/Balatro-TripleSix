to_big = to_big or function(x)
	return x
end
to_number = to_number or function(x)
	return x
end
is_big = is_big or function(x)
	return false
end

if not Handy then
	Handy = setmetatable({
		version = "1.5.1p",

		last_clicked_area = nil,
		last_clicked_card = nil,

		last_hovered_area = nil,
		last_hovered_card = nil,

		modules = {},

		meta = {
			["1.4.1b_patched_select_blind_and_skip"] = true,
			["1.5.0_update"] = true,
			["1.5.1a_multiplayer_check"] = true,
		},
	}, {})

	function Handy.is_stop_use()
		return G.CONTROLLER.locked or G.CONTROLLER.locks.frame or (G.GAME and (G.GAME.STOP_USE or 0) > 0)
	end

	function Handy.is_in_multiplayer()
		return not not (MP and MP.LOBBY and MP.LOBBY.code)
	end

	function Handy.register_module(key, mod_module)
		Handy.modules[key] = mod_module
	end

	--

	require("handy/utils")
	require("handy/config")
	require("handy/fake_events")
	require("handy/controller")
	require("handy/ui")

	require("handy/controls/insta_cash_out")
	require("handy/controls/insta_booster_skip")
	require("handy/controls/deselect_hand")
	require("handy/controls/show_deck_preview")
	require("handy/controls/regular_keybinds")
	require("handy/controls/insta_highlight")
	require("handy/controls/insta_highlight_entire_f_hand")
	require("handy/controls/insta_actions")
	require("handy/controls/move_highlight")
	require("handy/controls/speed_multiplier")
	require("handy/controls/animation_skip")
	require("handy/controls/scoring_hold")

	require("handy/controls/misc")
	require("handy/controls/debug_actions")

	--

	local init_localization_ref = init_localization
	function init_localization(...)
		local res = init_localization_ref(...)
		if not G.localization.__handy_injected then
			Handy.UI.cache_config_dictionary_search()
			G.localization.__handy_injected = true
		end
		return res
	end

	local card_area_emplace_ref = CardArea.emplace
	function CardArea:emplace(...)
		self.cards = self.cards or {}
		return card_area_emplace_ref(self, ...)
	end

	local card_area_align_cards_ref = CardArea.align_cards
	function CardArea:align_cards(...)
		self.children = self.children or {}
		return card_area_align_cards_ref(self, ...)
	end

	local game_start_up_ref = Game.start_up
	function Game:start_up(...)
		local result = game_start_up_ref(self, ...)
		G.CONTROLLER.saved_axis_cursor_speed = G.CONTROLLER.axis_cursor_speed
		G.CONTROLLER.axis_cursor_speed = G.CONTROLLER.saved_axis_cursor_speed * Handy.cc.controller_sensivity.mult
		G.E_MANAGER:add_event(Event({
			no_delete = true,
			blocking = false,
			func = function()
				G.E_MANAGER:add_event(Event({
					no_delete = true,
					blocking = false,
					func = function()
						Handy.speed_multiplier.load_default_value()
						Handy.animation_skip.load_default_value()
						return true
					end,
				}))
				return true
			end,
		}))
		return result
	end

	--

	function Handy.emplace_steamodded()
		if Handy.current_mod then
			return
		end
		Handy.current_mod = (Handy_Preload and Handy_Preload.current_mod) or SMODS.current_mod
		if Handy.current_mod.config then
			Handy.config.current = Handy.utils.table_merge(Handy.config.current, Handy.current_mod.config)
		end
		Handy.current_mod.config = Handy.config.current
		Handy.cc = Handy.config.current
		Handy.UI.show_options_button = not Handy.cc.hide_options_button.enabled

		-- Config tabs
		Handy.current_mod.config_tab = function()
			return Handy.UI.get_options_tabs()[1].tab_definition_function
		end
		Handy.current_mod.extra_tabs = function()
			local result = Handy.UI.get_options_tabs()
			table.remove(result, 1)
			return result
		end

		-- NotJustYet
		G.E_MANAGER:add_event(Event({
			blocking = false,
			func = function()
				G.njy_keybind = nil
				if MP and G.FUNCS.lobby_info then
					local lobby_info_ref = G.FUNCS.lobby_info
					function G.FUNCS.lobby_info(...)
						Handy.regular_keybinds.toggle_swappable_overlay(true)
						return lobby_info_ref(...)
					end
				end
				return true
			end,
		}))

		-- Animation skip setup
		local smods_calculate_effect_ref = SMODS.calculate_effect or function() end
		function SMODS.calculate_effect(effect, ...)
			if Handy.animation_skip.should_skip_animation() then
				effect.juice_card = nil
			end
			return smods_calculate_effect_ref(effect, ...)
		end
		if Talisman then
			local nuGC_ref = nuGC
			function nuGC(time_budget, ...)
				if G.STATE == G.STATES.HAND_PLAYED then
					time_budget = 0.0333
				end
				return nuGC_ref(time_budget, ...)
			end
		end

		-- Load Talisman Sounds
		if SMODS.Sound then
			SMODS.Sound({
				key = "xchip",
				path = "MultiplicativeChips.wav"
			})
			SMODS.Sound({
				key = "echip",
				path = "ExponentialChips.wav"
			})
			SMODS.Sound({
				key = "eechip",
				path = "TetrationalChips.wav"
			})
			SMODS.Sound({
				key = "eeechip",
				path = "PentationalChips.wav"
			})
			SMODS.Sound({
				key = "emult",
				path = "ExponentialMult.wav"
			})
			SMODS.Sound({
				key = "eemult",
				path = "TetrationalMult.wav"
			})
			SMODS.Sound({
				key = "eeemult",
				path = "PentationalMult.wav"
			})
		end

		-- Load Talisman Scoring Calculation
		if SMODS and SMODS.Scoring_Calculation then
			local ref = SMODS.set_scoring_calculation
			function SMODS.set_scoring_calculation(key, ...)
				G.GAME.current_scoring_calculation_key = key
				if key == "talisman_hyper" then
					G.GAME.hyper_operator = G.GAME.hyper_operator or 2
				end
				return ref(key, ...)
			end

			SMODS.Scoring_Calculation:take_ownership("add", {order = -1}, true)
			SMODS.Scoring_Calculation:take_ownership("multiply", {order = 0}, true)
			SMODS.Scoring_Calculation:take_ownership("exponent", {order = 1}, true)
			function change_operator(amount)
				local order = SMODS.Scoring_Calculations[G.GAME.current_scoring_calculation_key or "multiply"].order + amount
				if not order then return end
				if G.GAME.current_scoring_calculation_key == "talisman_hyper" then
					G.GAME.hyper_operator = (G.GAME.hyper_operator or 2) + amount
					order = G.GAME.hyper_operator
				end
				local next = "add"
				local keys = {}
				for i, v in pairs(SMODS.Scoring_Calculations) do
					if v.order then
						keys[#keys+1] = i
					end
				end
				table.sort(keys, function(a, b) return SMODS.Scoring_Calculations[a].order < SMODS.Scoring_Calculations[b].order end)
				for i, v in pairs(keys) do
					if SMODS.Scoring_Calculations[v].order <= order then
						next = v
					end
				end
				if next then
					SMODS.set_scoring_calculation(next)
				end
			end

			SMODS.Scoring_Calculation {
				key = "hyper",
				func = function(self, chips, mult, flames) return to_big(chips):arrow(G.GAME.hyper_operator or 2, mult) end,
				text = function()
					if G.GAME.hyper_operator < 6 then
						local str = ""
						for i = 1, G.GAME.hyper_operator do str = str.."^" end
						return str
					else
						return "{"..G.GAME.hyper_operator.."}"
					end
				end,
				order = 2
			}
		end

		if Handy_Preload then
			Handy_Preload = nil
		end
	end

	if Handy_Preload then
		Handy.emplace_steamodded()
	end
end
