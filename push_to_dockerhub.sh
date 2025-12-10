#!/bin/bash
# Script para publicar imágenes en Docker Hub
# Uso: ./push_to_dockerhub.sh [DOCKERHUB_USER] [VERSION]

set -e

# Configuración
DOCKERHUB_USER="${1:-yourusername}"
VERSION="${2:-1.0.0}"
PROJECT_NAME="practica4"

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Pushing Images to Docker Hub ===${NC}"
echo -e "${YELLOW}Docker Hub User: ${DOCKERHUB_USER}${NC}"
echo -e "${YELLOW}Version: ${VERSION}${NC}"
echo ""

# Verificar que el usuario está logueado
if ! docker info | grep -q "Username: ${DOCKERHUB_USER}"; then
    echo -e "${YELLOW}Please login to Docker Hub first:${NC}"
    docker login
fi

# Push Apache PHP image
echo -e "${GREEN}Pushing Apache PHP image...${NC}"
docker push ${DOCKERHUB_USER}/${PROJECT_NAME}-apache-php:${VERSION}
docker push ${DOCKERHUB_USER}/${PROJECT_NAME}-apache-php:latest
echo -e "${GREEN}✓ Apache PHP image pushed successfully${NC}"
echo ""

# Push Task Agent image
echo -e "${GREEN}Pushing Task Agent image...${NC}"
docker push ${DOCKERHUB_USER}/${PROJECT_NAME}-task-agent:${VERSION}
docker push ${DOCKERHUB_USER}/${PROJECT_NAME}-task-agent:latest
echo -e "${GREEN}✓ Task Agent image pushed successfully${NC}"
echo ""

echo -e "${GREEN}=== Push Complete ===${NC}"
echo ""
echo -e "${BLUE}Images available at:${NC}"
echo "  - https://hub.docker.com/r/${DOCKERHUB_USER}/${PROJECT_NAME}-apache-php"
echo "  - https://hub.docker.com/r/${DOCKERHUB_USER}/${PROJECT_NAME}-task-agent"
echo ""
echo -e "${YELLOW}Users can now deploy with:${NC}"
echo "  export DOCKERHUB_USER=${DOCKERHUB_USER}"
echo "  docker-compose -f docker-compose.prod.yml up -d"
