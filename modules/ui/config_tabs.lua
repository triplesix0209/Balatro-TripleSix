-- Keybinds content (3 pages)

Handy.UI.get_keybinds_page = function(page)
	local result = {}
	if page == 1 then
		result = {
			Handy.UI.PARTS.create_module_section("hand_selection"),
			Handy.UI.CD.insta_highlight.keybind(),
			Handy.UI.CD.insta_highlight_entire_f_hand.keybind(),
			Handy.UI.CD.deselect_hand.keybind(),
			Handy.UI.PARTS.create_module_section("hand"),
			Handy.UI.CD.regular_keybinds_play_hand.keybind(),
			Handy.UI.CD.regular_keybinds_discard.keybind(),
			Handy.UI.CD.regular_keybinds_sort_by_rank.keybind(),
			Handy.UI.CD.regular_keybinds_sort_by_suit.keybind(),
			Handy.UI.CD.regular_keybinds_toggle_sort.keybind(),
			Handy.UI.PARTS.create_module_section("menus"),
			Handy.UI.CD.regular_keybinds_run_info_hands.keybind(),
			Handy.UI.CD.regular_keybinds_run_info_blinds.keybind(),
			Handy.UI.CD.regular_keybinds_view_deck.keybind(),
			Handy.UI.CD.show_deck_preview.keybind(),
			Handy.UI.CD.regular_keybinds_lobby_info.keybind(),
		}
	elseif page == 2 then
		result = {
			Handy.UI.PARTS.create_module_section("round"),
			Handy.UI.CD.insta_cash_out.keybind(),
			Handy.UI.PARTS.create_module_section("shop"),
			Handy.UI.CD.insta_booster_skip.keybind(),
			Handy.UI.CD.regular_keybinds_reroll_shop.keybind(),
			Handy.UI.CD.regular_keybinds_leave_shop.keybind(),
			Handy.UI.PARTS.create_module_section("blinds"),
			Handy.UI.CD.regular_keybinds_skip_blind.keybind(),
			Handy.UI.CD.regular_keybinds_select_blind.keybind(),
			Handy.UI.CD.regular_keybinds_reroll_boss.keybind(),
			Handy.UI.PARTS.create_module_section("quick_actions"),
			Handy.UI.CD.insta_buy_or_sell.keybind(),
			Handy.UI.CD.insta_buy_n_sell.keybind(),
			Handy.UI.CD.insta_use.keybind(),
		}
	elseif page == 3 then
		result = {
			Handy.UI.PARTS.create_module_section("gamespeed"),
			Handy.UI.CD.speed_multiplier.keybind(),
			Handy.UI.CD.speed_multiplier_multiply.keybind(),
			Handy.UI.CD.speed_multiplier_divide.keybind(),
			Handy.UI.PARTS.create_module_section("animations"),
			Handy.UI.CD.animation_skip.keybind(),
			Handy.UI.CD.animation_skip_increase.keybind(),
			Handy.UI.CD.animation_skip_decrease.keybind(),
			Handy.UI.CD.scoring_hold.keybind(),
		}
	elseif page == 4 then
		result = {
			Handy.UI.PARTS.create_module_section("highlight_movement"),
			Handy.UI.CD.move_highlight_one_left.keybind(),
			Handy.UI.CD.move_highlight_one_right.keybind(),
			Handy.UI.CD.move_highlight_move_card.keybind(),
			Handy.UI.CD.move_highlight_to_end.keybind(),
			Handy.UI.PARTS.create_module_section("misc"),
			Handy.UI.CD.misc_open_mod_settings.keybind(),
			Handy.UI.CD.misc_save_run.keybind(),
			Handy.UI.CD.misc_quick_restart.keybind(),
			Handy.UI.CD.misc_start_fantoms_preview.keybind(),
			Handy.UI.CD.misc_crash.keybind(),
		}
	elseif page == 5 then
		result = {
			Handy.UI.PARTS.create_module_section("debug"),
			Handy.UI.CD.debug_add_money.keybind(),
			Handy.UI.CD.debug_add_round.keybind(),
			Handy.UI.CD.debug_add_ante.keybind(),
			Handy.UI.CD.debug_add_hand.keybind(),
			Handy.UI.CD.debug_add_discard.keybind(),
			Handy.UI.CD.debug_add_chips.keybind(),
			Handy.UI.CD.debug_add_mult.keybind(),
			Handy.UI.CD.debug_win_game.keybind(),
			Handy.UI.CD.debug_lose_game.keybind(),
			Handy.UI.CD.debug_unlock.keybind(),
			Handy.UI.CD.debug_discover.keybind(),
			Handy.UI.CD.debug_spawn.keybind(),
			Handy.UI.CD.debug_cycle_edition.keybind(),
		}
	end
	if result then
		result = {
			n = G.UIT.ROOT,
			config = {
				colour = adjust_alpha(HEX("000000"), 0.1),
				align = "cm",
				padding = 0.25,
				r = 0.5,
				minh = 8.1,
				maxh = 8.1,
			},
			nodes = {
				{
					n = G.UIT.C,
					config = { padding = 0.05 },
					nodes = result,
				},
			},
		}
	end
	return result, 5
end


-- Tabs definitions

Handy.UI.get_overall_page = function(page)
	local gamepad = Handy.controller.is_gamepad()
	local result = {}
	if page == 1 then
		result = {
			not gamepad and {
				n = G.UIT.R,
				config = { padding = 0.05, align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						nodes = {
							Handy.UI.CD.info_popups_level.option_cycle(),
						},
					},
					{
						n = G.UIT.C,
						nodes = {
							Handy.UI.CD.keybinds_trigger_mode.option_cycle(),
						},
					},
					{
						n = G.UIT.C,
						nodes = {
							Handy.UI.CD.device_select.option_cycle(),
						},
					},
				},
			} or nil,
			Handy.UI.PARTS.create_separator_r(0.05),
			{
				n = G.UIT.R,
				config = {
					align = "cm",
				},
				nodes = {
					{
						n = G.UIT.R,
						config = {
							padding = 0.25,
							r = 0.5,
							colour = adjust_alpha(HEX("000000"), 0.1),
						},
						nodes = {
							Handy.UI.CD.handy.checkbox({ full_width = true }),
						},
					},
				},
			},
			gamepad and Handy.UI.PARTS.create_separator_r(gamepad and 0.125) or nil,
			gamepad and {
				n = G.UIT.R,
				config = { padding = 0, align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						nodes = {
							Handy.UI.CD.info_popups_level.option_cycle({ compress = true }),
						},
					},
					{
						n = G.UIT.R,
						nodes = {
							Handy.UI.CD.keybinds_trigger_mode.option_cycle({ compress = true }),
						},
					},
					{
						n = G.UIT.R,
						nodes = {
							Handy.UI.CD.device_select.option_cycle({ compress = true }),
						},
					},
				},
			} or nil,
			Handy.UI.PARTS.create_separator_r(gamepad and 0.125 or nil),
			{
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.insta_highlight.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.insta_unhighlight.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.regular_keybinds.checkbox(),
						},
					},
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.show_deck_preview.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.hide_options_button.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.debug_always_enabled.checkbox(),
						},
					},
				},
			},
		}
	elseif page == 2 then
		result = {
			{
				n = G.UIT.R,
				config = { padding = 0.05, align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						nodes = {
							Handy.UI.CD.buy_sell_use_mode.option_cycle({ compress = gamepad }),
						},
					},
				},
			},
			Handy.UI.PARTS.create_separator_r(),
			{
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.insta_buy_or_sell.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.insta_buy_n_sell.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.insta_use.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.deselect_hand.checkbox(),
						},
					},
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.insta_highlight_entire_f_hand.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.insta_cash_out.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.insta_booster_skip.checkbox(),
						},
					},
				},
			},
		}
	elseif page == 3 then
		result = {
			not gamepad and {
				n = G.UIT.R,
				config = { padding = 0.05, align = "cm" },
				nodes = {
					{
						n = G.UIT.C,
						nodes = {
							Handy.UI.CD.speed_multiplier_default_value.option_cycle(),
						},
					},
					{
						n = G.UIT.C,
						nodes = {
							Handy.UI.CD.animation_skip_default_value.option_cycle(),
						},
					},
				},
			} or nil,
			gamepad and {
				n = G.UIT.R,
				config = { padding = 0, align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						nodes = {
							Handy.UI.CD.speed_multiplier_default_value.option_cycle({ compress = true }),
						},
					},
					{
						n = G.UIT.R,
						nodes = {
							Handy.UI.CD.animation_skip_default_value.option_cycle({ compress = true }),
						},
					},
				},
			} or nil,
			Handy.UI.PARTS.create_separator_r(),
			{
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.speed_multiplier.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.animation_skip.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.scoring_hold.checkbox(),
						},
					},
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.speed_multiplier_no_hold.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.animation_skip_no_hold.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.scoring_hold_any_moment.checkbox(),
						},
					},
				},
			},
		}
	elseif page == 4 then
		result = {
			Handy.UI.CD.move_highlight.checkbox(),
			Handy.UI.PARTS.create_separator_r(),
			{
				n = G.UIT.R,
				nodes = {
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.speed_multiplier_settings_toggle.checkbox(),
							Handy.UI.PARTS.create_separator_r(),
							Handy.UI.CD.animation_skip_settings_toggle.checkbox(),
						},
					},
					{
						n = G.UIT.C,
						config = { minw = 4 },
						nodes = {
							Handy.UI.CD.controller_swap_cursor_stick.checkbox(),
						},
					},
				},
			},
			Handy.UI.PARTS.create_separator_r(),
			Handy.UI.CD.controller_sensivity.slider(),
		}
	end
	if result then
		result = {
			n = G.UIT.ROOT,
			config = { colour = G.C.CLEAR, align = "cm", padding = 0.05, minh = 6.5, maxh = 6.5, minw = 17.5 },
			nodes = result,
		}
	end
	return result, 4
end

Handy.UI.get_config_tab_overall = function()
	local gamepad = Handy.controller.is_gamepad()
	local page_definition, max_page = Handy.UI.get_overall_page(Handy.UI.overall_page or 1)
	local options = {}
	for i = 1, max_page do
		table.insert(options, localize("k_page") .. " " .. tostring(i) .. "/" .. tostring(max_page))
	end
	return {
		{
			n = G.UIT.R,
			config = {
				align = "cm",
			},
			nodes = {
				{
					n = G.UIT.O,
					config = {
						id = "handy_overall_page_content",
						object = UIBox({
							definition = page_definition,
							config = {
								colour = G.C.CLEAR,
								align = "cm",
							},
						}),
						align = "cm",
					},
				},
			},
		},
		Handy.UI.PARTS.create_separator_r(0.1),
		{
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				create_option_cycle({
					options = options,
					w = 4.5,
					cycle_shoulders = true,
					opt_callback = "handy_change_overall_page",
					current_option = Handy.UI.overall_page or 1,
					colour = G.C.RED,
					no_pips = true,
					focus_args = { nav = "wide" },
					scale = 0.8,
				}),
			},
		},
	}
end
Handy.UI.get_config_tab_keybinds_paginated = function()
	local page_definition, max_page = Handy.UI.get_keybinds_page(Handy.UI.keybinds_page or 1)
	local options = {}
	for i = 1, max_page do
		table.insert(options, localize("k_page") .. " " .. tostring(i) .. "/" .. tostring(max_page))
	end
	return {
		{
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				{
					n = G.UIT.O,
					config = {
						id = "handy_keybinds_page_content",
						object = UIBox({
							definition = page_definition,
							config = { colour = G.C.CLEAR, align = "cm" },
						}),
						align = "cm",
					},
				},
			},
		},
		Handy.UI.PARTS.create_separator_r(0.05),
		{
			n = G.UIT.R,
			config = { align = "cm" },
			nodes = {
				create_option_cycle({
					options = options,
					w = 4.5,
					cycle_shoulders = true,
					opt_callback = "handy_change_keybinds_page",
					current_option = Handy.UI.keybinds_page or 1,
					colour = G.C.RED,
					no_pips = true,
					focus_args = { nav = "wide" },
					scale = 0.8,
				}),
			},
		},
	}
end

-- Tabs order

Handy.UI.PARTS.tabs_list = {
	["Overall"] = {
		definition = function()
			return Handy.UI.get_config_tab_overall()
		end,
	},
	["Keybinds Paginated"] = {
		definition = function()
			return Handy.UI.get_config_tab_keybinds_paginated()
		end,
	},
	["Fusions"] = {
		definition = function()
			if get_config_tab_fusions then
				return get_config_tab_fusions()
			else
				return {}
			end
		end,
	},
	["Thanks"] = {
		definition = function()
			if get_config_tab_thanks then
				return get_config_tab_thanks()
			else
				return {}
			end
		end,
	},
}
Handy.UI.PARTS.tabs_order = {
	"Overall",
	"Fusions",
	"Keybinds Paginated",
	"Thanks",
}

-- Getters

function Handy.UI.get_config_tab(_tab, _index)
	local result = {
		n = G.UIT.ROOT,
		config = { align = "cm", padding = 0.05, colour = G.C.CLEAR, minh = 5, minw = 5 },
		nodes = {},
	}
	Handy.UI.config_tab_index = _index
	result.nodes = Handy.UI.PARTS.tabs_list[_tab].definition()
	return result
end
function Handy.UI.get_options_tabs()
	local result = {}
	for index, k in ipairs(Handy.UI.PARTS.tabs_order) do
		table.insert(result, {
			label = localize(k, "handy_tabs"),
			tab_definition_function = function()
				return Handy.UI.get_config_tab(k, index)
			end,
		})
	end
	return result
end
