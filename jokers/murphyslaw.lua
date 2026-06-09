SMODS.Atlas {
    key = 'murphyslaw',
    path = "j_murphy_law.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "murphyslaw",
    name = "Murphy's Law",
    atlas = 'murphyslaw',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "fuse_fusion",
    cost = 14,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            joker1 = "j_oops",
            joker2 = "j_oops",
            joker3 = "j_oops"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'}
            }
        }
    end,
    calculate = function(self, card, context)
        if context.fix_probability then
            return {
                numerator = context.denominator
            }
        end
    end
}
