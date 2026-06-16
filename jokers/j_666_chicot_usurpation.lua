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
    cost = 18,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            joker1 = "j_chicot",
            joker2 = "j_luchador",
            joker3 = "j_baseball",
            x_mult = 1.0,
            x_mult_gain = 5.0,
            joker_xmult = 1.5,
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'},
                card.ability.extra.x_mult
            }
        }
    end,
    calculate = function(self, card, context)
        -- 1. Disables effect of every Boss Blind
        if context.setting_blind and not context.blueprint then
            if G.GAME.blind and G.GAME.blind.boss and not G.GAME.blind.disabled then
                G.GAME.blind:disable()
                play_sound('timpani')
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "Boss Disabled!",
                    colour = G.C.RED
                })
            end
        end

        -- 2. Each Joker gives X1.5 Mult
        if context.other_joker and context.other_joker ~= card then
            G.E_MANAGER:add_event(Event({
                func = function()
                    context.other_joker:juice_up(0.5, 0.5)
                    return true
                end
            }))
            return {
                message = "X1.5 Mult",
                Xmult_mod = card.ability.extra.joker_xmult,
                colour = G.C.MULT,
                card = card
            }
        end

        -- 3. Card's own X Mult application
        if context.joker_main then
            local total_xmult = card.ability.extra.x_mult * card.ability.extra.joker_xmult
            if total_xmult > 1 then
                return {
                    x_mult_mod = total_xmult,
                    card = card
                }
            end
        end

        -- 4. Scale X Mult upon Boss Blind defeat
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME.blind and G.GAME.blind.boss and G.GAME.chips >= G.GAME.blind.chips then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "X" .. tostring(card.ability.extra.x_mult) .. " Mult!",
                    colour = G.C.MULT
                })
            end
        end
    end
}
