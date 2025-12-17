#!/bin/bash

source ./scripts/import-env.sh .env

BACKEND_ROOT=$TODO_EXPRESS_SERVER_SRC_DIR
FRONTEND_ROOT=$TODO_NEXT_SRC_DIR
LOCAL_DOCKER_ROOT=$DEPLOYMENT_SRC_DIR

EXPRESS_DOCKERFILE="${BACKEND_ROOT}/Dockerfile.dev"
POSTGRESQL_DOCKERFILE="${LOCAL_DOCKER_ROOT}/dockerfiles/postgresql/Dockerfile.dev"
MINIO_DOCKERFILE="${LOCAL_DOCKER_ROOT}/dockerfiles/minio/Dockerfile.dev"
NEXT_DOCKERFILE="${FRONTEND_ROOT}/Dockerfile.dev"

# Minikubeコンテナ内にimageをbuildする
eval $(minikube docker-env)

echo "Building Express server image..."
docker build -t express:latest -f "${EXPRESS_DOCKERFILE}" "${BACKEND_ROOT}"

echo "Building PostgresQL server image..."
docker build -t postgresql:latest -f "${POSTGRESQL_DOCKERFILE}" "${LOCAL_DOCKER_ROOT}/dockerfiles/postgresql"

echo "Building MinIO image..."
docker build -t minio:latest -f "${MINIO_DOCKERFILE}" "${LOCAL_DOCKER_ROOT}/dockerfiles/minio"

echo "Building Next.js server image..."
docker build -t next:latest -f "${NEXT_DOCKERFILE}" "${FRONTEND_ROOT}"

echo "All images built successfully in Minikube context"
