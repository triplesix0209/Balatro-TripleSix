SMODS.Atlas {
    key = 'capitalist_taurus',
    path = "j_666_capitalist_taurus.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "capitalist_taurus",
    name = "Capitalist Taurus",
    atlas = 'capitalist_taurus',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "666_fusion",
    cost = 10,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            chip_multiplier = 2,
            mult_multiplier = 2,
            mult_threshold = 5,
            joker1 = "j_bull",
            joker2 = "j_bootstraps"
        }
    },
    loc_vars = function(self, info_queue, card)
        local dollars = math.max(0, (G.GAME and G.GAME.dollars or 0) + (G.GAME and G.GAME.dollar_buffer or 0))
        local current_chips = card.ability.extra.chip_multiplier * dollars
        local current_mult = card.ability.extra.mult_multiplier * math.floor(dollars / card.ability.extra.mult_threshold)
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                card.ability.extra.chip_multiplier,
                card.ability.extra.mult_multiplier,
                card.ability.extra.mult_threshold,
                current_chips,
                current_mult
            }
        }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local dollars = math.max(0, G.GAME.dollars + (G.GAME.dollar_buffer or 0))
            local chips = card.ability.extra.chip_multiplier * dollars
            local mult = card.ability.extra.mult_multiplier * math.floor(dollars / card.ability.extra.mult_threshold)
            
            local to_big = to_big or function(x) return x end
            if to_big(chips) > to_big(0) or to_big(mult) > to_big(0) then
                return {
                    message = "+" .. chips .. " Chips, +" .. mult .. " Mult",
                    chips = chips,
                    mult = mult,
                    colour = G.C.GOLD
                }
            end
        end
    end
}
