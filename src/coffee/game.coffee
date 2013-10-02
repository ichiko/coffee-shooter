# game.coffee

# enchant.js の初期化
enchant()

# 定数
IMG_PLAYER   = 'images/player.png'
IMG_ENEMY    = 'images/enemy.png'
IMG_MUSHROOM = 'images/mushroom.png'

# 状態定義
STATE_MAINGAME = 1
STATE_RESULT = 2

SCREEN_SIZE = 320
FPS = 30

PLAYER_INIT_POS_X = 40
PLAYER_INIT_POS_Y = 30
ENEMY_POP_DELAY = 15
ENEMY_INIT_POS_X = 300
ENEMY_INIT_POS_TOP = 120
ENEMY_INIT_POS_RANGE = 180
MUSH_INIT_POS_Y = 55

TIME_LIMIT = 10 * FPS

class Shooter extends Game
	constructor: ->
		super SCREEN_SIZE, SCREEN_SIZE
		@fps = FPS
		Shooter.game = @
		@preload IMG_PLAYER, IMG_ENEMY, IMG_MUSHROOM
		@time_tick = 0

		@onload = ->
			@replaceScene new ShootScene()
			@startGame()

			@onenterframe = ->
				@time_tick++
				switch @state
					when STATE_MAINGAME
						@onEnterFrameAtGame()

		@start()

	# メインゲームの開始
	startGame: ->
		@time_tick = 0
		@score = 0
		@state = STATE_MAINGAME

	# メインゲームの終了
	finishGame: ->
		@state = STATE_RESULT
		@currentScene.onFinishGame()
		@pushScene new ResultScene(@score)

	# 状態ごとのonEnterFrame
	onEnterFrameAtGame: ->
		if @time_tick >= TIME_LIMIT
			@finishGame()

	# スコア加算
	incrementScore: (add) ->
		@score += add

## ---- メインのゲームシーン ----

class ShootScene extends Scene
	constructor: ->
		super()		# ... うっかりするけど、これ大事
		@game = Shooter.game
		ShootScene.scene = @

		@player = new Player(PLAYER_INIT_POS_X, PLAYER_INIT_POS_Y)
		@addChild @player

		timeLabel = new StateLabel(160, 18)
		timeLabel.x = timeLabel.y = 0
		timeLabel.setText("残り時間 : " + parseInt(TIME_LIMIT / Shooter.game.fps))
		timeLabel.onenterframe = ->
			time = parseInt((TIME_LIMIT - ShootScene.scene.tick) / Shooter.game.fps) + 1
			timeLabel.setText("残り時間 : " + time)
		@timeLabel = timeLabel
		@addChild @timeLabel

		# @frameは他のシーンとも共有されるのか、カウントアップが激速
		@tick = 0

		@onenter = ->
			@initScene()
			@player.tl.clear()
			@tick = 0

		@ontouchstart = (e) ->
			@player.tl.moveTo(e.x, @player.y, Math.abs(@player.x - e.x) / 4).then( =>
				@mainGroup.addChild new Mush(e.x, MUSH_INIT_POS_Y)
			)

		@onenterframe = ->
			@tick++
			if @tick % ENEMY_POP_DELAY == 0
				@mainGroup.addChild(new Enemy(ENEMY_INIT_POS_X, ENEMY_INIT_POS_TOP + Math.random() * ENEMY_INIT_POS_RANGE))

	initScene: ->
		@player.x = PLAYER_INIT_POS_X
		@removeChild @mainGroup if @mainGroup
		@mainGroup = new Group()
		@addChild @mainGroup

	onFinishGame: ->
		@timeLabel.setText "残り時間 : 0"

class StateLabel extends Group
	constructor: (width, height, color) ->
		super()
	
		StateLabelPadding = 3

		backboard = new Sprite(width + StateLabelPadding * 2, height + StateLabelPadding * 2)
		backboard.backgroundColor = '#666666'
		backboard.x = backboard.y = 0
		@addChild backboard

		@label = new Label()
		@label.color = (color || 'white')
		@label.width = width
		@label.height = height
		@label.x = StateLabelPadding
		@label.y = StateLabelPadding
		@addChild @label

	setText: (text) ->
		@label.text = text

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
			if elm isnt this and elm instanceof Enemy and elm.intersect(this) is true
				@game.incrementScore(100)
				@parentNode.addChild new CrushParticle(elm.x, elm.y)
				@parentNode.removeChild elm
				@parentNode.removeChild this
				break
			i++

class ArcSprite extends Sprite
	constructor: (radius) ->
		super radius * 2, radius * 2

		surface = new Surface(radius * 2, radius * 2)
		c = surface.context
		# 円を描画
		c.fillStyle = "rgb(255, 0, 0)"
		c.beginPath()
		c.arc(radius, radius, radius, 0, Math.PI * 2, true)
		c.fill()

		# Sprite にイメージとして指定
		@image = surface

class CrushParticle extends Group
	constructor: (x, y) ->
		super()
		@x = x
		@y = y

		# パーティクル生成
		for i in [0...8]
			particle = new ArcSprite(5)
			particle.x = particle.y = 0
			# 移動ベクトルを保存
			radius = 2 * Math.PI / 8 * i
			particle.vx = Math.cos(radius)
			particle.vy = -Math.sin(radius)
			# 消滅までの時間
			particle.life = 20

			# 更新関数を登録
			particle.update = ->
				# 移動
				@x += @vx
				@y += @vy
				# ライフに応じて透過度を変更
				@opacity = @life / 20
				@life -= 1
				# true: 存続, false: 消滅
				return @life > 0

			@addChild particle

	onenterframe: ->
		# 登録されているパーティクルを更新
		i = 0
		len = @childNodes.length
		while i < len
			elm = @childNodes[i]
			if typeof elm isnt "undefined" and elm.update() is false
				@removeChild elm
			i++
		# すべてがなくなったら
		if @childNodes.length <= 0
			@parentNode.removeChild this

## ---- 結果画面 ----

class ResultScene extends Scene
	constructor: (score) ->
		super()
		@game = Shooter.game

		backboard = new Sprite(200, 220)
		backboard.backgroundColor = 'lightgray'
		backboard.x = 60
		backboard.y = 50
		@addChild backboard

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

		# 結果表示直後は、タッチイベントを受け付けない
		@tl.delay(@game.fps * 1).then(this.setEventDelay)

	setEventDelay: ->
		btn = new Button("リトライ!", "blue")
		btn.moveTo(90, 220)
		btn.width = 120
		btn.game = Shooter.game
		btn.ontouchend = ->
			@tl.delay(@game.fps * 0.1).then( ->
				@game.popScene()
				@game.startGame()
			)
		@addChild btn

window.onload = ->
	new Shooter()