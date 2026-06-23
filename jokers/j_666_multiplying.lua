SMODS.Atlas {
    key = 'multiplying',
    path = "j_666_multiplying joker.png",
    px = 71,
    py = 95
}

SMODS.Joker {
    key = "multiplying",
    name = "Multiplying Joker",
    atlas = 'multiplying',
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
            round_counter = 0,
            rounds_required = 2,
            joker1 = "j_invisible",
            joker2 = "j_blueprint",
            joker3 = "j_brainstorm"
        }
    },
    loc_vars = function(self, info_queue, card)
        return {
            vars = {
                localize{type = 'name_text', key = card.ability.extra.joker1, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker2, set = 'Joker'},
                localize{type = 'name_text', key = card.ability.extra.joker3, set = 'Joker'},
                card.ability.extra.rounds_required,
                card.ability.extra.round_counter
            }
        }
    end,
    calculate = function(self, card, context)
        -- 1. Count rounds and clone leftmost joker
        if context.end_of_round and not context.blueprint and not context.individual and not context.repetition then
            card.ability.extra.round_counter = card.ability.extra.round_counter + 1
            if card.ability.extra.round_counter >= card.ability.extra.rounds_required then
                card.ability.extra.round_counter = 0
                -- Find leftmost joker that is not a Multiplying Joker
                local leftmost_joker = nil
                for i = 1, #G.jokers.cards do
                    local j = G.jokers.cards[i]
                    if j.config.center.key ~= 'j_666_multiplying' then
                        leftmost_joker = j
                        break
                    end
                end
                if leftmost_joker then
                    local copy = copy_card(leftmost_joker, nil, nil, nil, true)
                    copy:set_edition({negative = true}, true)
                    copy:add_to_deck()
                    G.jokers:emplace(copy)
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "Cloned!",
                        colour = G.C.DARK_EDITION
                    })
                end
            else
                card_eval_status_text(card, 'extra', nil, nil, nil, {
                    message = tostring(card.ability.extra.round_counter) .. "/" .. tostring(card.ability.extra.rounds_required),
                    colour = G.C.BLUE
                })
            end
        end

        -- 2. Copy ability of joker to the right (Blueprint logic) - Trigger 2 times!
        if not context.end_of_round then
            local my_pos = nil
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i] == card then my_pos = i; break end
            end
            if my_pos and G.jokers.cards[my_pos+1] then
                local other_joker = G.jokers.cards[my_pos+1]
                if other_joker.config.center.blueprint_compat ~= false and 
                   other_joker.config.center.key ~= 'j_blueprint' and 
                   other_joker.config.center.key ~= 'j_brainstorm' and 
                   other_joker.config.center.key ~= 'j_666_multiplying' then
                    
                    context.blueprint = true
                    context.blueprint_card = card
                    
                    local ret1 = other_joker:calculate_joker(context)
                    local ret2 = other_joker:calculate_joker(context)
                    
                    if ret1 or ret2 then
                        local res = {}
                        if ret1 then
                            for k, v in pairs(ret1) do res[k] = v end
                        end
                        if ret2 then
                            for k, v in pairs(ret2) do
                                if k == 'mult' then
                                    res.mult = (res.mult or 0) + v
                                elseif k == 'chips' then
                                    res.chips = (res.chips or 0) + v
                                elseif k == 'x_mult' then
                                    res.x_mult = (res.x_mult or 1) * v
                                elseif k == 'dollars' then
                                    res.dollars = (res.dollars or 0) + v
                                elseif k == 'repetitions' then
                                    res.repetitions = (res.repetitions or 0) + v
                                else
                                    res[k] = v
                                end
                            end
                        end
                        
                        if ret1 and ret2 and ret1.message and ret2.message then
                            res.message = ret1.message .. " x2"
                        end
                        
                        res.card = card
                        return res
                    end
                end
            end
        end
    end
}
