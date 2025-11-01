up-todo:
	docker compose -f compose.todo-app.local.yaml up -d --build

up-auth:
	docker compose -f compose.auth.local.yaml up -d --build

down-todo:
	docker compose -f compose.todo-app.local.yaml down

down-auth:
	docker compose -f compose.auth.local.yaml down

restart-todo:
	docker compose -f compose.todo-app.local.yaml restart

rebuild-todo:
	docker compose -f compose.todo-app.local.yaml down
	docker compose -f compose.todo-app.local.yaml up -d --build

bash-auth-keycloak:
	docker compose -f compose.auth.local.yaml exec auth-keycloak sh

bash-todo-next:
	docker compose -f compose.todo-app.local.yaml exec todo-next sh

bash-todo-express:
	docker compose -f compose.todo-app.local.yaml exec todo-express sh

bash-todo-postgres:
	docker compose -f compose.todo-app.local.yaml exec todo-postgresql sh

migrate-todo:
	docker compose -f compose.todo-app.local.yaml exec todo-express npm run migrate:dev

reset-todo:
	docker compose -f compose.todo-app.local.yaml exec todo-express npm run migrate:reset

build-k8s-images:
	bash scripts/build-images.sh

deploy-k8s: build-k8s-images
	bash scripts/deploy-charts.sh

# クリーンアップ
clean-k8s:
	helm uninstall --namespace default $$(helm list -n default -q) 2>/dev/null || true
