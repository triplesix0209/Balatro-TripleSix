SMODS.Atlas {
    key = 'trio_jester',
    path = "j_666_trio_jester.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "trio_jester",
    name = "Trio Jester",
    atlas = 'trio_jester',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "666_fusion",
    cost = 8,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        h_size = 4,
        d_size = 2,
        extra = {
            joker1 = "j_troubadour",
            joker2 = "j_juggler",
            joker3 = "j_drunkard",
            hands_add = 1
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'},
                card.ability.h_size,
                card.ability.d_size,
                card.ability.extra.hands_add
            }
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands_add
        ease_hands_played(card.ability.extra.hands_add)
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands_add
        ease_hands_played(-card.ability.extra.hands_add)
    end,
    calculate = function(self, card, context)
        -- Passive effect, no calculation triggers needed
    end
}
