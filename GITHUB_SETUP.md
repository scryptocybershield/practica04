# 📋 Guía: Subir Proyecto a GitHub

## Paso 1: Crear repositorio en GitHub

1. Ve a https://github.com/new
2. Nombre del repositorio: `practica4-docker-compose` (o el que prefieras)
3. Descripción: "Arquitectura web completa con Docker Compose - Balanceo de carga, microservicios, bases de datos"
4. **Importante**: Selecciona **"Public"** para que otros puedan clonar
5. **NO** marques "Add a README file" (ya tenemos uno)
6. Click en **"Create repository"**

---

## Paso 2: Configurar Git local (si no está configurado)

```bash
# Verificar configuración actual
git config --global user.name
git config --global user.email

# Si no está configurado, configurar:
git config --global user.name "Tu Nombre"
git config --global user.email "tu-email@example.com"
```

---

## Paso 3: Inicializar y subir el repositorio

```bash
cd /home/salviubuntu/puesta_en_produccion/practica4

# Inicializar Git
git init

# Añadir todos los archivos
git add .

# Hacer commit inicial
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

# Añadir remote (REEMPLAZA con tu URL de GitHub)
git remote add origin https://github.com/TU-USUARIO/practica4-docker-compose.git

# Cambiar a branch main
git branch -M main

# Subir a GitHub
git push -u origin main
```

---

## Paso 4: Autenticación con GitHub

Cuando hagas `git push`, GitHub te pedirá autenticación. Tienes 2 opciones:

### Opción A: Personal Access Token (Recomendado)

1. Ve a https://github.com/settings/tokens
2. Click en "Generate new token" → "Generate new token (classic)"
3. Nombre: "practica4-upload"
4. Selecciona scope: **repo** (marcar todo)
5. Click "Generate token"
6. **COPIA EL TOKEN** (solo se muestra una vez)
7. Cuando Git pida contraseña, pega el token

### Opción B: GitHub CLI (gh)

```bash
# Instalar GitHub CLI
sudo apt install gh

# Login
gh auth login

# Seguir las instrucciones interactivas
```

---

## Paso 5: Verificar en GitHub

1. Ve a tu repositorio: `https://github.com/TU-USUARIO/practica4-docker-compose`
2. Verifica que todos los archivos estén subidos
3. El README.md se mostrará automáticamente

---

## Paso 6: Actualizar README con URL del repositorio

Una vez subido, actualiza estos archivos con la URL real:

- `README.md`
- `DEPLOYMENT.md`
- `DOCKERHUB.md`

Reemplaza `<URL_REPOSITORIO>` con:
```
https://github.com/TU-USUARIO/practica4-docker-compose.git
```

---

## 🎯 URL Final para Usuarios

Los usuarios podrán desplegar con:

```bash
git clone https://github.com/TU-USUARIO/practica4-docker-compose.git
cd practica4-docker-compose
cp .env.example .env
# Editar .env
export DOCKERHUB_USER=s4lvaborjamoll
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📝 Notas Importantes

- ✅ El archivo `.gitignore` ya está configurado
- ✅ El archivo `.env` NO se subirá (está en .gitignore)
- ✅ Solo se sube `.env.example` (plantilla sin secretos)
- ✅ Las imágenes Docker ya están en Docker Hub

---

## 🔄 Actualizaciones Futuras

Para subir cambios:

```bash
git add .
git commit -m "Descripción de los cambios"
git push
```
