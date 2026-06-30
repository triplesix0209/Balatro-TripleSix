-- Debug Actions module
-- Triggers Balatro's built-in debug tool functions via keybindings.
-- Works independently of the debug panel being open.

-- Inline implementations matching Balatro's DT_* functions
local function dt_add_money()   if G.STAGE == G.STAGES.RUN then ease_dollars(10) end end
local function dt_add_round()   if G.STAGE == G.STAGES.RUN then ease_round(1) end end
local function dt_add_ante()    if G.STAGE == G.STAGES.RUN then ease_ante(1) end end
local function dt_add_hand()    if G.STAGE == G.STAGES.RUN then ease_hands_played(1) end end
local function dt_add_discard() if G.STAGE == G.STAGES.RUN then ease_discard(1) end end
local function dt_add_chips()   if G.STAGE == G.STAGES.RUN then update_hand_text({delay = 0}, {chips = 10 + G.GAME.current_round.current_hand.chips}); play_sound('chips1') end end
local function dt_add_mult()    if G.STAGE == G.STAGES.RUN then update_hand_text({delay = 0}, {mult = 10 + G.GAME.current_round.current_hand.mult}); play_sound('multhit1') end end
local function dt_win_game()    if G.STAGE == G.STAGES.RUN then win_game() end end
local function dt_lose_game()   if G.STAGE == G.STAGES.RUN then G.STATE = G.STATES.GAME_OVER; G.STATE_COMPLETE = false end end

-- Hover-based actions (require hovering a card)
local function get_hovered_card()
	if G.CONTROLLER and G.CONTROLLER.hovering and G.CONTROLLER.hovering.target then
		local t = G.CONTROLLER.hovering.target
		if t.is and t:is(Card) then return t end
	end
	return nil
end

local function dt_unlock()
	local _card = get_hovered_card()
	if _card and G.OVERLAY_MENU then
		unlock_card(_card.config.center)
		_card:set_sprites(_card.config.center)
	end
end

local function dt_discover()
	local _card = get_hovered_card()
	if _card and G.OVERLAY_MENU then
		unlock_card(_card.config.center)
		discover_card(_card.config.center)
		_card:set_sprites(_card.config.center)
	end
end

local function dt_spawn()
	local _card = get_hovered_card()
	if _card and G.OVERLAY_MENU then
		if _card.ability.set == 'Joker' and G.jokers and #G.jokers.cards < G.jokers.config.card_limit then
			add_joker(_card.config.center.key)
			_card:set_sprites(_card.config.center)
		end
		if _card.ability.consumeable and G.consumeables and #G.consumeables.cards < G.consumeables.config.card_limit then
			add_joker(_card.config.center.key)
			_card:set_sprites(_card.config.center)
		end
	end
end

local function dt_cycle_edition()
	local _card = get_hovered_card()
	if _card and (_card.ability.set == 'Joker' or _card.playing_card or _card.area) then
		local found_index = 1
		if _card.edition then
			for i, v in ipairs(G.P_CENTER_POOLS.Edition) do
				if v.key == _card.edition.key then
					found_index = i
					break
				end
			end
		end
		found_index = found_index + 1
		if found_index > #G.P_CENTER_POOLS.Edition then
			found_index = found_index - #G.P_CENTER_POOLS.Edition
		end
		local _edition = G.P_CENTER_POOLS.Edition[found_index].key
		_card:set_edition(_edition, true, true)
	end
end

local debug_funcs = {
	add_money     = dt_add_money,
	add_round     = dt_add_round,
	add_ante      = dt_add_ante,
	add_hand      = dt_add_hand,
	add_discard   = dt_add_discard,
	add_chips     = dt_add_chips,
	add_mult      = dt_add_mult,
	win_game      = dt_win_game,
	lose_game     = dt_lose_game,
	unlock        = dt_unlock,
	discover      = dt_discover,
	spawn         = dt_spawn,
	cycle_edition = dt_cycle_edition,
}

local function can_use_debug()
	return (not _RELEASE_MODE) or (Handy.cc.debug_always_enabled and Handy.cc.debug_always_enabled.enabled)
end

local function make_debug_action(func_name)
	return {
		use = function(key)
			if not can_use_debug() then return false end
			local cc = Handy.cc["debug_" .. func_name]
			if not cc then return false end
			-- pass true for allow_disabled since debug keys have no enabled field
			if Handy.controller.is_module_key(cc, key, true) then
				local f = debug_funcs[func_name]
				if f then f() end
				return true
			end
			return false
		end,
	}
end

Handy.debug_add_money     = make_debug_action("add_money")
Handy.debug_add_round     = make_debug_action("add_round")
Handy.debug_add_ante      = make_debug_action("add_ante")
Handy.debug_add_hand      = make_debug_action("add_hand")
Handy.debug_add_discard   = make_debug_action("add_discard")
Handy.debug_add_chips     = make_debug_action("add_chips")
Handy.debug_add_mult      = make_debug_action("add_mult")
Handy.debug_win_game      = make_debug_action("win_game")
Handy.debug_lose_game     = make_debug_action("lose_game")
Handy.debug_unlock        = make_debug_action("unlock")
Handy.debug_discover      = make_debug_action("discover")
Handy.debug_spawn         = make_debug_action("spawn")
Handy.debug_cycle_edition = make_debug_action("cycle_edition")
