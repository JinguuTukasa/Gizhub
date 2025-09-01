# GizHub 開発用 Makefile
# 使い方: `make` または `make help`

.DEFAULT_GOAL := help
SHELL := /bin/bash

# コマンド/サービス名
DC := docker-compose
APP := app
FE := frontend
DB := db
REDIS := redis
ECHO := echo-server

ENV_FILE := .env
ENV_EXAMPLE := .env.example

.PHONY: help init env env-create env-sync up up-bg build down restart ps logs clean \
	app-setup fe-setup fe-dev echo-start echo-logs fe-logs \
	storage-fix app-shell fe-shell db-shell redis-cli \
	migrate migrate-seed migrate-refresh keygen cache-clear cache-rebuild test \
	fresh check-db seed-safe check-fe

help: ## 利用可能なターゲット一覧を表示
	@echo "\nGizHub Make ターゲット一覧" && \
	awk 'BEGIN {FS = ":.*?## "}; /^[a-zA-Z0-9_.-]+:.*?## / {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: env up storage-fix env-sync app-setup fe-setup fe-dev ## 初期セットアップ一括実行（env生成→起動→権限→env同期→Laravel/FEセットアップ→FE開発サーバー起動）

env: ## .env が無ければ .env.example から作成
	@if [ ! -f $(ENV_FILE) ]; then \
		if [ -f $(ENV_EXAMPLE) ]; then \
			cp $(ENV_EXAMPLE) $(ENV_FILE); \
			echo "[OK] .env を作成しました"; \
		else \
			echo "[WARN] .env.example が見つかりません。README を参照して手動作成してください"; \
		fi; \
	else \
		echo "[SKIP] .env は既に存在します"; \
	fi

up: ## コンテナをビルドして起動（バックグラウンド）+ フロントエンド開発サーバー起動
	$(DC) up -d
	@echo ""
	@echo "=== フロントエンド開発サーバー起動 ==="
	@echo "フロントエンド開発サーバーを起動します..."
	@echo "Ctrl+C で停止できます"
	@echo ""
	@echo "🌐 アクセスURL:"
	@echo "   React: http://localhost:5173"
	@echo "   Laravel: http://localhost"
	@echo ""
	$(DC) exec $(FE) npm run dev

up-bg: ## コンテナをビルドして起動（バックグラウンド）+ フロントエンド開発サーバーもバックグラウンド起動
	$(DC) up -d
	@echo ""
	@echo "=== フロントエンド開発サーバー起動（バックグラウンド） ==="
	@echo "フロントエンド開発サーバーをバックグラウンドで起動します..."
	@echo "ログは 'make echo-logs' で確認できます"
	@echo ""
	$(DC) exec -d $(FE) npm run dev

stop: ## コンテナとフロントエンド開発サーバーを停止
	@echo ""
	@echo "=== フロントエンド開発サーバー停止 ==="
	@echo "停止中..."
	@echo ""
	-$(DC) exec $(FE) pkill -f "vite" || true
	$(DC) stop
	@echo ""
	@echo "✅ 全てのサービスを停止しました"

build: ## コンテナをキャッシュ無しでビルド
	$(DC) build --no-cache

down: ## コンテナ停止・削除
	$(DC) down

restart: ## コンテナ再起動
	$(DC) restart

ps: ## コンテナ一覧表示
	$(DC) ps

logs: ## すべてのログをフォロー
	$(DC) logs -f

clean: ## ボリューム含めクリーン（データ全削除注意）
	$(DC) down -v --remove-orphans

fresh: clean up ## データ初期化の上、再起動

storage-fix: ## storage 配下の作成と権限調整（Please provide a valid cache path対策）
	$(DC) exec $(APP) mkdir -p storage/framework/views
	$(DC) exec $(APP) chmod -R 777 storage

app-setup: ## Laravel セットアップ（依存/マイグレーション/安全なシーディング/キー/キャッシュ）
	$(DC) exec $(APP) composer install
	$(DC) exec $(APP) php artisan migrate
	$(DC) exec $(APP) php artisan config:clear
	$(DC) exec $(APP) php artisan cache:clear
	$(DC) exec $(APP) php artisan config:cache
	$(DC) exec $(APP) php artisan key:generate
	@echo ""
	@echo "=== シーディング状況 ==="
	@make seed-safe

fe-setup: ## フロントエンド依存をインストール（npm install）
	$(DC) exec $(FE) npm install

fe-dev: ## フロントエンド開発サーバ起動（ログはターミナル出力）
	$(DC) exec $(FE) npm run dev

echo-start: ## Laravel Echo Server 起動
	$(DC) exec $(ECHO) laravel-echo-server start

echo-logs: ## Echo Server のログ表示
	$(DC) logs -f $(ECHO)

fe-logs: ## フロントエンドのログ表示
	$(DC) logs -f $(FE)

app-shell: ## Laravelコンテナに入る
	$(DC) exec $(APP) bash

fe-shell: ## フロントエンドコンテナに入る
	$(DC) exec $(FE) sh

db-shell: ## MySQL コンテナに接続
	$(DC) exec $(DB) mysql -u chat_user -psecret chat_db

redis-cli: ## Redis CLI を起動
	$(DC) exec $(REDIS) redis-cli

migrate: ## マイグレーション実行
	$(DC) exec $(APP) php artisan migrate

migrate-seed: ## マイグレーション + シーディング
	$(DC) exec $(APP) php artisan migrate --seed

migrate-refresh: ## DB再作成 + シーディング
	$(DC) exec $(APP) php artisan migrate:fresh --seed

keygen: ## APP_KEY を再生成
	$(DC) exec $(APP) php artisan key:generate

cache-clear: ## Laravel キャッシュ/設定をクリア
	$(DC) exec $(APP) php artisan config:clear
	$(DC) exec $(APP) php artisan cache:clear

cache-rebuild: ## Laravel 設定キャッシュ再生成
	$(DC) exec $(APP) php artisan config:cache

test: ## Laravel テスト実行
	$(DC) exec $(APP) php artisan test

env-create: ## .env.example が無い場合の手動作成用テンプレート表示
	@echo "=== .env.example テンプレート ==="
	@echo "以下の内容で .env.example を作成してから 'make env' を実行してください:"
	@echo ""
	@echo "APP_NAME=GizHub"
	@echo "APP_ENV=local"
	@echo "APP_KEY="
	@echo "APP_DEBUG=true"
	@echo "APP_URL=http://localhost"
	@echo ""
	@echo "LOG_CHANNEL=stack"
	@echo "LOG_LEVEL=debug"
	@echo ""
	@echo "# Docker環境用のDB設定（docker-compose.ymlと一致）"
	@echo "DB_CONNECTION=mysql"
	@echo "DB_HOST=db"
	@echo "DB_PORT=3306"
	@echo "DB_DATABASE=chat_db"
	@echo "DB_USERNAME=chat_user"
	@echo "DB_PASSWORD=secret"
	@echo ""
	@echo "BROADCAST_DRIVER=redis"
	@echo "CACHE_DRIVER=redis"
	@echo "QUEUE_CONNECTION=database"
	@echo "SESSION_DRIVER=redis"
	@echo "SESSION_LIFETIME=120"
	@echo ""
	@echo "# Docker環境用のRedis設定"
	@echo "REDIS_CLIENT=phpredis"
	@echo "REDIS_HOST=redis"
	@echo "REDIS_PASSWORD=null"
	@echo "REDIS_PORT=6379"
	@echo ""
	@echo "VIEW_COMPILED_PATH=/var/www/html/storage/framework/views"

env-sync: ## ホストの.envファイルをコンテナに同期
	@if [ -f $(ENV_FILE) ]; then \
		docker cp $(ENV_FILE) laravel_app:/var/www/html/.env; \
		echo "[OK] .env をコンテナに同期しました"; \
	else \
		echo "[WARN] .env ファイルが見つかりません"; \
	fi

check-db: ## DB接続テスト
	@echo "=== DB接続確認 ==="
	@echo "1. コンテナ状態確認:"
	$(DC) ps
	@echo ""
	@echo "2. DB接続テスト:"
	$(DC) exec $(DB) mysql -u chat_user -psecret -e "SELECT 'DB接続OK' as status;"
	@echo ""
	@echo "3. Laravel側からの接続テスト:"
	$(DC) exec $(APP) php artisan migrate:status || echo "Laravel DB接続エラー - .env設定を確認してください"

seed-safe: ## 安全なシーディング（既存データがある場合はスキップ）
	@echo "=== 安全なシーディング実行 ==="
	@echo "1. 既存データ確認:"
	@if docker-compose exec db mysql -u chat_user -psecret chat_db -e "SELECT COUNT(*) as count FROM users;" 2>/dev/null | grep -q "0"; then \
		echo "   → データが存在しません。シーディングを実行します。"; \
		$(DC) exec $(APP) php artisan db:seed; \
	else \
		echo "   → 既存データが存在します。シーディングをスキップします。"; \
		echo "   → 必要に応じて 'make migrate-refresh' でDBをリセットしてください。"; \
	fi

check-fe: ## フロントエンド接続テスト
	@echo "=== フロントエンド接続確認 ==="
	@echo "1. コンテナ状態確認:"
	$(DC) ps | grep frontend || echo "   → フロントエンドコンテナが見つかりません"
	@echo ""
	@echo "2. HTTP接続テスト:"
	@if curl -s -o /dev/null -w "%{http_code}" http://localhost:5173 | grep -q "200"; then \
		echo "   ✅ http://localhost:5173 にアクセス可能"; \
	elif curl -s -o /dev/null -w "%{http_code}" http://localhost:5174 | grep -q "200"; then \
		echo "   ✅ http://localhost:5174 にアクセス可能（ポート変更）"; \
	else \
		echo "   ❌ フロントエンドにアクセスできません"; \
		echo "   → 'make fe-logs' でログを確認してください"; \
	fi
	@echo ""
	@echo "3. アクセスURL:"
	@echo "   🌐 React: http://localhost:5173 または http://localhost:5174"
	@echo "   🖥️  Laravel: http://localhost"
