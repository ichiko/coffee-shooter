# game.coffee

enchant()

# 定数
IMG_PLAYER   = 'images/player.png'
IMG_ENEMY    = 'images/enemy.png'
IMG_MUSHROOM = 'images/mushroom.png'

player = null
px = 0
e_time = 70
e_pop_x = 300
pop_top = 30
score = 0
time_limit = 300

class Shooter extends Game
	constructor: ->
		super 320, 320
		@fps = 30
		Shooter.game = @
		@preload IMG_PLAYER, IMG_ENEMY, IMG_MUSHROOM

		@onload = ->
			player = new Player(40, 0)
			@rootScene.addChild player

			@rootScene.onenter = ->
				@frame = 0

			@rootScene.ontouchstart = (e) ->
				player.x = e.x
				this.addChild new Mush(e.x, pop_top)

			@onenterframe = ->
				if @frame % 14 == 0
					@rootScene.addChild(new Enemy(e_pop_x, pop_top + Math.random() * 200))
				if @frame >= time_limit
					alert score + "点です"
					@end()

		@start()

class Player extends Sprite
	constructor: (x, y) ->
		super 24, 24
		@x = x
		@y = y
		@game = Shooter.game
		@image = @game.assets[IMG_PLAYER]

class Enemy extends Sprite
	constructor: (x, y) ->
		super 24, 24
		@x = x
		@y = y
		@game = Shooter.game
		@image = @game.assets[IMG_ENEMY]

	onenterframe: ->
		@x -= 1
		@parentNode.removeChild this if @x < 0

class Mush extends Sprite
	constructor: (x, y) ->
		super 24, 20
		@x = x
		@y = y
		@game = Shooter.game
		@image = @game.assets[IMG_MUSHROOM]

	onenterframe: ->
		@y += 3
		@rotate 20
		if @y > 300
			@parentNode.removeChild this 
			return
		
		# 衝突判定
		i = 0
		len = @parentNode.childNodes.length

		while i < len
			elm = @parentNode.childNodes[i]
			if elm isnt player and elm isnt this and elm.intersect(this) is true
				score += 100
				@parentNode.removeChild elm
				@parentNode.removeChild this
				break
			i++


window.onload = ->
	new Shooter()