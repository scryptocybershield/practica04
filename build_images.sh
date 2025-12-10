#!/bin/bash
# Script para construir las imágenes Docker personalizadas
# Uso: ./build_images.sh [DOCKERHUB_USER] [VERSION]

set -e

# Configuración
DOCKERHUB_USER="${1:-yourusername}"
VERSION="${2:-1.0.0}"
PROJECT_NAME="practica4"

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Building Docker Images ===${NC}"
echo -e "${YELLOW}Docker Hub User: ${DOCKERHUB_USER}${NC}"
echo -e "${YELLOW}Version: ${VERSION}${NC}"
echo ""

# Build Apache PHP image
echo -e "${GREEN}Building Apache PHP image...${NC}"
docker build \
    -f docker/Dockerfile.apache \
    -t ${DOCKERHUB_USER}/${PROJECT_NAME}-apache-php:${VERSION} \
    -t ${DOCKERHUB_USER}/${PROJECT_NAME}-apache-php:latest \
    .

echo -e "${GREEN}✓ Apache PHP image built successfully${NC}"
echo ""

# Build Task Agent image
echo -e "${GREEN}Building Task Agent image...${NC}"
docker build \
    -f docker/Dockerfile.task_agent \
    -t ${DOCKERHUB_USER}/${PROJECT_NAME}-task-agent:${VERSION} \
    -t ${DOCKERHUB_USER}/${PROJECT_NAME}-task-agent:latest \
    .

echo -e "${GREEN}✓ Task Agent image built successfully${NC}"
echo ""

# Mostrar imágenes creadas
echo -e "${BLUE}=== Images Created ===${NC}"
docker images | grep "${DOCKERHUB_USER}/${PROJECT_NAME}"

echo ""
echo -e "${GREEN}=== Build Complete ===${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Test images locally: docker-compose -f docker-compose.prod.yml up -d"
echo "2. Push to Docker Hub: ./push_to_dockerhub.sh ${DOCKERHUB_USER} ${VERSION}"
