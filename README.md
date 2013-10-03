enchant.jsとcoffee-scriptで、ゲームをつくってみる。
最初の練習。

### DEMO

<http://ichiko.github.io/coffee-shooter/index.html>

#### ざっくりやってみたこと

- きのこ、こうもりが移動する(Sprite.onenterframeで更新)
- ユーザクリックの位置まで、移動してから、きのこを投げる(Timelineを使った)
- 打ち落すときにパーティクルを表示する(SpriteをGroupにつめて、まとめて管理)
- メインと結果を別々のシーンで管理する

### for Developers

#### 環境に必要なもの。

- node.js ( required by coffee-script)
- coffee-script
- Grunt
  - プロジェクトが依存するモジュールについては、 package.json を参照

#### インストール方法とか

##### 環境準備のメモ

1. node.js

  download installer from http://nodejs.org

1. coffee-script

  ```
  sudo npm install -g coffee-script
  ```

1. Grunt

  ```
  sudo npm install -g grunt-cli
  ```
  
  '-g' is optional

  install/update dependecies into local project
  ```
  npm install
  ```

##### 監視とビルド

coffeeファイルを監視して.jsへ変換するGruntfile.coffeeを作成しています。
以下のコマンドで、監視とビルドを行えます。

```
grunt
```


