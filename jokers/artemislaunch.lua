SMODS.Atlas {
    key = 'artemis_launch',
    path = "j_artemis_launch.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "artemis_launch",
    name = "Artemis Launch",
    atlas = 'artemis_launch',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "fuse_fusion",
    cost = 10,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            interest_amount_increase = 2,
            interest_amount_gain = 1,
            interest_threshold = 5,
            joker1 = "j_to_the_moon",
            joker2 = "j_rocket"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.interest_amount_increase,
                card.ability.extra.interest_threshold,
                card.ability.extra.interest_amount_gain,
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'}
            }
        }
    end,
    add_to_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount + card.ability.extra.interest_amount_increase
    end,
    remove_from_deck = function(self, card, from_debuff)
        G.GAME.interest_amount = G.GAME.interest_amount - card.ability.extra.interest_amount_increase
    end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            if G.GAME.blind.boss then
                card.ability.extra.interest_amount_increase = card.ability.extra.interest_amount_increase + card.ability.extra.interest_amount_gain
                G.GAME.interest_amount = G.GAME.interest_amount + card.ability.extra.interest_amount_gain
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.GOLD,
                    card = card
                }
            end
        end
    end
}
