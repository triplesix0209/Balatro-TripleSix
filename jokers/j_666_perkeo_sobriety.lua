SMODS.Atlas {
    key = 'perkeo_sobriety',
    path = "j_666_perkeo_sobriety.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "perkeo_sobriety",
    name = "Perkeo's Sobriety",
    atlas = 'perkeo_sobriety',
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
            joker1 = "j_perkeo",
            joker2 = "j_selzer",
            joker3 = "j_drunkard"
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
        -- 1. When a consumable card is used, add +2 discards and enable retriggers
        if context.using_consumeable and not context.blueprint then
            if G.GAME.blind and G.GAME.blind.in_blind then
                ease_discard(2)
                G.GAME.consumeable_used_this_round = true
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = "+2 Discards",
                    colour = G.C.RED
                })
            end
        end

        -- 2. Repetition for all played cards if a consumable has been used this round
        if context.repetition and context.cardarea == G.play then
            if G.GAME.consumeable_used_this_round then
                return {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    card = card
                }
            end
        end

        -- 5. Creates 2 Negative copies of random consumable cards in your possession at the end of the shop
        if context.ending_shop then
            local copies_created = 0
            for i = 1, 2 do
                if G.consumeables and G.consumeables.cards and #G.consumeables.cards > 0 then
                    local random_consumable = pseudorandom_element(G.consumeables.cards, pseudorandom('perkeo_sobriety_shop_' .. i))
                    local copy = copy_card(random_consumable, nil, nil, nil, true)
                    copy:set_edition({negative = true}, true)
                    copy:add_to_deck()
                    G.consumeables:emplace(copy)
                    copies_created = copies_created + 1
                end
            end
            if copies_created > 0 then
                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.SECONDARY_SET.Tarot,
                    card = card
                }
            end
        end
    end
}
