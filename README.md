# Flipping Jokers API

## About

**Flipping Jokers API** is a mod that allows modders to easily create jokers that flip every round.
Flipping jokers can have up to two unique abilities (one on each face).

## Installing the mod

- Requires [Steamodded 1.0.0-alpha](https://github.com/Steamopollys/Steamodded/archive/refs/heads/main.zip) and [Lovely](https://github.com/ethangreen-dev/lovely-injector)
- Download or git the files to the Mods folder (at %appdata%/Balatro/Mods)

## Getting started

> [!TIP]
> Don't hesitate to check `core.lua` if you have any trouble.

You can create a flipping joker by simply calling the <sub>function</sub> `FlippingJokers.new(args)`, with the `args` being:
- `args.name`: <sub>string</sub> name of the joker
- `args.key`: <sub>string</sub> key of the joker
- `args.config`: <sub>table</sub> you can override this to add more extra variables, 'flipped' will be set automatically — default:{extra = {flipped = false}}
- `args.loc_txt`: <sub>table</sub> additionnal description
- `args.front_description`: <sub>table</sub> description of the front face of the joker
- `args.back_description`: <sub>table</sub> description of the back face of the joker
- `args.rarity`: <sub>number</sub> rarity of the joker (1 = common, 2 = uncommon, 3 = rare, 4 = legendary)
- `args.cost`: <sub>number</sub> cost of the joker
- `args.unlocked`: <sub>boolean</sub> is the joker unlocked
- `args.discovered`: <sub>boolean</sub> is the joker discovered
- `args.blueprint_compat`: <sub>boolean</sub> is the joker compatible with blueprint
- `args.atlas`: <sub>string</sub> atlas of the joker (i.e. the key of the atlas) — default:'flipping_joker' implies the file must be named 'j_flipping_joker.png' and 'j_flipping_joker_flip.png'
- `args.spritesheet`: <sub>string</sub> key for your spritesheets — e.g. args.spritesheet = 'flipping_jokers' implies the files must be named 'j_flipping_jokers.png' and 'j_flipping_jokers_flip.png'
- `args.loc_vars`: <sub>function</sub> do not edit unless you know what you are doing. This function is used to set the description depending on the state of the joker.
- `args.set_ability`: <sub>function</sub> set the set_ability function of the joker
- `args.calculate`: <sub>function</sub> set the calculate function of the joker
- `args.tooltips`: <sub>table</sub> tooltips of the joker
- `args.default_tooltip`: <sub>boolean</sub> set to true to add the default tooltip to the joker
---
### Useful examples:
**Creating a single joker** and providing 2 images *(one per face)*
```lua
FlippingJokers.new({
  name = "Pancakes",
  key = "pancakes",
  config = { extra = { mult = 20, chips = 150 } },
  loc_txt = {name = "Pancakes", text = {}},
  rarity = 2,
  cost = 5,
  atlas = "pancakes",
  front_description = {text = '{C:chips}+#1#{} Chips', vars = {'chips'}},
  back_description = {text = '{C:mult}+#1#{} Mult', vars = {'mult'}},
  tooltips = {
      { key = 'pancakes_tooltip2', name = 'Delicious', text = {'I heard that', 'both sides are', 'wonderful'} }
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
```
---
**Creating multiple jokers** and providing 2 spritesheets *(one for all the faces, the other for all the backs)*
```lua
-- First joker
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

-- Second joker
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
                  mult_mod = card.ability.extra.Xmult,
                  colour = G.C.MULT
              }
          end
      end
  end
})
```
