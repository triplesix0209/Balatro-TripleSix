SMODS.Atlas {
    key = 'canio_madness',
    path = "j_666_canio_madness.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "canio_madness",
    name = "Canio's Madness",
    atlas = 'canio_madness',
    pos = {
        x = 0,
        y = 0
    },
    rarity = "666_fusion",
    cost = 17,
    unlocked = true,
    discovered = false,
    eternal_compat = true,
    perishable_compat = true,
    blueprint_compat = true,
    config = {
        extra = {
            x_mult = 1.0,
            destroy_xmult_gain = 1.0,
            joker1 = "j_caino",
            joker2 = "j_ceremonial",
            joker3 = "j_madness"
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
        -- 1. When a playing card is destroyed (e.g. Hanged Man)
        if context.remove_playing_cards and not context.blueprint then
            local gain = 0
            for _, val in ipairs(context.removed) do
                if val:is_face() then
                    gain = gain + card.ability.extra.destroy_xmult_gain
                end
            end
            if gain > 0 then
                card.ability.extra.x_mult = card.ability.extra.x_mult + gain
                return {
                    message = localize{type='variable', key='a_xmult', vars={card.ability.extra.x_mult}},
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        -- 2. When a playing card shatters (Glass card)
        if context.cards_destroyed and not context.blueprint then
            local gain = 0
            for _, val in ipairs(context.glass_shattered) do
                if val:is_face() then
                    gain = gain + card.ability.extra.destroy_xmult_gain
                end
            end
            if gain > 0 then
                card.ability.extra.x_mult = card.ability.extra.x_mult + gain
                return {
                    message = localize{type='variable', key='a_xmult', vars={card.ability.extra.x_mult}},
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        -- 3. When a Joker is destroyed
        if context.joker_type_destroyed and not context.blueprint then
            if context.card ~= card then
                local gain = (context.card.sell_cost or 0) * 0.5
                card.ability.extra.x_mult = card.ability.extra.x_mult + gain
                return {
                    message = localize{type='variable', key='a_xmult', vars={card.ability.extra.x_mult}},
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        -- 4. Ceremonial Dagger effect: Destroy Joker to the right on setting blind
        if context.setting_blind and not context.blueprint then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos+1] and not card.getting_sliced and not SMODS.is_eternal(G.jokers.cards[my_pos+1], card) and not G.jokers.cards[my_pos+1].getting_sliced then
                local sliced_card = G.jokers.cards[my_pos+1]
                sliced_card.getting_sliced = true
                G.GAME.joker_buffer = G.GAME.joker_buffer - 1
                local gain = (sliced_card.sell_cost or 0) * 0.5
                card.ability.extra.x_mult = card.ability.extra.x_mult + gain
                G.E_MANAGER:add_event(Event({func = function()
                    G.GAME.joker_buffer = 0
                    card:juice_up(0.8, 0.8)
                    sliced_card:start_dissolve({HEX("57ecab")}, nil, 1.6)
                    play_sound('slice1', 0.96+math.random()*0.08)
                    return true 
                end }))
                return {
                    message = localize{type='variable', key='a_xmult', vars={card.ability.extra.x_mult}},
                    colour = G.C.MULT,
                    card = card
                }
            end
        end

        -- 5. Apply XMult Mod
        if context.joker_main then
            if card.ability.extra.x_mult > 1 then
                return {
                    message = localize{type='variable', key='a_xmult', vars={card.ability.extra.x_mult}},
                    Xmult_mod = card.ability.extra.x_mult,
                    colour = G.C.MULT
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
