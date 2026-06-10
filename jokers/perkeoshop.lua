SMODS.Atlas {
    key = 'perkeo_shop',
    path = "j_perkeo_shop.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "perkeo_shop",
    name = "Perkeo Shop",
    atlas = 'perkeo_shop',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "fuse_fusion",
    cost = 19,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            x_mult = 1.0,
            x_mult_gain = 0.25,
            joker1 = "j_perkeo",
            joker2 = "j_lucky_cat",
            joker3 = "j_fuse_murphyslaw"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                card.ability.extra.x_mult_gain,
                card.ability.extra.x_mult,
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'}
            }
        }
    end,
    calculate = function(self, card, context)
        -- Murphy's Law effect: All listed probabilities always trigger
        if context.fix_probability then
            return {
                numerator = context.denominator
            }
        end

        -- Lucky Cat effect: Gain XMult on Lucky Card triggers
        if context.individual and context.cardarea == G.play then
            if context.other_card.lucky_trigger then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_gain
                return {
                    extra = {message = localize('k_upgrade_ex'), colour = G.C.MULT},
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    message = localize{type='variable', key='a_xmult', vars={card.ability.extra.x_mult}},
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.MULT
                }
            end
        end

        -- Perkeo effect: Creates 2 Negative copies of 1 random consumable card in possession at the end of the shop
        if context.ending_shop then
            if G.consumeables and G.consumeables.cards and #G.consumeables.cards > 0 then
                local random_consumable = pseudorandom_element(G.consumeables.cards, pseudorandom('perkeo_shop'))
                for i = 1, 2 do
                    local copy = copy_card(random_consumable, nil, nil, nil, true)
                    copy:set_edition({negative = true}, true)
                    copy:add_to_deck()
                    G.consumeables:emplace(copy)
                end
                return {
                    message = localize('k_copied_ex'),
                    colour = G.C.SECONDARY_SET.Tarot,
                    card = card
                }
            end
        end
    end,
    joker_display_def = function(JokerDisplay)
        return {
            text = {
                { text = "x" },
                { ref_table = "card.ability.extra", ref_value = "x_mult", retrigger_type = "xmult" }
            },
            text_config = { colour = G.C.XMULT }
        }
    end
}
