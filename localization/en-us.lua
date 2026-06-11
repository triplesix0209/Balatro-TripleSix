return {
	["misc"] = {
		["dictionary"] = {
            ["k_fusion"] = "Fusion",
			["k_fuse_fusion"] = "Fusion",
            ["k_flipped_ex"] = "Flipped!",
            ["k_copied_ex"] = "Cloned!",
            ["k_in_tact_ex"] = "In-Tact!",
            ["b_fuse"] = "FUSE",
		},
		["labels"] = {
			["k_fuse_fusion"] = "Fusion",
		},
	},
	["descriptions"] = {
		["Joker"] = {
			["j_fuse_diamond_bard"] = {
				["name"] = "Diamond Bard",
				["text"] = {
                    "{C:purple}(#4# + #5#){}",
                    "Played cards with {C:diamonds}Diamond{} suit give",
                    "{C:money}$#1#{}, as well as {C:mult}+#2#{} Mult for every ",
                    "{C:money}$#3#{} you have when scored",
				},
			},
			["j_fuse_heart_paladin"] = {
				["name"] = "Heart Paladin",
				["text"] = {
                    "{C:purple}(#4# + #5#){}",
                    "Played cards with {C:hearts}Heart{} suit give",
                    "{X:mult,C:white}X#1#{} Mult when scored.",
                    "{C:green}#2# in #3#{} chance to re-trigger",
				},
			},
			["j_fuse_spade_archer"] = {
				["name"] = "Spade Archer",
				["text"] = {
                    "{C:purple}(#3# + #4#){}",
                    "Played cards with {C:spades}Spade{} suit give",
                    "{C:chips}+#1#{} Chips when scored. Gains {C:chips}+#2#{} ",
                    "chips when 5 or more {C:spades}Spades{} are played",
				},
			},
			["j_fuse_club_wizard"] = {
				["name"] = "Club Wizard",
				["text"] = {
                    "{C:purple}(#2# + #3#){}",
                    "Played cards with {C:clubs}Club{} suit",
                    "give {C:mult}+#1#{} Mult when scored",
				},
			},
			["j_fuse_big_bang"] = {
				["name"] = "Big Bang",
				["text"] = {
                    "{C:purple}(#2# + #3# + #4#){}",
                    "{X:mult,C:white} X#1# {} Mult per the number of times {C:attention}poker hand{} has been played",
                    "plus the level of the {C:attention}poker hand{}.",
                    "{C:green}#5# in #6#{} chance to upgrade level of played {C:attention}poker hand{}",
				},
			},
			["j_fuse_dynamic_duo"] = {
				["name"] = "Dynamic Duo",
				["text"] = {
                    "{C:purple}(#3# + #4#){}",
                    "Played {C:attention}number{} cards give {C:mult}+#1#{} Mult ",
                    "and {C:chips}+#2#{} Chips when scored.",
				},
			},
			["j_fuse_collectible_chaos_card"] = {
				["name"] = "Collectible Chaos Card",
				["text"] = {
                    "{C:purple}(#4# + #5#){}",
                    "{C:mult}+#1#{} Mult per {C:attention}reroll{} in the shop.",
                    "{C:attention}#2#{} free {C:green}Reroll{} per shop",
                    "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)",
				},
			},
			["j_fuse_flip_flop"] = {
				["name"] = "Flip-Flop",
				["text"] = {
                    "{C:purple}(#3# + #4#){}",
                    "{C:attention}+#1#{} hand size. {C:red}+#2#{} Mult",
                    "{C:attention}Flips{} after each blind",
				},
			},
			["j_fuse_flip_flop_mult"] = {
				["name"] = "Flip-Flop",
				["text"] = {
                    "{C:purple}(#3# + #4#){}",
                    "{C:attention}+#1#{} hand size. {C:red}+#2#{} Mult",
                    "{C:attention}Flips{} after each blind",
				},
			},
			["j_fuse_flip_flop_chips"] = {
				["name"] = "Flip-Flop",
				["text"] = {
                    "{C:purple}(#3# + #4#){}",
                    "{C:red}+#1#{} discard. {C:chips}+#2#{} Chips",
                    "{C:attention}Flips{} after each blind",
				},
			},
			["j_fuse_royal_decree"] = {
				["name"] = "Royal Decree",
				["text"] = {
                    "{C:purple}(#2# + #3#){}",
                    "Played {C:attention}face{} cards give {C:money}$#1#{} when scored.",
                    "Each {C:attention}face{} card held in hand",
                    "at end of round gives {C:money}$#1#{}",
				},
			},
			["j_fuse_dementia_joker"] = {
				["name"] = "Dementia Joker",
				["text"] = {
                    "{C:purple}(#5# + #6#){}",
                    "{C:mult}+#1#{} Mult for each {C:attention}Joker{} card.",
                    "{C:green}#2# in #3#{} chance to {C:attention}clone{} if ",
                    "not {C:dark_edition}Negative{} after you beat a blind",
                    "{C:inactive}(Currently {C:mult}+#4#{C:inactive} Mult)",
				},
			},
			["j_fuse_golden_egg"] = {
				["name"] = "Golden Egg",
				["text"] = {
                    "{C:purple}(#2# + #3#){}",
                    "Gains {C:money}$#1#{} of {C:attention}sell value{}",
                    " at end of round.",
                    " Earn {C:money}$#1#{} at end of round",
				},
			},
			["j_fuse_flag_bearer"] = {
				["name"] = "Flag Bearer",
				["text"] = {
                    "{C:purple}(#4# + #5#){}",
                    "{C:mult}+#1#{} Mult per hand played, {C:mult}-#2#{} Mult",
                    "per discard. Mult is multiplied by",
                    " remaining {C:attention}discards{}",
                    "{C:inactive}(Currently {C:mult}+#3#{C:inactive} Mult)",
				},
			},
			["j_fuse_uncanny_face"] = {
				["name"] = "Uncanny Face",
				["text"] = {
                    "{C:purple}(#3# + #4# + #5#){}",
					"Retrigger all played {C:attention}face{} cards.",
					"Played {C:attention}face{} cards give {C:chips}+#1#{} Chips and {C:mult}+#2#{} Mult",
                    "for every {C:attention}face{} card in the scoring hand.",
				},
			},
			["j_fuse_commercial_driver"] = {
				["name"] = "Commercial Driver",
				["text"] = {
                    "{C:purple}(#3# + #4#){}",
                    "{X:mult,C:white} X#1# {} Mult per consecutive hand",
                    "played with a scoring {C:attention}enhanced{} card",
                    "{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} Mult)",
				},
			},
			["j_fuse_camping_trip"] = {
				["name"] = "Camping Trip",
				["text"] = {
                    "{C:purple}(#3# + #4# + #5#){}",
					"Every {C:attention}played card{} is scored.",
                    "Played {C:attention}cards{} permanently gain",
                    "{C:chips}+#1#{} Chips when scored",
                    "({C:chips}+#2#{} on the {C:attention}final hand{}).",
                    "Retrigger all played cards on {C:attention}final hand{}.",
				},
			},
			["j_fuse_capitalist_taurus"] = {
				["name"] = "Capitalist Taurus",
				["text"] = {
                    "{C:purple}(#6# + #7#){}",
                    "{C:chips}+#1#{} Chips for each {C:money}$1{} you have.",
                    "{C:mult}+#2#{} Mult for every {C:money}$#3#{} you have.",
                    "{C:inactive}(Currently {C:chips}+#4#{C:inactive} Chips, {C:mult}+#5#{C:inactive} Mult)",
				},
			},
			["j_fuse_artemis_launch"] = {
				["name"] = "Artemis Launch",
				["text"] = {
                    "{C:purple}(#4# + #5#){}",
                    "Earn an extra {C:money}$#1#{} of {C:attention}interest{} for every {C:money}$#2#{} you have at end of round.",
                    "When {C:attention}Boss Blind{} is defeated, permanently increases this extra {C:attention}interest{} by {C:money}$#3#{}",
				},
			},
			["j_fuse_murphy_law"] = {
				["name"] = "Murphy's Law",
				["text"] = {
                    "{C:purple}(#1# + #2# + #3#){}",
                    "All listed {C:green}probabilities{} always trigger",
				},
			},
			["j_fuse_perkeo_sobriety"] = {
				["name"] = "Perkeo's Sobriety",
				["text"] = {
                    "{C:purple}(#2# + #3# + #4#){}",
                    "Gain {C:red}+1{} discard for every",
                    "{C:attention}consumable{} card in your possession",
                    "{C:inactive}(Currently {C:red}+#1#{C:inactive})",
                    "When playing a hand, retrigger all played cards",
                    "by destroying a random {C:attention}consumable{} card",
                    "Creates a {C:dark_edition}Negative{} copy of {C:attention}1{} random",
                    "{C:attention}consumable{} card in your possession at the end of the shop",
				},
			},
			["j_fuse_canio_madness"] = {
				["name"] = "Canio's Madness",
				["text"] = {
                    "{C:purple}(#2# + #3# + #4#){}",
                    "When {C:attention}Blind{} is selected, destroy the {C:attention}Joker{} to the right.",
                    "When a card is destroyed, permanently add {X:mult,C:white}X1{} Mult to its {X:mult,C:white}X{} Mult,",
                    "if the destroyed card is a {C:attention}Joker{} or a {C:attention}face{} card, add its sell value instead.",
                    "{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)",
				},
			},
		},
	},
}