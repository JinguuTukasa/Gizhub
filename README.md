# GizHub Environment Setup

この README は、GizHub の開発環境（Laravel + React + Laravel Echo Server + Redis + MySQL + Nginx + Coturn）のセットアップ方法と構成をまとめたものです。

---

## 1. 環境構成

| コンポーネント              | 役割                                      | バージョン            |
| --------------------------- | ----------------------------------------- | --------------------- |
| **Laravel (PHP)**           | バックエンド（API）                       | Laravel 11.9 (例)     |
| **React (Vite)**            | フロントエンド                           | React 18 + Vite       |
| **MySQL**                   | データベース                             | MySQL 8               |
| **Redis**                   | キャッシュ & WebSocket 用                 | Redis 7               |
| **Laravel Echo Server**     | WebSocket のサーバー                     | laravel-echo-server 1.6.3 |
| **Nginx**                   | リバースプロキシ                         | Nginx latest          |
| **Coturn**                  | STUN/TURN サーバー（WebRTC）               | instrumentisto/coturn |

---

## 2. Docker Compose 設定

以下は、`docker-compose.yml` の例です。 
このファイルをプロジェクトのルートに保存してください。

```yaml
services:
  app:
    container_name: laravel_app
    build:
      context: ./app
      dockerfile: Dockerfile
    volumes:
      - ./app:/var/www/html
      - ./storage:/var/www/html/storage
      - ./bootstrap/cache:/var/www/html/bootstrap/cache
    depends_on:
      - db
      - redis
    networks:
      - app_network

  db:
    container_name: mysql_db
    image: mysql:8
    environment:
      MYSQL_DATABASE: chat_db
      MYSQL_USER: chat_user
      MYSQL_PASSWORD: secret
      MYSQL_ROOT_PASSWORD: root_password
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3306:3306"
    networks:
      - app_network

  redis:
    container_name: redis_server
    image: redis:7
    networks:
      - app_network

  echo-server:
    container_name: laravel_echo_server
    build:
      context: ./echo-server
      dockerfile: Dockerfile
    ports:
      - "6001:6001"
    depends_on:
      - redis
    networks:
      - app_network

  frontend:
    container_name: react_frontend
    build:
      context: ./frontend
      dockerfile: Dockerfile
    ports:
      - "5173:5173"
    volumes:
      - ./frontend:/usr/src/app
    networks:
      - app_network

  nginx:
    container_name: nginx_server
    build:
      context: ./nginx
      dockerfile: Dockerfile
    ports:
      - "80:80"
    depends_on:
      - app
      - frontend
    networks:
      - app_network

  coturn:
    container_name: coturn_server
    image: instrumentisto/coturn
    ports:
      - "3478:3478/tcp"
      - "3478:3478/udp"
      - "5349:5349/tcp"
      - "5349:5349/udp"
    networks:
      - app_network

networks:
  app_network:

volumes:
  mysql_data:
```

---

## 3. セットアップ手順

### 1️⃣ リポジトリをクローン
```sh
git clone https://github.com/JinguuTukasa/Gizhub
cd Gizhub
```

### 2️⃣ `.env` ファイルの作成
```sh
cp .env.example .env
```

### 3️⃣ Docker コンテナの起動
```sh
docker-compose up -d --build
```

### 4️⃣ Laravel のセットアップ
```sh
docker-compose exec app composer install
docker-compose exec app php artisan migrate --seed
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan key:generate
```

### 5️⃣ フロントエンドのセットアップ
```sh
docker-compose exec frontend npm install
docker-compose exec frontend npm run dev
```

### 6️⃣ Laravel Echo Server の起動
```sh
docker-compose exec echo-server laravel-echo-server start
```

---

## 4. `.env` ファイル設定例

以下の内容を `.env` に記述してください。

```ini
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

## 5. 環境動作確認チェックリスト

| チェック項目 | コマンド | 期待される結果 |
|------------|------------|------------|
| **Docker コンテナの確認** | `docker-compose ps` | すべてのコンテナが `Up` |
| **MySQL 接続確認** | `docker-compose exec db mysql -u chat_user -psecret chat_db` | `mysql>` が表示される |
| **Laravel の DB 接続確認** | `docker-compose exec app php artisan migrate:status` | マイグレーション一覧が表示される |
| **Redis 接続確認** | `docker-compose exec redis redis-cli ping` | `PONG` が返る |
| **Laravel Echo Server 確認** | `docker-compose logs echo-server` | `Server ready!` が表示される |
| **フロントエンド表示確認** | [http://localhost:5173](http://localhost:5173) | フロントエンドが表示される |
| **Nginx 経由でのバックエンド確認** | [http://localhost](http://localhost) | Laravel の画面が表示される |

---

この手順に従えば、どの PC でも環境をすぐにセットアップでき、開発を開始できます！ 🚀
