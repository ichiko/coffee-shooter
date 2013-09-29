# game.coffee

enchant()

# 定数
IMG_PLAYER   = 'images/player.png'
IMG_ENEMY    = 'images/enemy.png'
IMG_MUSHROOM = 'images/mushroom.png'

player = null

e_time = 70
e_pop_x = 300
pop_top = 50
score = 0
time_limit = 300

class Shooter extends Game
	constructor: ->
		super 320, 320
		@fps = 30
		Shooter.game = @
		@preload IMG_PLAYER, IMG_ENEMY, IMG_MUSHROOM

		@onload = ->
			@replaceScene(new ShootScene())

		@start()

## ---- メインのゲームシーン ----

class ShootScene extends Scene
	constructor: ->
		super()		# ... うっかりするけど、これ大事
		@game = Shooter.game

		player = new Player(40, 0)
		@addChild player

		# @frameは他のシーンとも共有されるのか、カウントアップが激速
		@tick = 0

		@onenter = ->
			console.log "ShootScene.onenter"
			@tick = 0
			score = 0

		@ontouchstart = (e) ->
			player.x = e.x
			@addChild new Mush(e.x, pop_top)

		@onenterframe = ->
			console.log "ShootScene.onenterframe"
			@tick++
			if @tick % 14 == 0
				@addChild(new Enemy(e_pop_x, pop_top + Math.random() * 200))

			# ゲームオーバー
			if @tick >= time_limit
				@game.pushScene new ResultScene(score)

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

## ---- 結果画面 ----

class ResultScene extends Scene
	constructor: (score) ->
		super()
		@game = Shooter.game

		label1 = new Label()
		label1.text = "結果"
		label1.x = 60
		label1.y = 100
		label1.width = 200
		label1.textAlign = 'center'
		@addChild label1

		label2 = new Label()
		label2.text = "スコア：" + score
		label2.x = 60
		label2.y = 160
		label2.width = 200
		label2.textAlign = 'center'
		@addChild label2

		@ontouchstart = ->
			console.log "ResultScene ontouchstart"
			@game.popScene()
			console.log "popped"

window.onload = ->
	new Shooter()