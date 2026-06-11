SMODS.Atlas {
    key = 'yorick_skull',
    path = "j_666_yorick_skull.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "yorick_skull",
    name = "Yorick's Skull",
    atlas = 'yorick_skull',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "666_fusion",
    cost = 20,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            chips = 0,
            chip_mod = 2,
            x_mult_mod = 1.0,
            chips_period = 23,
            joker1 = "j_yorick",
            joker2 = "j_mr_bones",
            joker3 = "j_castle"
        }
    },
    loc_vars = function(self, info_queue, card)
        local dynamic_x_mult = 1.0 + math.floor(card.ability.extra.chips / card.ability.extra.chips_period) * card.ability.extra.x_mult_mod
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'},
                card.ability.extra.chip_mod,
                card.ability.extra.x_mult_mod,
                card.ability.extra.chips_period,
                card.ability.extra.chips,
                dynamic_x_mult
            }
        }
    end,
    calculate = function(self, card, context)
        -- 1. Death prevention: Mr. Bones effect (runs on context.end_of_round and context.game_over)
        if context.end_of_round and context.game_over and not context.blueprint then
            if G.GAME.chips / G.GAME.blind.chips >= 0.25 then
                return {
                    message = localize('k_saved_ex'),
                    saved = true,
                    colour = G.C.RED
                }
            end
        end

        -- 2. Discard scaling: Castle + Yorick effects
        if context.discard and not context.blueprint then
            -- Scale chips (+2 per discarded card)
            local old_chips = card.ability.extra.chips
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod

            -- Check if we crossed a chips_period boundary to trigger the "X... Mult!" message
            local old_xmult = 1.0 + math.floor(old_chips / card.ability.extra.chips_period) * card.ability.extra.x_mult_mod
            local new_xmult = 1.0 + math.floor(card.ability.extra.chips / card.ability.extra.chips_period) * card.ability.extra.x_mult_mod
            if new_xmult > old_xmult then
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "X" .. tostring(new_xmult) .. " Mult!",
                    colour = G.C.MULT
                })
            end

            -- Display visual feedback only on the last card of the discarded hand to avoid message spam
            if context.other_card == context.full_hand[#context.full_hand] then
                local total_discarded = #context.full_hand
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "+" .. tostring(total_discarded * card.ability.extra.chip_mod) .. " Chips",
                    colour = G.C.CHIPS
                })
            end
        end

        -- 3. Scoring hand application
        if context.joker_main then
            local chips = card.ability.extra.chips
            local xmult = 1.0 + math.floor(chips / card.ability.extra.chips_period) * card.ability.extra.x_mult_mod
            if chips > 0 or xmult > 1 then
                local message = ""
                if chips > 0 and xmult > 1 then
                    message = "+" .. chips .. " Chips, X" .. xmult .. " Mult"
                elseif chips > 0 then
                    message = "+" .. chips .. " Chips"
                else
                    message = "X" .. xmult .. " Mult"
                end
                return {
                    message = message,
                    chip_mod = chips,
                    x_mult_mod = xmult,
                    colour = G.C.GOLD
                }
            end
        end
    end
}
