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
            retrigger_hand = false,
            added_discards = 0,
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
    remove_from_deck = function(self, card, from_debuff)
        if card.ability.extra.added_discards and card.ability.extra.added_discards > 0 then
            G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.added_discards
            ease_discard(-card.ability.extra.added_discards)
            card.ability.extra.added_discards = 0
        end
    end,
    calculate = function(self, card, context)
        -- 1. Gain +1 discard for each consumable card (calculated at start of round)
        if context.setting_blind and not context.blueprint then
            if card.ability.extra.added_discards and card.ability.extra.added_discards > 0 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.added_discards
                card.ability.extra.added_discards = 0
            end
            if G.consumeables and G.consumeables.cards then
                local extra_discards = #G.consumeables.cards
                if extra_discards > 0 then
                    card.ability.extra.added_discards = extra_discards
                    G.GAME.round_resets.discards = G.GAME.round_resets.discards + extra_discards
                    ease_discard(extra_discards)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "+" .. tostring(extra_discards) .. " Discards",
                        colour = G.C.RED
                    })
                end
            end
        end

        -- 2. When play hand, retrigger all cards played by consuming 1 random consumable card
        if context.before and not context.blueprint then
            card.ability.extra.retrigger_hand = false
            if G.consumeables and G.consumeables.cards and #G.consumeables.cards > 0 then
                card.ability.extra.retrigger_hand = true
                local random_consumable = pseudorandom_element(G.consumeables.cards, pseudorandom('perkeo_sobriety'))
                random_consumable:start_dissolve()
                play_sound('card1')
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = localize('k_active_ex'),
                    colour = G.C.FILTER
                })
            end
        end

        if context.repetition and context.cardarea == G.play then
            if card.ability.extra.retrigger_hand then
                return {
                    message = localize('k_again_ex'),
                    repetitions = 1,
                    card = card
                }
            end
        end

        if context.after and not context.blueprint then
            card.ability.extra.retrigger_hand = false
        end

        if context.end_of_round and not context.blueprint then
            if card.ability.extra.added_discards and card.ability.extra.added_discards > 0 then
                G.GAME.round_resets.discards = G.GAME.round_resets.discards - card.ability.extra.added_discards
                card.ability.extra.added_discards = 0
            end
        end

        -- 3. Creates a Negative copy of 1 random consumable card in your possession at the end of the shop
        if context.ending_shop and not context.blueprint then
            if G.consumeables and G.consumeables.cards and #G.consumeables.cards > 0 then
                local random_consumable = pseudorandom_element(G.consumeables.cards, pseudorandom('perkeo_sobriety_shop'))
                local copy = copy_card(random_consumable, nil, nil, nil, true)
                copy:set_edition({negative = true}, true)
                copy:add_to_deck()
                G.consumeables:emplace(copy)
                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.SECONDARY_SET.Tarot,
                    card = card
                }
            end
        end
    end
}
