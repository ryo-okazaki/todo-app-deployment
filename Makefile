up-all:
	$(MAKE) up-todo
	$(MAKE) up-auth

up-todo:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml up -d --build
	docker compose --env-file .env.mail -f compose.mail.local.yaml up -d --build

up-auth:
	docker compose --env-file .env.auth -f compose.auth.local.yaml up -d --build
	docker compose --env-file .env.mail -f compose.mail.local.yaml up -d --build

down-all:
	$(MAKE) down-todo
	$(MAKE) down-auth

down-todo:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml down
	docker compose --env-file .env.mail -f compose.mail.local.yaml down

down-auth:
	docker compose --env-file .env.auth -f compose.auth.local.yaml down
	docker compose --env-file .env.mail -f compose.mail.local.yaml down

restart-todo:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml restart
	docker compose --env-file .env.mail -f compose.mail.local.yaml restart

rebuild-all:
	$(MAKE) rebuild-todo
	$(MAKE) rebuild-auth

rebuild-todo:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml down
	docker compose --env-file .env.mail -f compose.mail.local.yaml down
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml up -d --build
	docker compose --env-file .env.mail -f compose.mail.local.yaml up -d --build

rebuild-auth:
	docker compose --env-file .env.auth -f compose.auth.local.yaml down
	docker compose --env-file .env.auth -f compose.auth.local.yaml up -d --build

bash-auth-kc-tools:
	docker compose --env-file .env.auth -f compose.auth.local.yaml exec auth-kc-tools sh

export-kc-settings:
	docker compose --env-file .env.auth -f compose.auth.local.yaml exec auth-kc-tools bash -c "cd /opt/keycloak/exports/scripts && bash export-realm.sh"

export-kc-settings-details:
	docker compose --env-file .env.auth -f compose.auth.local.yaml exec auth-kc-tools bash -c "cd /opt/keycloak/exports/scripts && bash export-realm-details.sh"

bash-todo-next:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml exec todo-next sh

bash-todo-express:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml exec todo-express sh

bash-todo-postgres:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml exec todo-postgresql sh

migrate-todo:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml exec todo-express npm run migrate:dev

reset-todo:
	docker compose --env-file .env.todo -f compose.todo-app.local.yaml exec todo-express npm run migrate:reset

build-k8s-images:
	bash scripts/build-images.sh

deploy-k8s: build-k8s-images
	bash scripts/deploy-charts.sh

# クリーンアップ
clean-k8s:
	helm uninstall --namespace default $$(helm list -n default -q) 2>/dev/null || true
