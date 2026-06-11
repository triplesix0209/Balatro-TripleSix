SMODS.Atlas {
    key = 'big_bang',
    path = "j_666_big_bang.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "big_bang",
    name = "Big Bang",
    atlas = 'big_bang',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "666_fusion",
    cost = 12,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            Xmult = 0.1, 
            joker1 = "j_supernova", 
            joker2 = "j_constellation",
            joker3 = "j_space"
        }
    },
    loc_vars = function(self, info_queue, card)
        local luck, odds = SMODS.get_probability_vars(card, 1, 2, "big_bang_desc", false)
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'},
                card.ability.extra.Xmult,
                luck,
                odds
            }
        }
    end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.joker_main and context.scoring_name then
			local mult_val = 1 + card.ability.extra.Xmult * (G.GAME.hands[context.scoring_name].level + G.GAME.hands[context.scoring_name].played)
			return {
				message = localize{type='variable',key='a_xmult',vars={mult_val}},
                Xmult_mod = mult_val
			}
		end
        if context.cardarea == G.jokers and context.before and context.scoring_name then
            if SMODS.pseudorandom_probability(card, 'big_bang', 1, 2, 'big_bang') then
                update_hand_text({sound = 'button', volume = 0.7, pitch = 0.8, delay = 0.3}, {handname = localize(context.scoring_name, 'poker_hands'), chips = G.GAME.hands[context.scoring_name].chips, mult = G.GAME.hands[context.scoring_name].mult, level = G.GAME.hands[context.scoring_name].level})
                level_up_hand(card, context.scoring_name, nil, 1)
                return {
                    message = localize('k_level_up_ex'),
                    colour = G.C.BLUE,
                    card = card
                }
            end
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                {
                    border_nodes = {
                        { text = "X" },
                        { ref_table = "card.joker_display_values", ref_value = "Xmult", retrigger_type = "exp" }
                    }
                }
            },
            calc_function = function(card)
                local text, _, _ = JokerDisplay.evaluate_hand()
                card.joker_display_values.Xmult = 1 + card.ability.extra.Xmult * ((text ~= 'Unknown' and G.GAME and G.GAME.hands[text] and G.GAME.hands[text].level + G.GAME.hands[text].played + (next(G.play.cards) and 0 or 1)) or
                0)
            end
        }
    end
}

-- See localization/en-us.lua to create joker text