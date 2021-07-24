# isucon-utils

## Usage

### ローカルPC

sshの設定

```shell
# basic usage
./client/init.sh -s "2.2.2.2"
# use bastion server and use 5032 port and multiple server
./client/init.sh -b 1.1.1.1 -s "2.2.2.2 3.3.3.3 4.4.4.4" -p 5032

# サーバにssh(最初にsetupする人はubuntuのユーザで入る)
alias ssh="ssh -F $(pwd)/client/.sshconfig"
ssh s1

# デプロイを行う
./client/deploy.sh main

# alpを回して結果をhtmlにまとめる
./client/analyze.sh s1
```

サーバ

```shell
# @isuconユーザのホームディレクトリ
git clone https://github.com/44smkn/isucon-utils.git
cd isucon-utils/server
webhook_url="<replca_your_webhook_url>"
./init.sh $webhook_url

cd $HOME/isuumo/webapp/go
git config --global user.name "pang of conscience"
git config --global user.email "pangofconscience@gmail.com"
git config --global credential.helper store
git config --global init.defaultBranch main

git init
git remote add origin https://github.com/PangsOfConscience/isucon9-qualify.git
git branch --set-upstream-to=origin/main main
git add .
git commit -m "Initial Commmit"
```

nginxのルーティングルールを変更する  
`sudo vim /etc/nginx/nginx.conf`

```sh
    server {
        listen 80;

        location / {
            proxy_pass http://localhost:8000;
        }
    }

    server {
        listen 9091;

        location / {
            root /www/data;
            index index.html;
        }
    }
```

## 事前準備

* レギュレーションを読む
  * ISUCON10だと、開催日の2ヶ月前くらいにPublicになっている様子
  * ただし当日に公開されるマニュアルの内容が優先されるらしい
* GitHubにリポジトリを作成しておく
  * `isucon11-qualify`とかの名前で
  * 必要であればIssueやプルリクのテンプレートとか作っておく
* 利用するGoのバージョンを揃える

## 当日の流れ

競技開始直前から終了までの流れ

### マニュアルを確認する

* スケジュールの再確認
* サーバへの入り方を確認する
  * 踏み台を経由する？
  * ssh鍵に何を利用するのか
* ベンチマークの流れ
  * 初期化処理にかけてよい時間
  * 負荷走行の時間（基本は60sっぽい）
* 参照実装の切替方法
  * 大体は`systemctl`で切り替えを行う
* スコア計算方法
* アプリケーションの仕様
  * ISUCON10ではbotからのリクエストを弾いて良いという記述があった

### 環境構築を行う

* ssh設定を作り全員で共有する
  * 当リポジトリの`client/init.sh`を叩くと設定を生成する
* デフォルトがGo実装でなければGo実装に切り替える
* そのままの状態でベンチマークを流す
  * 今まで通りだとポータルサイトから走らせる
* アプリケーションコードの置いてあるディレクトリにcdして`git init`して`git push`
  * 大体は`/hone/isucon/${APP名}`のディレクトリとなっているはず
  * そのディレクトリ配下で各種の設定ファイルも管理してしまう（`config`ディレクトリを切る）
    * 例えば、`nginx.conf`や`my.conf`、`sysctl.conf`等…

### 計測の準備をする

* 当リポジトリを`/hone/isucon`にcloneして、`server/init.sh`を叩く
  * 計測ツールのインストール
  * nginxのアクセスログ追加
* `my.conf`にスロークエリ出力の設定を行う

### 方針決め

* 怪しげなところの共有と優先度付け
* GitHub Issueを使って管理する（今の所は）

### デプロイと計測

* `client/deploy.sh`を使う
  * Goのビルドを行う（サーバよりクライアントの方が速いし、そのためのクロスコンパイル）
  * バイナリの配置とmysql, nginxの設定ファイルの配置/再起動を行う
* alpとpt-query-digest, pprofを利用してパフォーマンス計測
  * 後ほどスクリプト化など

## 確認したいこと

* サーバ分離するときの方法
