#  Guía Rápida - Despliegue Docker Hub

##  Para Desarrolladores: Publicar Imágenes

### 1. Construir las imágenes
```bash
# Sintaxis: ./build_images.sh [DOCKERHUB_USER] [VERSION]
./build_images.sh tuusuario 1.0.0
```

### 2. Login a Docker Hub
```bash
docker login
```

### 3. Publicar a Docker Hub
```bash
# Sintaxis: ./push_to_dockerhub.sh [DOCKERHUB_USER] [VERSION]
./push_to_dockerhub.sh tuusuario 1.0.0
```

**Imágenes publicadas:**
- `tuusuario/practica4-apache-php:1.0.0` y `:latest`
- `tuusuario/practica4-task-agent:1.0.0` y `:latest`

---

##  Para Usuarios: Desplegar desde Docker Hub

### 1. Clonar el repositorio
```bash
git clone <URL_REPOSITORIO>
cd practica4
```

### 2. Configurar variables de entorno
```bash
# Copiar plantilla
cp .env.example .env

# Editar credenciales (IMPORTANTE: cambiar contraseñas)
nano .env

# Configurar usuario de Docker Hub
export DOCKERHUB_USER=tuusuario
```

### 3. Desplegar todos los servicios
```bash
docker-compose -f docker-compose.prod.yml up -d
```

### 4. Verificar estado
```bash
docker-compose -f docker-compose.prod.yml ps
```

---

##  URLs de Acceso

| Servicio | URL | Puerto Expuesto |
|----------|-----|-----------------|
| **Aplicaciones Web** | http://localhost | 80 (solo loadbalancer) |

> **Nota Importante**: Solo el balanceador de carga (Nginx) expone el puerto 80. Todos los demás servicios (Metabase, Tomcat, Apache1/2/3, bases de datos, etc.) son **internos** y solo accesibles a través de las redes Docker internas.

---

## 🛠️ Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose -f docker-compose.prod.yml logs -f

# Ver logs de un servicio específico
docker-compose -f docker-compose.prod.yml logs -f loadbalancer

# Reiniciar un servicio
docker-compose -f docker-compose.prod.yml restart apache1

# Detener todos los servicios
docker-compose -f docker-compose.prod.yml down

# Actualizar a nueva versión
export VERSION=1.1.0
docker-compose -f docker-compose.prod.yml pull
docker-compose -f docker-compose.prod.yml up -d
```

---

## 🐛 Troubleshooting Rápido

**Puerto 80 ocupado:**
```bash
sudo systemctl stop apache2
docker-compose -f docker-compose.prod.yml up -d
```

**Ver estado de salud de servicios:**
```bash
docker-compose -f docker-compose.prod.yml ps
```

**Resetear todo (⚠️ BORRA DATOS):**
```bash
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d
```

---

## 📋 Arquitectura de Puertos

```
Internet
   ↓
Puerto 80 → Nginx (Loadbalancer) ← ÚNICO PUERTO EXPUESTO
              ↓
         [Red Interna]
              ↓
    Apache1, Apache2, Apache3
    Metabase, Tomcat
    PostgreSQL, Redis, RabbitMQ
    MinIO, MariaDB, Task Agent
    (Todos sin puertos expuestos)
```

**Único puerto expuesto:**
- ✅ **Puerto 80**: Loadbalancer (Nginx) - Único punto de acceso

**Todos los demás servicios son internos:**
- ❌ Apache1, Apache2, Apache3 (sin puertos expuestos)
- ❌ Metabase (sin puerto 3000 expuesto)
- ❌ Tomcat (sin puerto 8080 expuesto)
- ❌ PostgreSQL, Redis, RabbitMQ, MinIO, MariaDB, Task Agent (sin puertos expuestos)

---

📚 **Documentación completa:** [DEPLOYMENT.md](DEPLOYMENT.md)
