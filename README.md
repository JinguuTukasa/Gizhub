# GizHub 開発環境セットアップガイド

このリポジトリは、**Laravel + React + Laravel Echo Server + Redis + MySQL + Nginx + Coturn** をDockerで統合した、リアルタイムチャット等の開発用フルスタック環境です。

---

## 📦 構成概要

- **Laravel (PHP)** : バックエンドAPI
- **React (Vite)** : フロントエンドSPA
- **MySQL** : データベース
- **Redis** : キャッシュ & WebSocket用
- **Laravel Echo Server** : WebSocketサーバー
- **Nginx** : リバースプロキシ
- **Coturn** : STUN/TURNサーバー（WebRTC用）

各サービスはDocker Composeで一括起動・停止できます。

---

## 🗂️ ディレクトリ構成（抜粋）

```
GizHub/
├── app/           # Laravel本体
├── frontend/      # Reactフロントエンド
├── db/            # MySQL用Dockerfile等
├── redis/         # Redis用Dockerfile等
├── echo-server/   # Laravel Echo Server
├── nginx/         # Nginx設定
├── coturn/        # Coturn設定
├── docker-compose.yml
└── README.md
```

---

## 🚀 セットアップ手順

1. **リポジトリをクローン**
   ```sh
   git clone https://github.com/JinguuTukasa/Gizhub
   cd Gizhub
   ```

2. **.envファイルを作成**
   ```sh
   cp .env.example .env
   # 必要に応じて.envを編集
   ```

3. **Dockerコンテナを起動**
   ```sh
   docker-compose up -d --build
   ```

4. **Laravelセットアップ**
   ```sh
   docker-compose exec app composer install
   docker-compose exec app php artisan migrate --seed
   docker-compose exec app php artisan config:clear
   docker-compose exec app php artisan cache:clear
   docker-compose exec app php artisan config:cache
   docker-compose exec app php artisan key:generate
   ```

5. **フロントエンドセットアップ**
   ```sh
   docker-compose exec frontend npm install
   docker-compose exec frontend npm run dev
   ```

6. **Laravel Echo Server 起動**
   ```sh
   docker-compose exec echo-server laravel-echo-server start
   ```

---

## ⚙️ .env 設定例

`.env.example` を参考に、必要な値を設定してください。

```
APP_NAME=GizHub
APP_ENV=local
APP_KEY=base64:xxxxxxxxxxxxxxxxxxx
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=db
DB_PORT=3306
DB_DATABASE=chat_db
DB_USERNAME=chat_user
DB_PASSWORD=secret

REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PORT=6379

BROADCAST_DRIVER=redis
QUEUE_CONNECTION=database
SESSION_DRIVER=redis
CACHE_DRIVER=redis

VIEW_COMPILED_PATH=/var/www/html/storage/framework/views
```

---

## ✅ 動作確認チェックリスト

| 項目 | コマンド | 期待される結果 |
|------|----------|----------------|
| Dockerコンテナ | `docker-compose ps` | すべてUp |
| MySQL接続 | `docker-compose exec db mysql -u chat_user -psecret chat_db` | `mysql>`表示 |
| Laravel DB接続 | `docker-compose exec app php artisan migrate:status` | マイグレーション一覧 |
| Redis接続 | `docker-compose exec redis redis-cli ping` | `PONG` |
| Echo Server | `docker-compose logs echo-server` | `Server ready!` |
| フロント表示 | [http://localhost:5173](http://localhost:5173) | SPA表示 |
| Nginx経由 | [http://localhost](http://localhost) | Laravel画面 |

---

## 💡 よくある質問・トラブルシュート

- **Q. .envファイルが無い/エラーになる**
  - → `.env.example` をコピーして `.env` を作成してください。
- **Q. ポート競合で起動できない**
  - → 他のサービスが同じポートを使っていないか確認してください。
- **Q. DB接続エラー**
  - → `.env` のDB設定と `docker-compose.yml` の値が一致しているか確認。

---

## 📝 補足

- **.gitignore** で `node_modules/` や `storage/` などは除外済みです。
- **初回セットアップ後は、READMEの手順通りに進めればOKです。**
- **不明点やトラブルはこのREADMEを見直してください。**
