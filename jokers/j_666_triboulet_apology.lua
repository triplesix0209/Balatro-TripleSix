SMODS.Atlas {
    key = 'triboulet_apology',
    path = "j_666_triboulet_apology.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "triboulet_apology",
    name = "Triboulet's Apology",
    atlas = 'triboulet_apology',
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
            x_mult_played = 3,
            x_mult_held = 2,
            joker1 = "j_triboulet",
            joker2 = "j_baron",
            joker3 = "j_shoot_the_moon"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.x_mult_played,
                card.ability.extra.x_mult_held,
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'}
            }
        }
    end,
    calculate = function(self, card, context)
        -- Played Kings and Queens score X3 Mult
        if context.individual and context.cardarea == G.play then
            local rank = context.other_card:get_id()
            if rank == 13 or rank == 12 then
                return {
                    x_mult = card.ability.extra.x_mult_played,
                    card = card
                }
            end
        end

        -- Kings and Queens held in hand give X2 Mult
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            local rank = context.other_card:get_id()
            if rank == 13 or rank == 12 then
                if context.other_card.debuff then return end
                return {
                    x_mult = card.ability.extra.x_mult_held,
                    card = card
                }
            end
        end
    end
}

-- Override get_id to swap/extend Kings and Queens
local card_get_id_ref = Card.get_id
function Card:get_id()
    local id = card_get_id_ref(self)
    if G.STAGE == G.STAGES.RUN and next(SMODS.find_card('j_666_triboulet_apology')) then
        if id == 13 or id == 12 then
            if SMODS.current_evaluated_object and SMODS.current_evaluated_object.ability then
                local joker_name = SMODS.current_evaluated_object.ability.name
                if joker_name == 'Baron' then
                    return 13
                elseif joker_name == 'Shoot the Moon' then
                    return 12
                elseif joker_name == 'The Idol' and G.GAME.current_round.idol_card then
                    local target_id = G.GAME.current_round.idol_card.id
                    if target_id == 13 or target_id == 12 then
                        return target_id
                    end
                elseif joker_name == 'Mail Checker' and G.GAME.current_round.mail_card then
                    local target_id = G.GAME.current_round.mail_card.id
                    if target_id == 13 or target_id == 12 then
                        return target_id
                    end
                elseif joker_name == 'Odd Todd' then
                    return 13
                elseif joker_name == 'Even Steven' then
                    return 12
                end
            end
        end
    end
    return id
end
