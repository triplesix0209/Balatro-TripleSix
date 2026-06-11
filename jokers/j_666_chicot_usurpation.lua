SMODS.Atlas {
    key = 'chicot_usurpation',
    path = "j_666_chicot_usurpation.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "chicot_usurpation",
    name = "Chicot's Usurpation",
    atlas = 'chicot_usurpation',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "666_fusion",
    cost = 16,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            stolen_bosses = {},
            stolen_count = 0,
            stolen_bosses_order = {},
            joker1 = "j_chicot",
            joker2 = "j_luchador",
            joker3 = "j_misprint",
            round_hands = {},
            verdant_leaf_triggered = false,
            crimson_heart_joker = nil,
            last_ante = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        local list_str = "None"
        if card.ability and card.ability.extra and card.ability.extra.stolen_bosses then
            -- Initialize order array if it doesn't exist
            card.ability.extra.stolen_bosses_order = card.ability.extra.stolen_bosses_order or {}
            
            -- Backwards compatibility / Sync fallback
            local order = {
                "bl_hook", "bl_ox", "bl_house", "bl_wall", "bl_wheel", "bl_arm", "bl_club", 
                "bl_fish", "bl_psychic", "bl_goad", "bl_water", "bl_window", "bl_manacle", 
                "bl_eye", "bl_mouth", "bl_plant", "bl_serpent", "bl_pillar", "bl_needle", 
                "bl_head", "bl_tooth", "bl_flint", "bl_mark", "bl_acorn", "bl_leaf", 
                "bl_vessel", "bl_heart", "bl_bell"
            }
            if #card.ability.extra.stolen_bosses_order == 0 then
                for _, k in ipairs(order) do
                    if card.ability.extra.stolen_bosses[k] then
                        table.insert(card.ability.extra.stolen_bosses_order, k)
                    end
                end
            else
                -- Sync check: make sure all true keys in stolen_bosses are in stolen_bosses_order
                local order_set = {}
                for _, k in ipairs(card.ability.extra.stolen_bosses_order) do
                    order_set[k] = true
                end
                for _, k in ipairs(order) do
                    if card.ability.extra.stolen_bosses[k] and not order_set[k] then
                        table.insert(card.ability.extra.stolen_bosses_order, k)
                    end
                end
            end

            -- Build the display list string for main description
            local names = {}
            local display_names = {
                bl_hook = "The Hook", bl_ox = "The Ox", bl_house = "The House", bl_wall = "The Wall",
                bl_wheel = "The Wheel", bl_arm = "The Arm", bl_club = "The Club", bl_fish = "The Fish",
                bl_psychic = "The Psychic", bl_goad = "The Goad", bl_water = "The Water", bl_window = "The Window",
                bl_manacle = "The Manacle", bl_eye = "The Eye", bl_mouth = "The Mouth", bl_plant = "The Plant",
                bl_serpent = "The Serpent", bl_pillar = "The Pillar", bl_needle = "The Needle", bl_head = "The Head",
                bl_tooth = "The Tooth", bl_flint = "The Flint", bl_mark = "The Mark", bl_acorn = "Amber Acorn",
                bl_leaf = "Verdant Leaf", bl_vessel = "Violet Vessel", bl_heart = "Crimson Heart", bl_bell = "Cerulean Bell"
            }
            for _, k in ipairs(order) do
                if card.ability.extra.stolen_bosses[k] then
                    table.insert(names, display_names[k] or k)
                end
            end
            if #names > 0 then
                list_str = table.concat(names, ", ")
            end

            -- Populate info_queue. Limit to 5 entries.
            -- If total stolen bosses is <= 5, show all of them.
            -- If total stolen bosses is > 5, show the 4 most recently stolen and the "+X more" box.
            local total_stolen = #card.ability.extra.stolen_bosses_order
            if total_stolen <= 5 then
                for _, k in ipairs(card.ability.extra.stolen_bosses_order) do
                    table.insert(info_queue, { key = "chicot_" .. k, set = "Other" })
                end
            else
                for i = total_stolen - 3, total_stolen do
                    local k = card.ability.extra.stolen_bosses_order[i]
                    if k then
                        table.insert(info_queue, { key = "chicot_" .. k, set = "Other" })
                    end
                end
                table.insert(info_queue, { key = "chicot_more_buffs", set = "Other", vars = { total_stolen - 4 } })
            end
        end
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'},
                list_str
            }
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        if card.ability.extra.stolen_bosses["bl_manacle"] then
            G.hand:change_size(1)
        end
        if card.ability.extra.stolen_bosses["bl_wheel"] then
            G.GAME.probabilities.normal = G.GAME.probabilities.normal + 1
        end
    end,
    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.stolen_bosses["bl_manacle"] then
            G.hand:change_size(-1)
        end
        if card.ability.extra.stolen_bosses["bl_wheel"] then
            G.GAME.probabilities.normal = G.GAME.probabilities.normal - 1
        end
    end,
    update = function(self, card, dt)
        -- Keep track of original hand cards at the start of each round to detect drawn cards for The Fish
        if G.STAGE == G.STAGES.RUN and G.hand and G.hand.cards then
            -- Assign original_card flag to cards at the very beginning (0 hands played)
            if G.GAME.hands_played == 0 then
                for _, c in ipairs(G.hand.cards) do
                    if not c.original_card then
                        c.original_card = true
                        c.drawn_after_play = nil
                    end
                end
            elseif G.GAME.hands_played > 0 then
                -- Mark any new cards drawn as drawn_after_play
                if card.ability.extra.stolen_bosses["bl_fish"] and not card.debuff then
                    for _, c in ipairs(G.hand.cards) do
                        if not c.original_card and not c.drawn_after_play then
                            c.drawn_after_play = true
                        end
                    end
                end
            end

            -- Cerulean Bell / The Bell: Handle forced selection card drawing
            if (card.ability.extra.stolen_bosses["bl_bell"] or card.ability.extra.stolen_bosses["bl_bell"]) and not card.debuff then
                local has_forced = false
                for _, c in ipairs(G.hand.cards) do
                    if c.forced_selection then has_forced = true; break end
                end
                if not has_forced and #G.hand.cards > 0 then
                    local random_card = pseudorandom_element(G.hand.cards, pseudorandom('cerulean_bell_force'))
                    if random_card then
                        random_card.forced_selection = true
                        -- The Bell: Transform to random enhancement
                        if card.ability.extra.stolen_bosses["bl_bell"] then
                            local enhancements = {
                                G.P_CENTERS.m_steel, G.P_CENTERS.m_gold, G.P_CENTERS.m_glass, 
                                G.P_CENTERS.m_lucky, G.P_CENTERS.m_mult, G.P_CENTERS.m_bonus, 
                                G.P_CENTERS.m_wild
                            }
                            local selected_enhance = pseudorandom_element(enhancements, pseudorandom('bell_enhance'))
                            random_card:set_ability(selected_enhance)
                        end
                    end
                end
            end
        end
    end,
    calculate = function(self, card, context)
        -- Disables effect of every Boss Blind
        if context.setting_blind and not context.blueprint then
            if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
                play_sound('timpani')
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Boss Disabled!",
                    colour = G.C.RED
                })
            end

            -- Reset round/blind status flags
            card.ability.extra.round_hands = {}
            card.ability.extra.verdant_leaf_triggered = false
            card.ability.extra.crimson_heart_joker = nil
            for _, c in ipairs(G.hand.cards or {}) do
                c.original_card = true
                c.drawn_after_play = nil
            end

            -- Passive: The Wall (-25% goal chips)
            if card.ability.extra.stolen_bosses["bl_wall"] and G.GAME.blind then
                G.GAME.blind.chips = G.GAME.blind.chips * 0.75
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            end
            -- Passive: Violet Vessel (-40% goal chips)
            if card.ability.extra.stolen_bosses["bl_vessel"] and G.GAME.blind then
                G.GAME.blind.chips = G.GAME.blind.chips * 0.60
                G.GAME.blind.chip_text = number_format(G.GAME.blind.chips)
            end
            -- Passive: The Water (+2 Discards)
            if card.ability.extra.stolen_bosses["bl_water"] then
                ease_discard(2)
            end
            -- Passive: The Needle (+2 Hands)
            if card.ability.extra.stolen_bosses["bl_needle"] then
                ease_hands(2)
            end

            -- Passive: The Pillar (Reset cocks played in this Ante when Ante changes)
            local current_ante = G.GAME.round_resets.ante
            if card.ability.extra.last_ante ~= current_ante then
                card.ability.extra.last_ante = current_ante
                for _, c in ipairs(G.playing_cards or {}) do
                    c.played_this_ante = nil
                end
            end
        end

        -- Passive: The Arm (+1 Level to played poker hand before scoring)
        if context.before and not context.blueprint then
            if card.ability.extra.stolen_bosses["bl_arm"] then
                local hand_name = context.scoring_name or context.poker_hand or G.GAME.last_hand_played
                if hand_name then
                    update_hand_wrapper(card, function()
                        level_up_hand(card, hand_name, nil, 1)
                    end)
                end
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Arm Level Up!",
                    colour = G.C.BLUE
                })
            end
        end

        -- Played card repetitions (The Club, The Goad, The Window, The Head, The Plant, The Eye, The Mouth, The Pillar)
        if context.repetition and context.cardarea == G.play then
            local is_face = context.other_card:is_face()
            local stolen = card.ability.extra.stolen_bosses

            local trigger = false
            -- Suits & Face retriggers
            if (context.other_card:is_suit("Clubs") and stolen["bl_club"]) or
               (context.other_card:is_suit("Spades") and stolen["bl_goad"]) or
               (context.other_card:is_suit("Diamonds") and stolen["bl_window"]) or
               (context.other_card:is_suit("Hearts") and stolen["bl_head"]) or
               (is_face and stolen["bl_plant"]) then
                trigger = true
            end

            -- The Eye (Played repeat hand)
            local hand_name = context.scoring_name or context.poker_hand or G.GAME.last_hand_played
            if stolen["bl_eye"] and hand_name and card.ability.extra.round_hands[hand_name] and card.ability.extra.round_hands[hand_name] > 0 then
                trigger = true
            end

            -- The Mouth (First played hand in round)
            if stolen["bl_mouth"] and G.GAME.hands_played == 0 then
                trigger = true
            end

            -- The Pillar (Played in this Ante before)
            if stolen["bl_pillar"] and context.other_card.played_this_ante then
                trigger = true
            end

            if trigger then
                return {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    card = card
                }
            end
        end

        -- Individual card evaluations (The Fish, The Tooth, The Mark, Cerulean Bell)
        if context.individual and context.cardarea == G.play then
            local stolen = card.ability.extra.stolen_bosses
            local x_mult = 1
            local dollars = 0

            -- The Fish (Drawn after a played hand)
            if stolen["bl_fish"] and context.other_card.drawn_after_play then
                x_mult = x_mult * 2
            end

            -- The Mark (Face cards give X2 Mult)
            if stolen["bl_mark"] and context.other_card:is_face() then
                x_mult = x_mult * 2
            end

            -- Cerulean Bell (Forced selection cards give X5 Mult)
            if stolen["bl_bell"] and context.other_card.forced_selection then
                x_mult = x_mult * 5
            end

            -- The Tooth (+$1 per scored card)
            if stolen["bl_tooth"] then
                dollars = dollars + 1
            end

            if x_mult > 1 or dollars > 0 then
                return {
                    x_mult = x_mult > 1 and x_mult or nil,
                    dollars = dollars > 0 and dollars or nil,
                    card = card
                }
            end
        end

        -- Poker Hand Modifiers (The House, The Flint, Amber Acorn, Crimson Heart)
        if context.joker_main then
            local stolen = card.ability.extra.stolen_bosses
            local x_mult = 1
            local mult = 0
            local chips = 0

            -- The House (First hand of round X2 Mult)
            if stolen["bl_house"] and G.GAME.hands_played == 0 then
                x_mult = x_mult * 2
            end

            -- The Flint (Double base Chips and base Mult)
            if stolen["bl_flint"] then
                local hand_name = context.scoring_name or context.poker_hand or G.GAME.last_hand_played
                if hand_name and G.GAME.hands[hand_name] then
                    local base_chips = G.GAME.hands[hand_name].chips
                    local base_mult = G.GAME.hands[hand_name].mult
                    chips = chips + base_chips
                    mult = mult + base_mult
                end
            end

            -- Amber Acorn (+10 Mult per Joker card in possession)
            if stolen["bl_acorn"] then
                local count = #G.jokers.cards
                mult = mult + count * 10
            end

            -- Crimson Heart (X5 Mult for a random Joker selected after last hand)
            if stolen["bl_heart"] and card.ability.extra.crimson_heart_joker then
                local alive = false
                for _, j in ipairs(G.jokers.cards) do
                    if j == card.ability.extra.crimson_heart_joker then alive = true; break end
                end
                if alive then
                    x_mult = x_mult * 5
                end
            end

            if x_mult > 1 or mult > 0 or chips > 0 then
                return {
                    x_mult = x_mult > 1 and x_mult or nil,
                    mult_mod = mult > 0 and mult or nil,
                    chip_mod = chips > 0 and chips or nil,
                    card = card
                }
            end
        end

        -- Discard and Play hand triggers (The Hook, The Ox, The Serpent, The Eye, Crimson Heart, The Pillar)
        if context.after and not context.blueprint then
            local stolen = card.ability.extra.stolen_bosses

            -- Update The Eye hands list
            local hand_name = context.scoring_name or context.poker_hand or G.GAME.last_hand_played
            if hand_name then
                card.ability.extra.round_hands[hand_name] = (card.ability.extra.round_hands[hand_name] or 0) + 1
            end

            -- Mark cards played in this Ante for The Pillar
            if context.full_hand then
                for _, c in ipairs(context.full_hand) do
                    c.played_this_ante = true
                end
            end

            -- The Hook (Draw +1 card after played hand)
            if stolen["bl_hook"] then
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        draw_card(G.deck, G.hand, 1, 'up', true)
                        return true
                    end
                }))
            end

            -- The Ox (Playing most played hand doubles money)
            if stolen["bl_ox"] then
                local most_played_hand = nil
                local max_plays = -1
                for k, v in pairs(G.GAME.hands) do
                    if v.played > max_plays then
                        max_plays = v.played
                        most_played_hand = k
                    end
                end
                local hand_name = context.scoring_name or context.poker_hand or G.GAME.last_hand_played
                if hand_name == most_played_hand and G.GAME.dollars > 0 then
                    ease_dollars(G.GAME.dollars)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Ox Bounty!",
                        colour = G.C.GOLD
                    })
                end
            end

            -- Crimson Heart (Select a random Joker for next hand X5 Mult)
            if stolen["bl_heart"] then
                local jokers = {}
                for _, j in ipairs(G.jokers.cards) do
                    if j ~= card then table.insert(jokers, j) end
                end
                if #jokers > 0 then
                    local selected = pseudorandom_element(jokers, pseudorandom('crimson_heart'))
                    card.ability.extra.crimson_heart_joker = selected
                    card_eval_status_text(selected, 'extra', nil, nil, nil, {
                        message = "Crimson Heart X5!",
                        colour = G.C.RED
                    })
                end
            end

            -- The Serpent (Always draw back to full hand size)
            if stolen["bl_serpent"] then
                local cards_needed = G.hand.config.card_limit - #G.hand.cards
                if cards_needed > 0 then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'immediate',
                        func = function()
                            draw_card(G.deck, G.hand, cards_needed, 'up', true)
                            return true
                        end
                    }))
                end
            end
        end

        -- Handle card discard events (The Serpent)
        if context.discard and not context.blueprint then
            local stolen = card.ability.extra.stolen_bosses
            -- The Serpent (Draw back to full hand size after discard)
            if stolen["bl_serpent"] then
                -- Wait a frame for deck size calculation to clear
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        local cards_needed = G.hand.config.card_limit - #G.hand.cards
                        if cards_needed > 0 then
                            draw_card(G.deck, G.hand, cards_needed, 'up', true)
                        end
                        return true
                    end
                }))
            end
        end

        -- Verdant Leaf (Selling Joker spawns random Joker, max 1/round)
        if context.selling_card and context.card.ability.set == 'Joker' and not context.blueprint then
            if card.ability.extra.stolen_bosses["bl_leaf"] and not card.ability.extra.verdant_leaf_triggered then
                card.ability.extra.verdant_leaf_triggered = true
                G.E_MANAGER:add_event(Event({
                    trigger = 'immediate',
                    func = function()
                        local new_joker = create_card('Joker', G.jokers, nil, nil, nil, nil, nil, 'verdant_leaf')
                        new_joker:add_to_deck()
                        G.jokers:emplace(new_joker)
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Usurped!",
                    colour = G.C.GREEN
                })
            end
        end

        -- Usurping Boss Blind upon defeat
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME.blind and G.GAME.blind.boss and G.GAME.chips >= G.GAME.blind.chips then
                local boss_key = G.GAME.blind.config.blind.key
                card.ability.extra.stolen_bosses = card.ability.extra.stolen_bosses or {}
                card.ability.extra.stolen_bosses_order = card.ability.extra.stolen_bosses_order or {}
                if not card.ability.extra.stolen_bosses[boss_key] then
                    card.ability.extra.stolen_bosses[boss_key] = true
                    card.ability.extra.stolen_count = (card.ability.extra.stolen_count or 0) + 1
                    table.insert(card.ability.extra.stolen_bosses_order, boss_key)

                    -- Apply permanent stat change: The Manacle (+1 Hand size)
                    if boss_key == "bl_manacle" then
                        G.hand:change_size(1)
                    end
                    -- Apply permanent stat change: The Wheel (+1 Probability)
                    if boss_key == "bl_wheel" then
                        G.GAME.probabilities.normal = G.GAME.probabilities.normal + 1
                    end

                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Usurped " .. (G.GAME.blind.name or boss_key) .. "!",
                        colour = G.C.GOLD
                    })
                end
            end

            -- Clean round stats
            card.ability.extra.round_hands = {}
            card.ability.extra.verdant_leaf_triggered = false
            card.ability.extra.crimson_heart_joker = nil
        end
    end
}
