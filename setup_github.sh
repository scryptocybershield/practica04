#!/bin/bash
# Script para subir el proyecto a GitHub
# Uso: ./setup_github.sh

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Setup GitHub Repository ===${NC}"
echo ""

# Verificar si ya hay un remote configurado
if git remote get-url origin 2>/dev/null; then
    echo -e "${YELLOW}Remote 'origin' ya existe:${NC}"
    git remote get-url origin
    echo ""
    read -p "¿Quieres reemplazarlo? (y/n): " replace
    if [ "$replace" = "y" ]; then
        git remote remove origin
    else
        echo "Manteniendo remote existente"
        exit 0
    fi
fi

# Pedir URL del repositorio
echo -e "${YELLOW}Primero, crea un repositorio en GitHub:${NC}"
echo "1. Ve a https://github.com/new"
echo "2. Nombre: practica4-docker-compose (o el que prefieras)"
echo "3. Descripción: Arquitectura web completa con Docker Compose"
echo "4. Público"
echo "5. NO marques 'Add a README file'"
echo "6. Click 'Create repository'"
echo ""

read -p "Introduce la URL del repositorio (ej: https://github.com/usuario/repo.git): " repo_url

if [ -z "$repo_url" ]; then
    echo -e "${RED}Error: URL vacía${NC}"
    exit 1
fi

# Configurar Git si no está configurado
if ! git config --global user.name > /dev/null 2>&1; then
    echo ""
    read -p "Introduce tu nombre para Git: " git_name
    git config --global user.name "$git_name"
fi

if ! git config --global user.email > /dev/null 2>&1; then
    echo ""
    read -p "Introduce tu email para Git: " git_email
    git config --global user.email "$git_email"
fi

echo ""
echo -e "${GREEN}Configuración Git:${NC}"
echo "Nombre: $(git config --global user.name)"
echo "Email: $(git config --global user.email)"
echo ""

# Añadir remote
echo -e "${GREEN}Añadiendo remote...${NC}"
git remote add origin "$repo_url"

# Cambiar a branch main
echo -e "${GREEN}Cambiando a branch main...${NC}"
git branch -M main

# Hacer commit si hay cambios
if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${YELLOW}No hay cambios para commitear${NC}"
else
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
echo -e "${YELLOW}=== Subiendo a GitHub ===${NC}"
echo "Se te pedirá autenticación:"
echo "- Usuario: tu usuario de GitHub"
echo "- Contraseña: usa un Personal Access Token (no tu contraseña)"
echo ""
echo "Para crear un token:"
echo "1. Ve a https://github.com/settings/tokens"
echo "2. Generate new token (classic)"
echo "3. Selecciona scope 'repo'"
echo "4. Copia el token y úsalo como contraseña"
echo ""

read -p "Presiona ENTER para continuar..."

git push -u origin main

echo ""
echo -e "${GREEN}=== ¡Éxito! ===${NC}"
echo "Tu proyecto está ahora en: $repo_url"
echo ""
echo -e "${BLUE}Próximos pasos:${NC}"
echo "1. Ve a tu repositorio en GitHub"
echo "2. Verifica que todos los archivos estén subidos"
echo "3. Comparte la URL con otros usuarios"
echo ""
echo -e "${YELLOW}Los usuarios pueden desplegar con:${NC}"
echo "git clone $repo_url"
echo "cd practica4-docker-compose"
echo "cp .env.example .env"
echo "# Editar .env"
echo "export DOCKERHUB_USER=s4lvaborjamoll"
echo "docker-compose -f docker-compose.prod.yml up -d"
