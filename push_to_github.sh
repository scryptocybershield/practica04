#!/bin/bash
# Script simplificado para subir a GitHub usando token de variable de entorno
# Uso: 
#   export GITHUB_TOKEN="tu_token_aqui"
#   ./push_to_github.sh https://github.com/usuario/repo.git

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

REPO_URL="${1}"

echo -e "${BLUE}=== Push to GitHub ===${NC}"
echo ""

# Verificar que se pasó la URL
if [ -z "$REPO_URL" ]; then
    echo -e "${RED}Error: Debes proporcionar la URL del repositorio${NC}"
    echo "Uso: ./push_to_github.sh https://github.com/usuario/repo.git"
    exit 1
fi

# Verificar que existe GITHUB_TOKEN
if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${RED}Error: Variable GITHUB_TOKEN no está configurada${NC}"
    echo ""
    echo "Pasos:"
    echo "1. Crea un token en: https://github.com/settings/tokens"
    echo "2. Selecciona scope 'repo'"
    echo "3. Exporta el token:"
    echo "   export GITHUB_TOKEN='tu_token_aqui'"
    echo "4. Ejecuta de nuevo este script"
    exit 1
fi

# Configurar Git si no está configurado
if ! git config --global user.name > /dev/null 2>&1; then
    read -p "Introduce tu nombre para Git: " git_name
    git config --global user.name "$git_name"
fi

if ! git config --global user.email > /dev/null 2>&1; then
    read -p "Introduce tu email para Git: " git_email
    git config --global user.email "$git_email"
fi

echo -e "${GREEN}Configuración Git:${NC}"
echo "Nombre: $(git config --global user.name)"
echo "Email: $(git config --global user.email)"
echo ""

# Extraer usuario de la URL
GITHUB_USER=$(echo "$REPO_URL" | sed -n 's/.*github\.com[:/]\([^/]*\)\/.*/\1/p')

if [ -z "$GITHUB_USER" ]; then
    echo -e "${RED}Error: No se pudo extraer el usuario de la URL${NC}"
    exit 1
fi

echo -e "${YELLOW}Usuario GitHub: ${GITHUB_USER}${NC}"
echo -e "${YELLOW}Repositorio: ${REPO_URL}${NC}"
echo ""

# Crear URL con token
AUTH_URL=$(echo "$REPO_URL" | sed "s|https://|https://${GITHUB_USER}:${GITHUB_TOKEN}@|")

# Añadir o actualizar remote
if git remote get-url origin 2>/dev/null; then
    echo -e "${YELLOW}Actualizando remote origin...${NC}"
    git remote set-url origin "$AUTH_URL"
else
    echo -e "${GREEN}Añadiendo remote origin...${NC}"
    git remote add origin "$AUTH_URL"
fi

# Cambiar a branch main
echo -e "${GREEN}Cambiando a branch main...${NC}"
git branch -M main

# Hacer commit si no existe
if ! git log -1 > /dev/null 2>&1; then
    echo -e "${GREEN}Haciendo commit inicial...${NC}"
    git commit -m "Initial commit: Docker Compose multi-service architecture

- Nginx load balancer
- 3 Apache PHP servers
- PostgreSQL (write/read/bi)
- Redis cache
- RabbitMQ message queue
- MinIO S3 storage
- Metabase BI
- Tomcat legacy app
- MariaDB

Docker Hub images:
- s4lvaborjamoll/practica4-apache-php:1.0.0
- s4lvaborjamoll/practica4-task-agent:1.0.0

Security: Only port 80 exposed (loadbalancer)"
fi

# Push a GitHub
echo ""
echo -e "${GREEN}Subiendo a GitHub...${NC}"
git push -u origin main

# Limpiar URL con token del remote (por seguridad)
git remote set-url origin "$REPO_URL"

echo ""
echo -e "${GREEN}=== ¡Éxito! ===${NC}"
echo "Tu proyecto está en: $REPO_URL"
echo ""
echo -e "${BLUE}Los usuarios pueden desplegar con:${NC}"
echo "git clone $REPO_URL"
echo "cd $(basename $REPO_URL .git)"
echo "cp .env.example .env"
echo "# Editar .env con credenciales"
echo "export DOCKERHUB_USER=s4lvaborjamoll"
echo "docker-compose -f docker-compose.prod.yml up -d"
