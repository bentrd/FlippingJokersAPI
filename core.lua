--- STEAMODDED HEADER
--- MOD_NAME: Flipping Joker API
--- MOD_ID: FLIPPING_JOKER_API
--- MOD_AUTHOR: [Ben]
--- MOD_DESCRIPTION: An API for creating joker cards that flip every round
--- PRIORITY: -9999
----------------------------------------------
------------MOD CODE -------------------------

local example_jokers = false

FlippingJokers = {}
FlippingJokers.TO_PROCESS = {descriptions = {}, tooltips = {}}

--- Instantiate a new flipping joker card
--- @param args table
--- @param args.name string name of the joker — default:'Flipping Joker'
--- @param args.key string key of the joker — default:'flipping_joker'
--- @param args.config table you can override this to add more extra variables, 'flipped' will be set automatically — default:{extra = {flipped = false}}
--- @param args.loc_txt table additionnal description — default:{name = args.name, text = {"{s:0.7,C:inactive}This joker {s:0.7,C:attention}flips{s:0.7,C:inactive} every round{}"}}
--- @param args.front_description table description of the front face of the joker — default:{text = 'This joker {C:attention}flips{} every round', vars = {}}
--- @param args.back_description table description of the back face of the joker — default:{text = 'This joker {X:attention,C:white}flipped!', vars = {}}
--- @param args.rarity number rarity of the joker (1 = common, 2 = uncommon, 3 = rare, 4 = legendary) — default:2
--- @param args.cost number cost of the joker — default:6
--- @param args.unlocked boolean is the joker unlocked — default:true
--- @param args.discovered boolean is the joker discovered — default:true
--- @param args.blueprint_compat boolean is the joker compatible with blueprint — default:false
--- @param args.atlas string atlas of the joker (i.e. the key of the atlas) — default:'flipping_joker' implies the file must be named 'j_flipping_joker.png' and 'j_flipping_joker_flip.png'
--- @param args.loc_vars function do not edit unless you know what you are doing. This function is used to set the description depending on the state of the joker.
--- @param args.set_ability function set the set_ability function of the joker
--- @param args.calculate function set the calculate function of the joker
--- @param args.tooltips table tooltips of the joker — default:{ {key = 'flipping_card_tooltip', name = 'Flipping Card', text = {'This card has a', '{C:green,E:1,S:1.1}different ability', 'on each side'}} }
--- @param args.default_tooltip boolean set to true to add the default tooltip to the joker — default:true
--- @param args.spritesheet string key for your spritesheets — e.g. args.spritesheet = 'flipping_jokers' implies the files must be named 'j_flipping_jokers.png' and 'j_flipping_jokers_flip.png'
FlippingJokers.new = function (args)
    args = args or {}
    args.name = args.name or 'Flipping Joker'
    args.key = args.key or 'flipping_joker'
    local key = args.key
    args.config = args.config or { extra = {} }
    args.config.extra.flipped = args.config.extra.flipped or false
    args.pos = args.pos or { x = 0, y = 0 }
    local pos = {x = args.pos.x, y = args.pos.y}
    args.loc_txt = args.loc_txt or {name = args.name, text = {"{s:0.7,C:inactive}This joker {s:0.7,C:attention}flips{s:0.7,C:inactive} every round{}"}} -- whatever you set here will be added after the front and back descriptions
    args.front_description = args.front_description or {text = 'This joker {C:attention}flips{} every round', vars = {}} -- use \n for new lines, #1#, #2#, #3#... for variables
    for i = 1, #args.front_description.vars do
        if type(args.front_description.vars[i]) == 'string' and args.config.extra[args.front_description.vars[i]] then
            args.front_description.vars[i] = args.config.extra[args.front_description.vars[i]]
        end
    end
    args.back_description = args.back_description or {text = 'This joker {X:attention,C:white}flipped!', vars = {}}
    for i = 1, #args.back_description.vars do
        if type(args.back_description.vars[i]) == 'string' and args.config.extra[args.back_description.vars[i]] then
            args.back_description.vars[i] = args.config.extra[args.back_description.vars[i]]
        end
    end
    args.rarity = args.rarity or 2
    args.cost = args.cost or 6
    args.unlocked = args.unlocked or true
    args.discovered = args.discovered or true
    args.blueprint_compat = args.blueprint_compat or false -- make sure to handle blueprint compatibility in the calculate function
    args.atlas = args.atlas or 'flipping_joker'
    local atlas = args.atlas
    args.tooltips = args.tooltips or {}
    local default_tooltip = { key = 'flipping_card_tooltip', name = 'Flipping Card', text = {'This card has a', '{C:green,E:2,S:1.1}different ability', 'on each side'} }
    if args.default_tooltip == nil then args.default_tooltip = true end
    if args.default_tooltip then table.insert(args.tooltips, 1, default_tooltip) end
    args.loc_vars = function(self, info_queue, center)
        if args.tooltips then for _, v in pairs(args.tooltips) do info_queue[#info_queue + 1] = { key = v.key, set = 'Other' } end end
        if not center.ability.extra.flipped then return { main_start = localize{type = 'text', key = key..'_front_description', vars = args.front_description.vars} }
        else return { main_start = localize{type = 'text', key = key..'_back_description', vars = args.back_description.vars} } end
    end
    local set_ability_extra = args.set_ability
    args.set_ability = function(self, card, context)
        if set_ability_extra then
            set_ability_extra(self, card, context)
        end
    end
    local calculate_extra = args.calculate
    args.calculate = function(self, card, context)
        local atlas_key = SMODS.current_mod.prefix..'_'..atlas..'_flip'
        if not card.ability.is_flipping_card then
            card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[atlas_key], pos)
            card.children.back.states.hover = card.states.hover
            card.children.back.states.click = card.states.click
            card.children.back.states.drag = card.states.drag
            card.children.back.states.collide.can = false
            card.children.back:set_role({ major = card, role_type = 'Glued', draw_major = card })
            card.ability.is_flipping_card = true
        end
        if context.end_of_round and not context.individual and not context.repetition and not context.blueprint then
            card.ability.extra.flipped = not card.ability.extra.flipped
            card:flip()
        end
        if calculate_extra then
            return calculate_extra(self, card, context)
        end
    end

    table.insert(FlippingJokers.TO_PROCESS.descriptions, { key = args.key..'_front_description', text = args.front_description.text })
    table.insert(FlippingJokers.TO_PROCESS.descriptions, { key = args.key..'_back_description', text = args.back_description.text })
    for _, v in ipairs(args.tooltips) do
        table.insert(FlippingJokers.TO_PROCESS.tooltips, { key = v.key, name = v.name, text = v.text})
    end

    atlas = args.spritesheet or atlas -- if spritesheet is set, it will try to register the atlas every time the 'new' function is called, but steamodded will just send a warning and ignore it :)
    SMODS['Atlas']({
        key = atlas,
        path = 'j_'..atlas..'.png',
        px = 71,
        py = 95
    })
    SMODS['Atlas']({
        key = atlas..'_flip',
        path = 'j_'..atlas..'_flip.png',
        px = 71,
        py = 95
    })
    SMODS['Joker'](args)
end

function SMODS.current_mod.process_loc_text()
    for _, v in ipairs(FlippingJokers.TO_PROCESS.descriptions) do
        G.localization.misc.v_text[v.key] = {v.text}
    end
    for _, v in ipairs(FlippingJokers.TO_PROCESS.tooltips) do
        G.localization.descriptions.Other[v.key] = {name = v.name, text = v.text}
    end
end

if example_jokers then
    local rainbow_text = function (text)
        local rainbow = {'tarot', 'purple', 'red', 'attention', 'gold', 'money', 'green', 'planet', 'chips', 'spectral' }
        local rainbow_text = ''
        for i = 1, #text do
            rainbow_text = rainbow_text..'{X:'..rainbow[i % #rainbow + 1]..',C:white,s:1.5}'..text:sub(i, i)
        end
        return rainbow_text
    end

    FlippingJokers.new({
        name = "Pancakes 1",
        key = "pancakes_1",
        config = { extra = { mult = 20, chips = 150 } },
        loc_txt = {name = "Pancakes", text = {}},
        rarity = 2,
        cost = 5,
        atlas = "pancakes",
        spritesheet = "pancakes",
        front_description = {text = '{C:chips}+#1#{} Chips', vars = {'chips'}},
        back_description = {text = '{C:mult}+#1#{} Mult', vars = {'mult'}},
        tooltips = {
            { key = 'pancakes_tooltip2', name = 'Delicious', text = {'I heard that', 'both sides are', rainbow_text('wonderful')} }
        },
        calculate = function(self, card, context)
            if context.cardarea == G.jokers and not context.repetition and not context.individual and not context.before and not context.after then
                if card.ability.extra.flipped then
                    return {
                        message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } },
                        mult_mod = card.ability.extra.mult,
                        colour = G.C.MULT
                    }
                else
                    return {
                        message = localize { type = 'variable', key = 'a_chips', vars = { card.ability.extra.chips } },
                        chip_mod = card.ability.extra.chips,
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    })

    FlippingJokers.new({
        name = "Pancakes 2",
        key = "pancakes_2",
        config = { extra = { Xmult = 4 } },
        loc_txt = {name = "Pancakes", text = {}},
        rarity = 2,
        cost = 5,
        atlas = "pancakes",
        spritesheet = "pancakes",
        pos = {x = 1, y = 0},
        front_description = {text = 'Does absolutely nothing.', vars = {}},
        back_description = {text = '{X:mult,C:white}X#1#{} Mult', vars = {'Xmult'}},
        calculate = function(self, card, context)
            if context.cardarea == G.jokers and not context.repetition and not context.individual and not context.before and not context.after then
                if card.ability.extra.flipped then
                    return {
                        message = localize{type = 'variable', key = 'a_Xmult', vars = { card.ability.extra.Xmult }},
                        Xmult_mod = card.ability.extra.Xmult,
                        colour = G.C.MULT
                    }
                end
            end
        end
    })
end

----------------------------------------------
------------MOD CODE END----------------------