function get_config_tab_fusions()
    return {
        {n = G.UIT.C, config = {minw=1, minh=1, align = "tl", colour = G.C.CLEAR, padding = 0.15}, nodes = {
        create_toggle({
            label = "Block used materials from reappearing",
            ref_table = FusionJokers.fusionconfig,
            ref_value = 'block_materials',
        }),
        create_toggle({
            label = "No price flickering",
            ref_table = FusionJokers.fusionconfig,
            ref_value = 'no_price_flicker',
        }),
        }}
    }
end

function get_config_tab_thanks()
    return {
        {n = G.UIT.C, config = {minw=8, minh=5, align = "cm", colour = G.C.CLEAR, padding = 0.2}, nodes = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = "Credits & Acknowledgments", scale = 0.55, colour = G.C.GOLD, shadow = true}}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = "Fusion Jokers", scale = 0.45, colour = G.C.WHITE}},
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                {n = G.UIT.T, config = {text = "by wingedcatgirl", scale = 0.35, colour = G.C.UI.TEXT_LIGHT}}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.15}},
            {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = "HandyBalatro", scale = 0.45, colour = G.C.WHITE}},
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                {n = G.UIT.T, config = {text = "by SleepyG11", scale = 0.35, colour = G.C.UI.TEXT_LIGHT}}
            }}
        }}
    }
end

SMODS.current_mod.config_tab = function()
    return {n = G.UIT.ROOT, config = {r = 0.1, minw = 8, minh = 6, align = "tl", padding = 0.2, colour = G.C.BLACK}, nodes = get_config_tab_fusions()}
end