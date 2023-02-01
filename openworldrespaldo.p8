pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--main loop
--------------------------------------------------------------------
debug = true
outside={}
outside.x, outside.y = 0,0
outside.w, outside.h = 17,15
outside.bg = 1
spawnx = 16
spawny = 16

shop = {}
shop.x, shop.y = 18,0
shop.w, shop.h = 10,7
shop.bg = 1

currentroom = outside
function setcurrentroom(room, entity,_x, _y)
	currentroom = room
	entity.position.setposition(_x,_y)
	cutscene.advance()
end
function moveroom(room, entity, _x, _y)
	cutscene.scene = {
			{curtain.set, "down"},
			{cutscene.wait, 20},
			{setcurrentroom, room, entity, _x, _y},
			{curtain.set, "up"},
			{cutscene.wait, 10}
			}
end
function moveentity(self, other, room, _x,_y)
	if other == player then
		moveroom(outside, other, _x, _y)
	end
end 


function _init()
	--create a player entity	
	player = newentity({
		position = newposition(16,16,14,8),
		sprite = newsprite({standright = {images = {{8,0}}, flip = false},
							moveright  = {images = {{8,0},{22,0},{8,0},{36,0}}, flip = false},
							standleft  = {images = {{8,0}}, flip = true},
							moveleft   = {images = {{8,0},{22,0},{8,0},{36,0}}, flip = true},
							hitright   = {images = {{50,0},{64,0},{78,0},{8,0}}, flip = false},
							hitleft    = {images = {{50,0},{64,0},{78,0},{8,0}}, flip = true}
							}),
		controller = newcontroller(0,1,2,3,4,5,playerinput),
		intention = newintention(),
		bounds = newbounds(4,4,6,4),
		animation = newanimation({moveright=true, moveleft = true, standright = true, standleft = true, hitright = true, hitleft = true}),
		dialogue = newdialogue(),
		state = newstate("standright", {moveright  = function() return (player.intention.right or ((player.intention.up or player.intention.down) and (player.state.current == "standright" or (player.state.current == "hitright")))) end,
										moveleft   = function() return (player.intention.left or ((player.intention.up or player.intention.down) and (player.state.current == "standleft" or (player.state.current == "hitleft")))) end,
										standright = function() return (not (player.intention.right or player.intention.up or player.intention.down) and player.state.current == "moveright") or (player.state.current == "hitright" and player.sprite.index > 3) end,
										standleft  = function() return (not (player.intention.left or player.intention.up or player.intention.down) and player.state.current == "moveleft")   or (player.state.current == "hitleft"  and player.sprite.index > 3) end,
										hitright   = function() return (player.state.current == "standright" or player.state.current == "moveright") and (player.intention.o and not player.intention.x) and not (player.intention.right or player.intention.up or player.intention.down) end,
										hitleft    = function() return (player.state.current == "standleft"  or player.state.current == "moveleft" ) and (player.intention.o and not player.intention.x) and not (player.intention.left or player.intention.up or player.intention.down)  end}),
		inventory = newinventory(3, true, 128, 112,{}),
		battle = newbattle({ hitright = {xoff =  11, yoff = 0, w=3, h=8},
							 hitleft  = {xoff = 0, yoff = 0, w=3, h=8}},
							{
								standright = {xoff = 3, yoff = 0, w=8, h=8},
								standleft = {xoff = 3, yoff = 0, w=8, h=8},
								moveright = {xoff = 3, yoff = 0, w=8, h=8},
								moveleft = {xoff = 3, yoff = 0, w=8, h=8},
								hitright = {xoff = 3, yoff = 0, w=8, h=8},
								hitleft = {xoff = 3, yoff = 0, w=8, h=8}
							}, 6, 1, 1, true)
		})

	add(entities,player)

	-- create enemy
	add(entities,
		newentity({
		position = newposition(16,64,8,8),
		sprite = newsprite({idle = {images = {{0,64}}, flip = false}}),
		intention = newintention(),
		bounds = newbounds(0,3,8,5),
		battle = newbattle({idle = {xoff=0, yoff=2, w=8, h=6}},{idle = {xoff=0, yoff=2, w=8, h=6} }, 3, 1, 0.5,true),
		ai = newai(10,48,80)
		})
	)

	--create a tree entity
	add(entities,
		newentity({
		position = newposition(64,48,16,16),
		sprite = newsprite({idle = {images = {{8,8}}, flip = false}}),
		bounds = newbounds(5,12,6,4),
		trigger = newtrigger(4,10,8,8,
			function(self, other)
				if other == player then
					--cutscene
					cutscene.scene = {
						{other.dialogue.set, "oh look, a tree", true},
						{cutscene.wait, 100},
						{other.dialogue.set, "how beautiful", true},
						{cutscene.wait, 100}

					}
				end
			end, "wait"),
		inventory = newinventory(1,false,0,0,{{id = "apple", num = 1}}),
		intention = newintention(),
		battle = newbattle({},{idle = {xoff=0, yoff=0, w=16, h=16} }, 4, 0, 0, false)
		})
	)
	-- create an apple entity
	add(entities, newitem("apple", 48, 80))
	add(entities, newitem("apple", 52, 80))
	add(entities, newitem("apple", 56, 80))
	add(entities, newitem("apple", 60, 80))
	-- create items entity
	add(entities, newitem("hearth", 120, 30))
	add(entities, newitem("sword", 48, 12))
	add(entities, newitem("corralkey", 16, 12))


	--create a shop entity
	add(entities,
		newentity({
		position = newposition(88,16,16,16),
		sprite = newsprite({idle = {images = {{40,8}}, flip = false}}),
		bounds = newbounds(2,10,12,6),
		trigger = newtrigger(5,16,6,3,
			function(self, other) 
				if other == player then
					moveroom(shop, other, 200, 40)
				end
			end, "wait")
		})
	)	

	--create a shop door trigger
	add(entities,
		newentity({
		position = newposition(200,48,8,8),
		sprite = newsprite({idle = {images = {{0,16}}, flip = false}}),
		bounds = newbounds(0,4,8,4),
		trigger = newtrigger(0,0,8,4,
			function(self, other)
				if other == player then
					moveroom(outside, other, 92,32)
				end
			end, "wait")
		})
	)

	--create a locked door trigger
		add(entities,
		newentity({
		position = newposition(96,80,8,8),
		sprite = newsprite({idle = {images = {{56,32}}, flip = false}}),
		bounds = newbounds(0,4,8,4),
		lock = newlock(0,0,8,10,"corralkey")
		})
	)

	-- initial gamestate
	statemanager.current = titlestate
end

function _update()
	statemanager.update()
end

function _draw()
	statemanager.draw()
end

-->8
--entities
--------------------------------------------------------------------

entities = {}

--creates and returns a new position
function newposition(_x,_y,_w,_h)
	local p = {}
	p.x = _x
	p.y = _y
	p.w = _w
	p.h = _h
	p.sx = _x
	p.sy = _y
	p.setposition = function(_x2, _y2)
		p.x = _x2
		p.y = _y2
	end
	return p
end

--creattes and returns a new sprite
function newsprite(_sp)
	local s ={}
	s.spritelist = _sp
	s.index = 1
	--s.flip = false
	return s
end

function newanimation(_list)
	local a ={}
	a.timer = 0
	a.delay = 3
	a.list = _list
	return a
end

--creates and returns a new collider
function newbounds(_xoff, _yoff, _w, _h)
	local b = {}
	b.xoff = _xoff
	b.yoff = _yoff
	b.w = _w
	b.h = _h
	return b 
end

--creates and returns a new statemachine
function newstate(initialstate, _rules)
	local s = {}
	s.current = initialstate
	s.previous = initialstate
	s.rules = _rules
	return s
end

--creates and returns a new trigger
function newtrigger(_xoff, _yoff, _w, _h, _f, _type)
	local t = {}
	t.xoff = _xoff
	t.yoff = _yoff
	t.w = _w
	t.h = _h
	t.funct = _f
	--type "once", "always" and "wait"
	t.type = _type
	t.active = false
	return t
end

function newlock(_xoff, _yoff, _w, _h, _key)
	local l = {}
	l.xoff = _xoff
	l.yoff = _yoff
	l.w = _w
	l.h = _h
	-- item that opens lock
	l.key = _key
	l.active = false
	return l
end

--creates and returns a new controller
function newcontroller(_left, _right, _up, _down, _o, _x, _input)
	local c ={}
	c.left = _left
	c.right = _right
	c.up = _up
	c.down = _down
	c.o = _o
	c.x = _x
	c.input = _input
	return c
end

function newintention()
	local i = {}
	i.left =false
	i.right = false
	i.up = false
	i.down = false
	i.o = false
	i.x = false
	i.moving = false
	return i
end

function newai(_movetimer, _range, _follow)
	local a ={}
	a.maxtimer = _movetimer
	a.timer = _movetimer
	a.direction = 0
	a.range = _range
	a.follow = _follow
	a.back = false
	return a
end

-- Hitboxes
function newbattle(_hitboxes, _hurtboxes, _health, _damage, _speed,_kinetic)
	local b = {}
	b.hitboxes = _hitboxes
	b.hurtboxes = _hurtboxes
	b.health = _health
	b.maxhealth = _health
	b.damage = _damage
	b.kinetic = _kinetic
	b.hit = 0
	b.dir = nil
	b.speed = _speed
	return b
end 

--creates and returns a new dialogue
function newdialogue()
	local d = {}
	d.text = {nil}
	d.timed =false
	d.timeremaining = 0
	d.cursor = 0
	d.set = function(_text, _timed)
		if #_text > 15 then
			local splitpos, spacefound = 15, false
			while splitpos <#_text and spacefound == false do 
				if sub(_text, splitpos,splitpos) == " " then
					spacefound = true
				end
				splitpos+=1
			end

			d.text[0] = sub(_text,0,splitpos-1)
			d.text[1] = sub(_text,splitpos,#_text)
		else
			d.text[0] = _text
			d.text[1] = nil
		end
		d.timed = _timed
		d.cursor = 0
		if d.timed then d.timeremaining = 90 end
		cutscene.advance()
	end
	return d
end

-- creates and returns a new inventory
function newinventory(_size, _visible, _x, _y, _items)
	local i = {}
	i.size = _size
	i.visible = _visible
	i.x = (_x-(_size*9+1))/2
	i.y = _y
	i.items = _items
	i.selected = 1
	return i
end


--creates and returns a new entity
function newentity(componenttable)
	local e = {}
	e.position = componenttable.position or nil
	e.sprite   = componenttable.sprite or nil
	e.controller = componenttable.controller or nil
	e.intention = componenttable.intention or nil
	e.bounds = componenttable.bounds or nil
	e.animation = componenttable.animation or nil
	e.trigger = componenttable.trigger or nil
	e.lock = componenttable.lock or nil
	e.dialogue = componenttable.dialogue or nil
	e.state = componenttable.state or {current = "idle"}
	e.inventory = componenttable.inventory or nil
	e.item = componenttable.item or false
	e.battle = componenttable.battle or nil
	e.ai = componenttable.ai or nil
	e.gamestate = "playing"
	return e
end

function playerinput(ent)

	if #cutscene.scene > 0 then
		ent.intention.left, ent.intention.right, ent.intention.up, ent.intention.down, ent.intention.o, ent.intention.x, ent.intention.moving =
		false, false, false, false, false, false, false
	else
		if ent.gamestate then
			if ent.gamestate == "playing" then
				ent.intention.left = btn(ent.controller.left)
				ent.intention.right = btn(ent.controller.right)
				ent.intention.up = btn(ent.controller.up)
				ent.intention.down = btn(ent.controller.down)
				ent.intention.o = btnp(ent.controller.o)
				ent.intention.x = btnp(ent.controller.x)
			elseif ent.gamestate == "inventory" then
				ent.intention.left = btnp(ent.controller.left)
				ent.intention.right = btnp(ent.controller.right)
				ent.intention.up = btnp(ent.controller.up)
				ent.intention.down = btnp(ent.controller.down)
				ent.intention.o = btnp(ent.controller.o)
				ent.intention.x = btnp(ent.controller.x)
			end
		end
	end
end

-- checks if player can walk on tile
function canwalk(x,y)
	return not fget(mget(x/8, y/8), 7)
end

--checks if two entities are touching
function touching(x1, y1, w1, h1, x2, y2, w2, h2)
	return 
		x1 + w1 > x2 and 
		x1 < x2 + w2 and
		y1 + h1 > y2 and
		y1 < y2 + h2
end

--sorts a list
function sort(list, comparison)
	for i = 1, #list do 
		local j = i
		while j > 1 and comparison(list[j-1], list[j]) do
			list[j], list[j-1] = list[j-1], list[j]
			j-=1
		end
	end
end

--compare entitites on y axis for drawing
function ycomparison(a,b)
	if a.position == nil or b.position == nil then return false end
	return a.position.y + a.position.h > b.position.y + b.position.h
end

--outline text
function printoutline(t,x,y,c)
  -- draw the outline
  for xoff=-1,1 do
    for yoff=-1,1 do
      print(t,x+xoff,y+yoff,1)
    end
  end
  --draw the text
  print(t,x,y,c)
end

function cprint(t,y,c)
	local x = (128 - (#t * 4)-1)/2
	print (t,x,y,c)
end

function dist(x,y,x2,y2)
 --gets the distance between
 --two points
 local dx, dy = x - x2, y - y2
 local res=flr(sqrt((dx^2 + dy^2)))
 if res<0 then
  res=0
 end
 return res
end

-->8
--items

-- --create an apple item
-- function newapple(_x, _y)
-- 	-- creatres an apple entity
-- 	return
-- 		newentity({
-- 		position = newposition(_x, _y, 8, 8),
-- 		sprite = newsprite({idle = {images = {{0,24}}, flip = false}}),
-- 		item = "apple"
-- 		})
	
-- end

function newitem(_id, _x, _y)
	-- creatres an item
	local i = itemdatabase[_id]
	return
		newentity({
		position = newposition(_x, _y, i.position.w, i.position.h),
		sprite = newsprite(i.sprite),
		item = _id
		})
	
end

function usekey(_id)
	for o in all(entities) do
		if o.lock and o.lock.active then
			if _id == o.lock.key then
				del(entities, o)
				return true
			else
				return false
			end  
		end
	end
	return false
end

function heal1(_ent)
	if _ent.battle and (_ent.battle.health < _ent.battle.maxhealth) then
		_ent.battle.health += 1
		if _ent.battle.health > _ent.battle.maxhealth then
			_ent.battle.health = _ent.battle.maxhealth
		end
		return true
	else 
		return false
	end
end

function hpup(_ent)
	if _ent.battle.maxhealth then
		_ent.battle.maxhealth += 2
		_ent.battle.health = _ent.battle.maxhealth
		return true
	else 
		return false
	end
end

function atkup(_ent)
	if _ent.battle.damage then
		_ent.battle.damage += 1
		return true
	else 
		return false
	end
end

--item database
itemdatabase = {}
itemdatabase.apple = {
	maxstack = 3,
	position = {w=8, h=8},
	sprite = {idle = {images = {{0,24}}, flip = false}},
	newfunction = newitem,
	usefunction = heal1
}
itemdatabase.hearth = {
	maxstack = 1,
	position = {w=8, h=8},
	sprite = {idle = {images = {{16,24}}, flip = false}},
	newfunction = newitem,
	usefunction = hpup
}
itemdatabase.sword = {
	maxstack = 1,
	position = {w=8, h=8},
	sprite = {idle = {images = {{40,24}}, flip = false}},
	newfunction = newitem,
	usefunction = atkup
}
itemdatabase.corralkey = {
	maxstack = 1,
	position = {w=8, h=8},
	sprite = {idle = {images = {{48,24}}, flip = false}},
	newfunction = newitem,
	usefunction = usekey
}



-->8
--systems
--------------------------------------------------------------------
controlsystem = {}
controlsystem.update = function()
	for ent in all(entities) do 
		if ent.controller != nil and ent.intention != nil then
			ent.controller.input(ent)
		end
	end
end

physicsystem = {}
physicsystem.update = function ()
	for ent in all(entities) do 
		if ent.gamestate and ent.gamestate == "playing" then
			if ent.bounds and ent.position then
				local newx, newy = ent.position.x, ent.position.y
				
				if ent.position != nil and ent.intention != nil and ent.battle then
					if ent.intention.up then newy -= 1 * ent.battle.speed end 
					if ent.intention.down then newy += 1 * ent.battle.speed end
					
					-- move on hit
					if ent.battle and ent.battle.hit >0 then
				 		if ent.battle.kinetic then
							newx +=2 * ent.battle.dir
						end

						ent.battle.hit -= 1
					else
						if ent.intention.left then newx -= 1 * ent.battle.speed end
						if ent.intention.right then newx += 1 * ent.battle.speed end
					end
				end


				local canmovex, canmovey = true, true

				local boundx, boundy = ent.position.x + ent.bounds.xoff, ent.position.y + ent.bounds.yoff
				local newboundx, newboundy = newx + ent.bounds.xoff, newy + ent.bounds.yoff
				--
				--map collision
				--

				--update x position if allowed to move
				if not (canwalk(newboundx, boundy) and
		   			canwalk(newboundx, boundy + ent.bounds.h-1) and 
		   			canwalk(newboundx + ent.bounds.w-1, boundy) and
		   			canwalk(newboundx + ent.bounds.w-1, boundy + ent.bounds.h-1)) then
			
					canmovex = false
				end

				--update y position if allowed to move
				if not (canwalk(boundx, newboundy) and 
		   			canwalk(boundx, newboundy + ent.bounds.h-1) and 
		   			canwalk(boundx + ent.bounds.w-1, newboundy) and
		   			canwalk(boundx + ent.bounds.w-1, newboundy + ent.bounds.h-1)) then

					canmovey = false
				end

				--
				--entity collision
				--

				for o in all(entities) do 
					if o != ent and o.position and o.bounds then
					--check x
						if touching(newboundx, boundy, ent.bounds.w, ent.bounds.h,
								o.position.x+o.bounds.xoff, o.position.y+o.bounds.yoff, o.bounds.w, o.bounds.h) then
							canmovex = false
						end

					--check y
						if touching(boundx, newboundy, ent.bounds.w, ent.bounds.h,
									o.position.x+o.bounds.xoff, o.position.y+o.bounds.yoff, o.bounds.w, o.bounds.h) then
							canmovey = false
						end
					end
				end

				if canmovex then ent.position.x = newx end
				if canmovey then ent.position.y = newy end
			end
		end
	end
end

locksystem={}
locksystem.update = function ()
	for ent in all(entities) do	
		if ent.lock and ent.position then
			local triggered = false
			for o in all(entities) do 
				if ent != o and o.bounds and o.position then
					
					if touching(ent.position.x + ent.lock.xoff, ent.position.y + ent.lock.yoff, ent.lock.w, ent.lock.h,
							o.position.x+o.bounds.xoff, o.position.y+o.bounds.yoff, o.bounds.w, o.bounds.h) then
						
						-- trigger is activated
						triggered = true
						ent.lock.active = true
					end 
				end
			end 
			if not triggered then
				ent.lock.active = false
			end
		end 
	end
end

triggersystem = {}
triggersystem.update = function()
	for ent in all(entities) do	
		if ent.trigger and ent.position then
			local triggered = false
			for o in all(entities) do 
				if ent != o and o.bounds and o.position then
					
					if touching(ent.position.x + ent.trigger.xoff, ent.position.y + ent.trigger.yoff, ent.trigger.w, ent.trigger.h,
							o.position.x+o.bounds.xoff, o.position.y+o.bounds.yoff, o.bounds.w, o.bounds.h) then
						
						-- trigger is activated
						triggered = true
						if ent.trigger.type == "once" then
							ent.trigger.funct(ent, o)
							ent.trigger = nil
							break
						elseif  ent.trigger.type == "always" then
							ent.trigger.funct(ent,o)
							ent.trigger.active = true
						elseif ent.trigger.type == "wait" and not ent.trigger.active then
							ent.trigger.funct(ent, o)
							ent.trigger.active = true
						end
					end 
				end
			end 
			if not triggered then
				ent.trigger.active = false
			end
		end 
	end
end

statesystem = {}
statesystem.update = function ()
	for ent in all(entities) do
		if ent.gamestate and ent.gamestate == "playing" then
			if ent.state and ent.state.rules then
				ent.state.previous = ent.state.current
				for s,r in pairs(ent.state.rules) do
					if r() then ent.state.current = s end
				end
			end
		end
	end
end

dialoguesystem = {}
dialoguesystem.update = function ()
	for ent in all(entities) do 
		if ent.dialogue then
			if ent.dialogue.text[0] then
				--calculate length of the text
				local len =  #ent.dialogue.text[0]
				if ent.dialogue.text[1] and #ent.dialogue.text > 0 then
					len += #ent.dialogue.text[1]
				end 

				if ent.dialogue.cursor < len then
					ent.dialogue.cursor += 1
				end
				if ent.dialogue.timed 
					and ent.dialogue.timeremaining > 0 then
					ent.dialogue.timeremaining -= 1
				end
			end
		end 
	end 
end

itemsystem = {}
itemsystem.update = function ()
	for ent in all(entities) do 
		if ent.item then
			for o in all(entities) do 
				if o != ent and o.position and o.bounds and ent.position then
					if touching(ent.position.x, ent.position.y, ent.position.w, ent.position.h,
								o.position.x + o.bounds.xoff, o.position.y + o.bounds.yoff, o.bounds.w, o.bounds.h) then
						if o.inventory then-- and #o.inventory.items < o.inventory.size and 
							if o.intention and o.intention.o then
								-- Stack the item
								local stored = false
								for p=1, o.inventory.size do
									if o.inventory.items[p] != nil then
										if o.inventory.items[p]["id"] == ent.item and o.inventory.items[p]["num"] < itemdatabase[ent.item]["maxstack"] then
											o.inventory.items[p]["num"] += 1
											del(entities, ent)
											stored = true
											break
										end
									end
								end

								-- spare slot
								if not stored then
									for p=1, o.inventory.size do
										if o.inventory.items[p] == nil then
											o.inventory.items[p] = { id=ent.item, num=1}
											del(entities, ent)
											break
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end 
end

inventorysystem = {}
inventorysystem.update = function ()
	for ent in all(entities) do
		if ent.inventory and ent.inventory.visible then
			if ent.gamestate and ent.gamestate == "inventory" then
				if ent.intention.left then
					ent.inventory.selected = max(1, ent.inventory.selected-1)
				elseif ent.intention.right then
					ent.inventory.selected = min(ent.inventory.size, ent.inventory.selected+1)
				elseif ent.intention.up then
					--use item
					if ent.inventory.items[ent.inventory.selected] then
						local id, num = ent.inventory.items[ent.inventory.selected]["id"], ent.inventory.items[ent.inventory.selected]["num"]
						
						if itemdatabase[id]["usefunction"] == usekey then
							ret = itemdatabase[id]["usefunction"](id)
						else
							ret = itemdatabase[id]["usefunction"](ent)
						end

						if ret then
							ent.inventory.items[ent.inventory.selected]["num"] -= 1
							if num-1 < 1 then 
								ent.inventory.items[ent.inventory.selected] = nil
							end
						end
					end

				elseif ent.intention.down then
					--drop items
					if ent.inventory.items[ent.inventory.selected] then
						local id, num = ent.inventory.items[ent.inventory.selected]["id"], ent.inventory.items[ent.inventory.selected]["num"]
						local f = itemdatabase[id]["newfunction"]
						add(entities, f(id, ent.position.x, ent.position.y))
						ent.inventory.items[ent.inventory.selected]["num"] -= 1
						if num-1 < 1 then 
							ent.inventory.items[ent.inventory.selected] = nil
						end
					end
				end
			end
		end
	end 
end

gamestatesystem = {}
gamestatesystem.update = function ()
	for ent in all(entities) do
		if ent.gamestate and ent.intention then
			//if ent.intention.o and ent.intention.x then
			if ent.intention.x then
				if ent.gamestate == "playing" then
					ent.gamestate = "inventory"
				elseif ent.gamestate == "inventory" then
					ent.gamestate = "playing"
				end
			end
		end
	end
end

battlesystem={}
battlesystem.update = function()
	for ent in all(entities) do
		if ent.battle and ent.state and ent.position then
			-- if entity has hitbox for the current state
			if ent.battle.hitboxes[ent.state.current] and ent.state.current != ent.state.previous then
				--other entities to hit
				for o in all(entities) do 
					if o !=ent and o.battle and o.state and o.position and (ent==player or o==player) then
						if o.battle.hurtboxes[o.state.current] then
							local hitbox, hurtbox = ent.battle.hitboxes[ent.state.current], o.battle.hurtboxes[o.state.current]
							if touching(ent.position.x + hitbox.xoff, ent.position.y + hitbox.yoff, hitbox.w, hitbox.h, 
										o.position.x + hurtbox.xoff, o.position.y + hurtbox.yoff, hurtbox.w, hurtbox.h) then
								-- damage movement
								if o.battle.hit <=0 then
									o.battle.hit = 5
									-- deal damage
									o.battle.health -= ent.battle.damage
									
									if ent.position.x - o.position.x <= 0 then
										o.battle.dir = 1
									else
										o.battle.dir = -1
									end
								end
								if o.battle.health <1 then
									if o != player then 
										del(entities,o)
									
										-- drop inventory items
										if o.inventory and #o.inventory.items > 0 then
											for p = 1, #o.inventory.items do
												for n=1, o.inventory.items[p]["num"] do
													local id = o.inventory.items[p]["id"]
													local f = itemdatabase[id]["newfunction"]
													add(entities, f(id ,o.position.x, o.position.y))
												end 
											end
										end
									end
								end
							end
						end
					end 
				end 
			end
		end
	end
end

aisystem ={}
aisystem.update = function ()
	for ent in all(entities) do
		if ent.intention and ent != player and ent.ai then
			for o in all(entities) do
				if o == player then
					-- far from start
					if dist(ent.position.x + ent.position.w/2, ent.position.y + ent.position.h/2, ent.position.sx + ent.position.w/2, ent.position.sy + ent.position.h/2) >= ent.ai.follow or ent.ai.back then
						--ahhh
						ent.ai.back = true
						if ent.position.x < ent.position.sx then
							ent.intention.right = true
							ent.intention.left = false
						elseif ent.position.x > ent.position.sx then
							ent.intention.right = false
							ent.intention.left = true
						else
							ent.intention.right = false
							ent.intention.left = false
						end


						if ent.position.y < ent.position.sy then
							ent.intention.up = false
							ent.intention.down = true
						elseif ent.position.y > ent.position.sy then
							ent.intention.up = true
							ent.intention.down = false
						else
							ent.intention.up = false
							ent.intention.down = false
						end

						if dist(ent.position.x + ent.position.w/2, ent.position.y + ent.position.h/2, ent.position.sx + ent.position.w/2, ent.position.sy + ent.position.h/2) < ent.ai.range-10 then
							ent.ai.back = false
						end

					--patrol
					elseif dist(ent.position.x + ent.position.w/2, ent.position.y + ent.position.h/2, o.position.x + o.position.w/2, o.position.y + o.position.h/2) >= ent.ai.range then
						if ent.ai.timer < ent.ai.maxtimer then
							dir = ent.dir
							ent.ai.timer -= 1
							if ent.ai.timer <= 0 then
								ent.ai.timer = ent.ai.maxtimer
							end
						else
							dir = flr(rnd(4))
							ent.ai.dir = dir
							ent.ai.timer -= 1
						end

						
						if dir == 0 then
							ent.intention.right = true
							ent.intention.left = false
							ent.intention.up = false
							ent.intention.down = false
						elseif dir == 1 then
							ent.intention.right = false
							ent.intention.left = true
							ent.intention.up = false
							ent.intention.down = false
						elseif dir == 2 then
							ent.intention.right = false
							ent.intention.left = false
							ent.intention.up = true
							ent.intention.down = false
						elseif dir == 3 then
							ent.intention.right = false
							ent.intention.left = false
							ent.intention.up = false
							ent.intention.down = true
						elseif dir == 4 then
							ent.intention.right = false
							ent.intention.left = false
							ent.intention.up = false
							ent.intention.down = false
						end
					
					--attack
					else
						if ent.position.x < o.position.x then
							ent.intention.right = true
							ent.intention.left = false
						elseif ent.position.x > o.position.x then
							ent.intention.right = false
							ent.intention.left = true
						else
							ent.intention.right = false
							ent.intention.left = false
						end

						if ent.position.y < o.position.y then
							ent.intention.up = false
							ent.intention.down = true
						elseif ent.position.y > o.position.y then
							ent.intention.up = true
							ent.intention.down = false
						else
							ent.intention.up = false
							ent.intention.down = false
						end
					end
				end
			end
		end
	end
end

-- States of the game
playstate = {}
playstate.update = function ()
	-- check player input
	controlsystem.update()
	-- move entities
	physicsystem.update()
	--animate entities
	animationsystem.update()
	-- check triggers
	triggersystem.update()
	-- itemsystem
	itemsystem.update()
	-- game state update
	gamestatesystem.update()
	-- update inventory selection
	inventorysystem.update()
	-- update states
	statesystem.update()
	-- update dialogue
	dialoguesystem.update()
	-- update battle system
	battlesystem.update()
	-- update cutscene
	cutscene.update()
	-- update curtain
	curtain.update()
	--update ai
	aisystem.update()
	--update lock
	locksystem.update()
end
playstate.draw = function ()
	cls()
	graphicssystem.update()
end

titlestate = {}
titlestate.update = function ()
	
end

titlestate.draw = function ()
	cls()
	rectfill(0,0,128,128,15)
	cprint("adventure game", 30, 1)
	sspr(8,8,16,16,56,64) 
	cprint("press x to start", 100, 1)
end

gameoverstate = {}
gameoverstate.update = function ()
	player.battle.health, player.battle.hit = player.battle.maxhealth, 0
	player.position.x, player.position.y = spawnx, spawny
end

gameoverstate.draw = function ()
	rectfill(0, 50, 128, 70, 1)
	cprint("gameover", 60, 8)
end

	-- game state manager
statemanager = {}
statemanager.frame = 0
statemanager.current = nil
statemanager.update = function ()
	if statemanager.current and statemanager.current.update then
		statemanager.current.update()
	end

	if statemanager.frame < 3000 then
		statemanager.frame += 1
	end

	if statemanager.current and statemanager.current.rules then
		for r in all(statemanager.current.rules) do 
			if r.rule() then
				statemanager.current = r.newstate
				statemanager.frame = 0
			end
		end
	end
end
statemanager.draw = function ()
	if statemanager.current and statemanager.current.draw then
		statemanager.current.draw()
	end
end

titlestate.rules = {{rule = function() return btn(5,0) end, newstate = playstate}}
playstate.rules ={{rule = function() return player.battle.health < 1 end, newstate = gameoverstate}}
gameoverstate.rules = {{rule = function () return (statemanager.frame > 90) end, newstate = titlestate}}

-- Graphics system
graphicssystem = {}
graphicssystem.update = function()
	sort(entities, ycomparison)

	local camerax, cameray = player.position.x-64+player.position.w/2,
							player.position.y-64-player.position.h/2

	--centre camera on player
	camera(camerax, cameray)
	
	map()
	
	--draw all entities with sprites
	for ent in all(entities) do

		if ent.sprite and ent.position and ent.state then
			-- check if state changed to reset animation
			if ent.state.current != ent.state.previous then
				ent.sprite.index = 1
			end

			sspr(ent.sprite.spritelist[ent.state.current]["images"][ent.sprite.index][1],
				ent.sprite.spritelist[ent.state.current]["images"][ent.sprite.index][2],
				ent.position.w, ent.position.h,
				ent.position.x, ent.position.y, 
				ent.position.w, ent.position.h,
				ent.sprite.spritelist[ent.state.current]["flip"],false)
			
			--highlight items on ground
			if ent.item then
				--topleft
				sspr(8,24,2,2,ent.position.x-2, ent.position.y-1)
				--top right
				sspr(14,24,2,2,ent.position.x+ent.position.w, ent.position.y-1)
				--bottom left
				sspr(8,30,2,2,ent.position.x-2, ent.position.y+ent.position.h)
				--bottom right
				sspr(14,30,2,2,ent.position.x+ent.position.w, ent.position.y+ent.position.h)
			end
		end

		if debug then
			if ent.position and ent.bounds then
				rect(ent.position.x + ent.bounds.xoff,
					ent.position.y + ent.bounds.yoff,
					ent.position.x + ent.bounds.xoff + ent.bounds.w-1,
					ent.position.y + ent.bounds.yoff + ent.bounds.h-1,3)
			end
			if ent.position and ent.trigger then
				if ent.trigger.active then color = 13 else color = 2 end
				rect(ent.position.x + ent.trigger.xoff,
					ent.position.y + ent.trigger.yoff,
					ent.position.x + ent.trigger.xoff + ent.trigger.w-1,
					ent.position.y + ent.trigger.yoff + ent.trigger.h-1,color)
			end
			if ent.position and ent.lock then
				if ent.lock.active then color = 13 else color = 2 end
				rect(ent.position.x + ent.lock.xoff,
					ent.position.y + ent.lock.yoff,
					ent.position.x + ent.lock.xoff + ent.lock.w-1,
					ent.position.y + ent.lock.yoff + ent.lock.h-1,color)
			end
			
			if ent.battle and ent.position and ent.state then
				local s = ent.state.current
				local hib, hub = ent.battle.hitboxes[s], ent.battle.hurtboxes[s]
				if hib then
					rect(ent.position.x + hib.xoff,
						ent.position.y + hib.yoff,
						ent.position.x + hib.xoff + hib.w-1,
						ent.position.y + hib.yoff + hib.h-1, 4)
				end
				if hub then
					rect(ent.position.x + hub.xoff,
						ent.position.y + hub.yoff,
						ent.position.x + hub.xoff + hub.w-1,
						ent.position.y + hub.yoff + hub.h-1, 12)
				end
			end

		end 
	end
	camera()
	--draw a room border
	bckg = currentroom.bg
	--top border
	rectfill(-1, -1, 128, currentroom.y*8-cameray-1, bckg)
	--left border
	rectfill(-1, -1, currentroom.x*8-camerax-1,128, bckg)
	--right border
	rectfill((currentroom.x + currentroom.w)*8-camerax, -1, 128, 128, bckg)
	--bottom border
	rectfill(-1, (currentroom.y+currentroom.h)*8-cameray-1, 128, 128, bckg)

	--dialogue subsystem
	camera(camerax, cameray)
	for ent in all(entities) do 
		if ent.dialogue and ent.position then
			if ent.dialogue.text[0] and (not ent.dialogue.timed or (ent.dialogue.timed and ent.dialogue.timeremaining > 0))then
				
				--move the text up if there is two lines
				local offset = 0
          		if ent.dialogue.text[1] and #ent.dialogue.text[1]>0 then offset -= 8 end

         		 -- draw line 1
          		local texttodraw = sub(ent.dialogue.text[0],0,ent.dialogue.cursor)
          		printoutline(texttodraw,ent.position.x-10,ent.position.y+offset-8,15)

          		-- draw line 2
          		if ent.dialogue.text[1] then
            		texttodraw = sub(ent.dialogue.text[1],0,max(0,ent.dialogue.cursor - #ent.dialogue.text[0]))
            		printoutline(texttodraw,ent.position.x-10,ent.position.y+offset,15)
				end 
			end
		end 
	end 


	camera()
	-- draw inventories and draw health
	for ent in all(entities) do
		if ent.inventory and ent.inventory.visible then
			rectfill(ent.inventory.x, ent.inventory.y, ent.inventory.x+(ent.inventory.size*9), ent.inventory.y+9, 8)
			for i = 1, ent.inventory.size do
				--draw inventory
				rectfill(ent.inventory.x+1+(i-1)*9, ent.inventory.y+1 ,ent.inventory.x+1+(i-1)*9+7, ent.inventory.y+8, 1)
				--draw items
				if ent.inventory.items[i] then
					-- draw item in inventory
					local id, num = ent.inventory.items[i]["id"], ent.inventory.items[i]["num"]
					sspr(itemdatabase[id]["sprite"]["idle"]["images"][1][1],
						itemdatabase[id]["sprite"]["idle"]["images"][1][2],
						itemdatabase[id]["position"].w,itemdatabase[id]["position"].h,
						ent.inventory.x + 1 + (i-1)*9 - (8-itemdatabase[id]["position"].w)/2, ent.inventory.y+1 + (8-itemdatabase[id]["position"].h)/2, 
						itemdatabase[id]["position"].w,itemdatabase[id]["position"].h,
						itemdatabase[id]["sprite"]["idle"]["flip"],false)
					-- number of items
					if num > 1 then
						print(num, ent.inventory.x + 1 + (i-1)*9, ent.inventory.y+1, 15)					
					end
				end
			end

			if ent.gamestate and ent.gamestate == "inventory" then
				rect(ent.inventory.x+(ent.inventory.selected-1)*9, ent.inventory.y ,ent.inventory.x+2+(ent.inventory.selected-1)*9+7, ent.inventory.y+9, 9)
				if ent.inventory.items[ent.inventory.selected] then
					printoutline(ent.inventory.items[ent.inventory.selected]["id"],(128-#ent.inventory.items[ent.inventory.selected]["id"]*4+1)/2, ent.inventory.y-6, 15)
				end 
			end
			
			-- draw health
			if ent.battle then
				if ent == player then
					for i = 0,player.battle.maxhealth/2-1 do 
						sspr(32, 24, 8, 8, i*8, 0)
					end
					hp = player.battle.health \ 2 - 1
					half = player.battle.health % 2
					if hp <= 0 and half == 1 then
						sspr(24, 24, 8, 8, 0, 0)
					end
					for i = 0,hp do 
						sspr(16, 24, 8, 8, i*8, 0)
						if i == hp and half == 1 then
							sspr(24, 24, 8, 8, (i+1)*8, 0)
						end
					end

				end
			end

		end 
	end

	-- hit color
	if player.battle.hit >=4 then
		rectfill(-1, -1, 128, 128, 8)
	end
	--draw curtain
	curtain.draw()


end

animationsystem = {}
animationsystem.update = function ()
	for ent in all(entities) do
		if ent.gamestate and ent.gamestate == "playing" then
			if ent.sprite and ent.animation and ent.state then
				if ent.animation.list[ent.state.current] then
					-- increment timer
					ent.animation.timer += 1
					-- if timer is  higher than delay
					if ent.animation.timer > ent.animation.delay then
						-- increment the index and reset timer
						ent.sprite.index += 1
						if ent.sprite.index > #ent.sprite.spritelist[ent.state.current]["images"] then
							ent.sprite.index = 1
						end
						ent.animation.timer = 0
					end
				
				end
	 		end
		end
	end
end 
	
cutscene = {}
cutscene.scene = {}
cutscene.step = 1
cutscene.timer = 0
cutscene.wait = function (_t)
  cutscene.timer +=1
  if cutscene.timer > _t then
    cutscene.advance()
  end 
end
cutscene.advance = function()
	if #cutscene.scene > 0 then
		cutscene.step +=1
		cutscene.timer = 0
	end
end
cutscene.update = function ()
	if #cutscene.scene > 0 then
		if cutscene.step > #cutscene.scene then
			cutscene.scene = {}
			cutscene.step = 1
			cutscene.timer = 0
		
		else
			-- as many premises as the longest function
			local f, p1, p2, p3,p4 = cutscene.scene[cutscene.step][1],
									cutscene.scene[cutscene.step][2],
									cutscene.scene[cutscene.step][3],
									cutscene.scene[cutscene.step][4],
									cutscene.scene[cutscene.step][5]

			f(p1,p2,p3,p4)
		end
	end 
end

curtain = {}
curtain.state = "up"
curtain.height = 0
curtain.speed = 4
curtain.set = function (_state)
	curtain.state = _state
	cutscene.advance()
end

curtain.draw = function ()
	--top
	rectfill(0, -1, 128, curtain.height-1, 1)
	--bottom
	rectfill(0, 129, 128, 129-curtain.height, 1)
end

curtain.update = function ()
	
	if curtain.state == "up" then
		if curtain.height > 0 then
			curtain.height -= curtain.speed
		end
	end

	if curtain.state == "down" then
		if curtain.height <= 64 then
			curtain.height += curtain.speed
		end 
	end
	
end

---- to do:
-- keys
-- respawn entities
-- visualize some enemies health // add other entities to the display
-- animate title screen and death screen
__gfx__
00000000000001010100000000010101000000000101010000000001010100000000010101000000000101010000000000000000000000000000000000000000
00000000000019181910000000191819100000001918191000000019181910000000191819180000001918191000000000000000000000000000000000000000
00700700000199f1f91000000199f1f91000000199f1f91000000199f1f91110000199f1f91000000199f1f91000000000000000000000000000000000000000
0007700000019f8f81000000019f8f81000000019f8f81000000019f8f81181000019f8f81008000019f8f810000000000000000000000000000000000000000
0007700000001ffff1000000001ffff1000000001ffff1000000001ffff1810000001ffff1111000001ffff11100000000000000000000000000000000000000
00700700000198998910000001f8998f10000001f899810000000198998f1000000198998f8881000198998f8100000000000000000000000000000000000000
000000000001f8888f100000019988810000000018119910000001f8888910000001f8888911100001f888891000000000000000000000000000000000000000
00000000000199119910000000001199100000019900000000000199119910000001991199100000019911991000000000000000000000000000000000000000
00000011000000111100000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000001f1000001999910000000000001910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11001f91000019999991000000000019910000000000011111100000000000000000000000000000000000000000000000000000000000000000000000000000
1f101910000199898988100000011019810000000000199999810000000000000000000000000000000000000000000000000000000000000000000000000000
19f11910000199989898100000199199810000000001991199981000000000000000000000000000000000000000000000000000000000000000000000000000
0199191000199989898881000018999991111000001991f819998100000000000000000000000000000000000000000000000000000000000000000000000000
00199110019998988888111000018889919991000199918819999810000000000000000000000000000000000000000000000000000000000000000000000000
00011100019989888881811000001199999881001999991199999981000000000000000000000000000000000000000000000000000000000000000000000000
00111100019898888818111000000199988110000111111111111110000000000000000000000000000000000000000000000000000000000000000000000000
01999910018988818181811000000198911000000018888888888100000000000000000000000000000000000000000000000000000000000000000000000000
19999991018888181818111000000198991000000019999999998100000000000000000000000000000000000000000000000000000000000000000000000000
18899991001881818181110000000198991000000019999999998100000000000000000000000000000000000000000000000000000000000000000000000000
19999991001818111111110000001989991000000019111991198100000000000000000000000000000000000000000000000000000000000000000000000000
19999981000111111111100000001989981000000019111991198100000000000000000000000000000000000000000000000000000000000000000000000000
18899991000000188100000000019999998100000019111999998100000000000000000000000000000000000000000000000000000000000000000000000000
19999991000001811810000000019999999810000019111999998100000000000000000000000000000000000000000000000000000000000000000000000000
000010008800008800000000000000000000000000000011000000000000000000000000000000000000000000000000000000000000000000000000ff998811
001141008000000801100110011001100110011000000181000011110000000000000000000000000000000000000000000000000000000000000000ff998811
018448100000000018911881189111111111111100001810000119910000000000000000000000000000000000000000000000000000000000000000ff998811
189888810000000019888881198811111111111111018100011199110000000000000000000000000000000000000000000000000000000000000000ff998811
19888881000000001888888118881111111111111f181000199991100000000000000000000000000000000000000000000000000000000000000000ff998811
188888810000000001888810018811100111111001910000191910000000000000000000000000000000000000000000000000000000000000000000ff998811
01888810800000080018810000181100001111001f1f1000199910000000000000000000000000000000000000000000000000000000000000000000ff998811
001111008800008800011000000110000001100011011000011100000000000000000000000000000000000000000000000000000000000000000000ff998811
fffffffffffffffff99fffffffffffffffffffffffffffffffffffff000000000000000000000000000000000000000000000000000000000000000000000000
9fffffffffffffff9999ffff9ff11fff9ff11fff9ff11fff9ff11fff000000000000000000000000000000000000000000000000000000000000000000000000
ffff9fff8f88ff888998ffffff1991ffff1991ffff1991ffff1991ff000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff98998899f88fffffff1111ffff1111ffff1111ffff1111ff010000100000000000000000000000000000000000000000000000000000000000000000
ffffffff99999999fffff99f11198111ff198111111981ffff1981ff181111810000000000000000000000000000000000000000000000000000000000000000
9fffffff11111111ffff999999198199ff198199991981ff9f1981ff191881910000000000000000000000000000000000000000000000000000000000000000
ffffffff11111111f9ff8998111981119f198111111981ffff1981ff181111810000000000000000000000000000000000000000000000000000000000000000
ffff9fff11111111fffff88fff1981ffff1981ffff1981ffff1981ff010000100000000000000000000000000000000000000000000000000000000000000000
11111111111ffffffffff111ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111111fffffff9ffffff1ffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111ffff9fffffff9ffffff88ff888f88fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111fffffffffffffffff88998899989988f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111ffffffffffffffff89999999999999980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111119fffffff9fffffff99911111111119990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111ffffffffffffffff91111111111111190000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111ffff9fffffff9fff11111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111118ffffffffffffff811111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11f11111988ffffffffff88911111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f111119988f88ff88899111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111199998998899999111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111111999999999911111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111f11111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111f1f11111111111111111f11111111111111f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111111111111111111111fff1111111111fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
111111119999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
88888818ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
88888818fff9f99f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
88888818ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
111111119999999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
81888888ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
81888888f99f9fff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
81888888ffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff998811
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01fff910000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f8f8f91000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f8f8f91000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1fffff91000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800080808080800000000000000000800000808000000000000000000000008080808080000000000000000000000080000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5050505050505050505050605050505050507070707070707070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5051404040404040526350505064515250507071717171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040424242424242404040404040404060507071717171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040404040404042404040404040404050507071717171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040405341544042404040404040536250507071717171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040405050504042424242404040505050507071717171717171717000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040405060504040404040405362505060507070707070707071707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040406350644040404040405050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040404040404040404040406350505050600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5040404040404040404040404052635050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5061415440404040405354444043455263500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505040404040405050404040404052500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050605040404040405050404040404040500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505061414141625050404040404062500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505050505050614141416250500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050505050505060505050505050505050500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
011000200c0433f2150000000000246153f2150c043000000c0533f215000003f215246153f2003f2153f2000c0533f2153f2003f21524615000000c043000000c0533f2003f2150c04324615000000c0433f215
