(function() {
  var ENEMY_INIT_POS_RANGE, ENEMY_INIT_POS_TOP, ENEMY_INIT_POS_X, ENEMY_POP_DELAY, Enemy, FPS, IMG_ENEMY, IMG_MUSHROOM, IMG_PLAYER, MUSH_INIT_POS_Y, Mush, PLAYER_INIT_POS_X, PLAYER_INIT_POS_Y, Player, ResultScene, SCREEN_SIZE, STATE_MAINGAME, STATE_RESULT, ShootScene, Shooter, StateLabel, TIME_LIMIT, player,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  enchant();

  IMG_PLAYER = 'images/player.png';

  IMG_ENEMY = 'images/enemy.png';

  IMG_MUSHROOM = 'images/mushroom.png';

  STATE_MAINGAME = 1;

  STATE_RESULT = 2;

  SCREEN_SIZE = 320;

  FPS = 30;

  PLAYER_INIT_POS_X = 40;

  PLAYER_INIT_POS_Y = 30;

  ENEMY_POP_DELAY = 15;

  ENEMY_INIT_POS_X = 300;

  ENEMY_INIT_POS_TOP = 120;

  ENEMY_INIT_POS_RANGE = 180;

  MUSH_INIT_POS_Y = 55;

  TIME_LIMIT = 10 * FPS;

  player = null;

  Shooter = (function(_super) {
    __extends(Shooter, _super);

    function Shooter() {
      Shooter.__super__.constructor.call(this, SCREEN_SIZE, SCREEN_SIZE);
      this.fps = FPS;
      Shooter.game = this;
      this.preload(IMG_PLAYER, IMG_ENEMY, IMG_MUSHROOM);
      this.time_tick = 0;
      this.onload = function() {
        this.replaceScene(new ShootScene());
        this.startGame();
        return this.onenterframe = function() {
          this.time_tick++;
          switch (this.state) {
            case STATE_MAINGAME:
              return this.onEnterFrameAtGame();
          }
        };
      };
      this.start();
    }

    Shooter.prototype.startGame = function() {
      this.time_tick = 0;
      this.score = 0;
      return this.state = STATE_MAINGAME;
    };

    Shooter.prototype.finishGame = function() {
      this.state = STATE_RESULT;
      this.currentScene.onFinishGame();
      return this.pushScene(new ResultScene(this.score));
    };

    Shooter.prototype.onEnterFrameAtGame = function() {
      if (this.time_tick >= TIME_LIMIT) {
        return this.finishGame();
      }
    };

    Shooter.prototype.incrementScore = function(add) {
      return this.score += add;
    };

    return Shooter;

  })(Game);

  ShootScene = (function(_super) {
    __extends(ShootScene, _super);

    function ShootScene() {
      var timeLabel;
      ShootScene.__super__.constructor.call(this);
      this.game = Shooter.game;
      ShootScene.scene = this;
      player = new Player(PLAYER_INIT_POS_X, PLAYER_INIT_POS_Y);
      this.addChild(player);
      timeLabel = new StateLabel(160, 18);
      timeLabel.x = timeLabel.y = 0;
      timeLabel.setText("残り時間 : " + parseInt(TIME_LIMIT / Shooter.game.fps));
      timeLabel.onenterframe = function() {
        var time;
        time = parseInt((TIME_LIMIT - ShootScene.scene.tick) / Shooter.game.fps) + 1;
        return timeLabel.setText("残り時間 : " + time);
      };
      this.timeLabel = timeLabel;
      this.addChild(this.timeLabel);
      this.tick = 0;
      this.onenter = function() {
        this.initScene();
        return this.tick = 0;
      };
      this.ontouchstart = function(e) {
        player.x = e.x;
        return this.mainGroup.addChild(new Mush(e.x, MUSH_INIT_POS_Y));
      };
      this.onenterframe = function() {
        this.tick++;
        if (this.tick % ENEMY_POP_DELAY === 0) {
          return this.mainGroup.addChild(new Enemy(ENEMY_INIT_POS_X, ENEMY_INIT_POS_TOP + Math.random() * ENEMY_INIT_POS_RANGE));
        }
      };
    }

    ShootScene.prototype.initScene = function() {
      player.x = PLAYER_INIT_POS_X;
      if (this.mainGroup) {
        this.removeChild(this.mainGroup);
      }
      this.mainGroup = new Group();
      return this.addChild(this.mainGroup);
    };

    ShootScene.prototype.onFinishGame = function() {
      return this.timeLabel.setText("残り時間 : 0");
    };

    return ShootScene;

  })(Scene);

  StateLabel = (function(_super) {
    __extends(StateLabel, _super);

    function StateLabel(width, height, color) {
      var StateLabelPadding, backboard;
      StateLabel.__super__.constructor.call(this);
      StateLabelPadding = 3;
      backboard = new Sprite(width + StateLabelPadding * 2, height + StateLabelPadding * 2);
      backboard.backgroundColor = '#666666';
      backboard.x = backboard.y = 0;
      this.addChild(backboard);
      this.label = new Label();
      this.label.color = color || 'white';
      this.label.width = width;
      this.label.height = height;
      this.label.x = StateLabelPadding;
      this.label.y = StateLabelPadding;
      this.addChild(this.label);
    }

    StateLabel.prototype.setText = function(text) {
      return this.label.text = text;
    };

    return StateLabel;

  })(Group);

  Player = (function(_super) {
    __extends(Player, _super);

    function Player(x, y) {
      Player.__super__.constructor.call(this, 24, 24);
      this.x = x;
      this.y = y;
      this.game = Shooter.game;
      this.image = this.game.assets[IMG_PLAYER];
    }

    return Player;

  })(Sprite);

  Enemy = (function(_super) {
    __extends(Enemy, _super);

    function Enemy(x, y) {
      Enemy.__super__.constructor.call(this, 24, 24);
      this.x = x;
      this.y = y;
      this.game = Shooter.game;
      this.image = this.game.assets[IMG_ENEMY];
    }

    Enemy.prototype.onenterframe = function() {
      this.x -= 1;
      if (this.x < 0) {
        return this.parentNode.removeChild(this);
      }
    };

    return Enemy;

  })(Sprite);

  Mush = (function(_super) {
    __extends(Mush, _super);

    function Mush(x, y) {
      Mush.__super__.constructor.call(this, 24, 20);
      this.x = x;
      this.y = y;
      this.game = Shooter.game;
      this.image = this.game.assets[IMG_MUSHROOM];
    }

    Mush.prototype.onenterframe = function() {
      var elm, i, len, _results;
      this.y += 3;
      this.rotate(20);
      if (this.y > 300) {
        this.parentNode.removeChild(this);
        return;
      }
      i = 0;
      len = this.parentNode.childNodes.length;
      _results = [];
      while (i < len) {
        elm = this.parentNode.childNodes[i];
        if (elm !== player && elm !== this && elm.intersect(this) === true) {
          this.game.incrementScore(100);
          this.parentNode.removeChild(elm);
          this.parentNode.removeChild(this);
          break;
        }
        _results.push(i++);
      }
      return _results;
    };

    return Mush;

  })(Sprite);

  ResultScene = (function(_super) {
    __extends(ResultScene, _super);

    function ResultScene(score) {
      var backboard, label1, label2;
      ResultScene.__super__.constructor.call(this);
      this.game = Shooter.game;
      backboard = new Sprite(200, 220);
      backboard.backgroundColor = 'lightgray';
      backboard.x = 60;
      backboard.y = 50;
      this.addChild(backboard);
      label1 = new Label();
      label1.text = "結果";
      label1.x = 60;
      label1.y = 100;
      label1.width = 200;
      label1.textAlign = 'center';
      this.addChild(label1);
      label2 = new Label();
      label2.text = "スコア：" + score;
      label2.x = 60;
      label2.y = 160;
      label2.width = 200;
      label2.textAlign = 'center';
      this.addChild(label2);
      this.tl.delay(this.game.fps * 1).then(this.setEventDelay);
    }

    ResultScene.prototype.setEventDelay = function() {
      return this.ontouchstart = function() {
        this.game.popScene();
        return this.game.startGame();
      };
    };

    return ResultScene;

  })(Scene);

  window.onload = function() {
    return new Shooter();
  };

}).call(this);
