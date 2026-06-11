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
            x_mult = 3,
            lives = 1,
            joker1 = "j_triboulet",
            joker2 = "j_baron",
            joker3 = "j_shoot_the_moon"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'},
                card.ability.extra.x_mult,
                card.ability.extra.lives
            }
        }
    end,
    calculate = function(self, card, context)
        -- Reset shield at the start of each round
        if context.setting_blind and not context.blueprint then
            card.ability.extra.lives = 1
        end

        -- Played Kings and Queens score X Mult
        if context.individual and context.cardarea == G.play then
            local rank = context.other_card:get_id()
            if rank == 13 or rank == 12 then
                return {
                    x_mult = card.ability.extra.x_mult,
                    card = card
                }
            end
        end

        -- Kings and Queens held in hand give 1/2 of X Mult
        if context.individual and context.cardarea == G.hand and not context.end_of_round then
            local rank = context.other_card:get_id()
            if rank == 13 or rank == 12 then
                if context.other_card.debuff then return end
                return {
                    x_mult = card.ability.extra.x_mult * 0.5,
                    card = card
                }
            end
        end
    end
}

-- Override start_dissolve to protect Triboulet's Apology from destruction once
local card_start_dissolve_ref = Card.start_dissolve
function Card:start_dissolve(dissolve_colours, silent, dissolve_time_fac, no_juice)
    if self.config.center.key == 'j_666_triboulet_apology' and self.area and (self.area == G.jokers or self.area == G.consumeables) and not self.selling and not self.debuff then
        if self.ability.extra.lives and self.ability.extra.lives > 0 then
            self.ability.extra.lives = self.ability.extra.lives - 1
            self.ability.extra.x_mult = self.ability.extra.x_mult + 1
            self.getting_sliced = nil
            card_eval_status_text(self, 'extra', nil, nil, nil, {
                message = "Pardoned! +1.0x Mult",
                colour = G.C.GOLD
            })
            return
        end
    end
    return card_start_dissolve_ref(self, dissolve_colours, silent, dissolve_time_fac, no_juice)
end
