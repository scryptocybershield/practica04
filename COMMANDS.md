# Comandos de Ejecución - Práctica Docker Compose

Este documento contiene los comandos esenciales para interactuar con los servicios de la arquitectura. Dado que solo el balanceador expone el puerto 80 al exterior, la mayoría de los servicios requieren acceso interno a través de comandos `docker exec` o conexiones desde otros contenedores.

## 📋 Convenciones
- `[SERVICIO]`: Nombre del servicio en docker-compose.yml
- Los comandos deben ejecutarse desde el directorio `practica4/`
- Usar `sudo` si Docker lo requiere en su sistema

## 🚀 Gestión de Docker Compose

### Desplegar todos los servicios
```bash
docker-compose up -d
```

### Desplegar servicios específicos
```bash
# Solo balanceador y front-end
docker-compose up -d loadbalancer apache1 apache2 apache3

# Solo back-end (bases de datos, cache, colas)
docker-compose up -d postgres_write postgres_read redis rabbitmq

# Solo inteligencia de negocio
docker-compose up -d metabase postgres_bi

# Solo aplicación heredada
docker-compose up -d tomcat mariadb
```

### Ver estado de los servicios
```bash
# Listar servicios y estado
docker-compose ps

# Ver logs en tiempo real
docker-compose logs -f

# Ver logs de un servicio específico
docker-compose logs [SERVICIO]

# Ver logs con timestamp
docker-compose logs -f --tail=100 --timestamps
```

### Detener servicios
```bash
# Detener todos los servicios (mantiene volúmenes)
docker-compose down

# Detener y eliminar volúmenes (¡CUIDADO! Elimina datos)
docker-compose down -v

# Detener un servicio específico
docker-compose stop [SERVICIO]

# Reiniciar un servicio
docker-compose restart [SERVICIO]
```

### Construir/reconstruir imágenes
```bash
# Construir todas las imágenes
docker-compose build

# Reconstruir imágenes sin cache
docker-compose build --no-cache

# Construir imagen específica
docker-compose build [SERVICIO]
```

## 🔍 Verificación y Monitorización

### Health checks manuales
```bash
# Verificar health status de todos los servicios
docker-compose ps

# Verificar logs de health checks
docker-compose logs | grep -i "health\|healthy\|unhealthy"

# Verificar estado de redes
docker network ls
docker network inspect practica4_web_net
docker network inspect practica4_app_net
docker network inspect practica4_functional_db_net
docker network inspect practica4_legacy_db_net
```

### Estadísticas y recursos
```bash
# Ver uso de recursos de contenedores
docker stats

# Ver información detallada de un contenedor
docker inspect [NOMBRE_CONTENEDOR]

# Ver procesos ejecutándose en un contenedor
docker top [NOMBRE_CONTENEDOR]
```

## 🔗 Acceso a Servicios Internos

### Balanceador de Carga (Nginx) - Único acceso externo
```bash
# Acceso desde navegador
http://localhost

# Health check externo
curl http://localhost/health

# Ver configuración Nginx
docker-compose exec loadbalancer cat /etc/nginx/nginx.conf

# Probar conectividad a MinIO desde balanceador
docker-compose exec loadbalancer curl -f http://minio:9000/minio/health/live || echo "MinIO no accesible desde balanceador"

# Ver logs de Nginx
docker-compose exec loadbalancer tail -f /var/log/nginx/access.log
```

### Servidores Apache (Front-end)
```bash
# Acceso interno desde balanceador
curl http://apache1/
curl http://apache2/
curl http://apache3/

# Ejecutar comandos dentro de Apache
docker-compose exec -it apache1 bash
docker-compose exec apache1 php -v
docker-compose exec apache1 apache2ctl status

# Ver logs de Apache
docker-compose exec apache1 tail -f /var/log/apache2/access.log
docker-compose exec apache1 tail -f /var/log/apache2/error.log
```

### Bases de Datos PostgreSQL

#### PostgreSQL Principal (escritura)
```bash
# Conectar a PostgreSQL write
docker-compose exec -it postgres_write psql -U appuser -d appdb

# Comandos útiles dentro de psql
\list  # Listar bases de datos
\dt    # Listar tablas
\q     # Salir

# Ejecutar consultas desde bash
docker-compose exec postgres_write psql -U appuser -d appdb -c "SELECT version();"
docker-compose exec postgres_write psql -U appuser -d appdb -c "SELECT current_database();"

# Backup de base de datos
docker-compose exec postgres_write pg_dump -U appuser appdb > backup.sql
```

#### PostgreSQL Secundaria (lectura)
```bash
# Conectar a PostgreSQL read
docker-compose exec -it postgres_read psql -U appuser -d appdb
```

#### PostgreSQL de Metabase
```bash
# Conectar a PostgreSQL BI
docker-compose exec -it postgres_bi psql -U metabase -d metabase
```

### Redis (Cache)
```bash
# Conectar a Redis CLI
docker-compose exec -it redis redis-cli

# Comandos Redis útiles
PING
INFO
KEYS *
GET [key]
SET [key] [value]

# Comandos desde bash
docker-compose exec redis redis-cli ping
docker-compose exec redis redis-cli info
```

### RabbitMQ (Cola de Mensajes)
```bash
# Ver estado de RabbitMQ
docker-compose exec rabbitmq rabbitmqctl status

# Listar colas
docker-compose exec rabbitmq rabbitmqctl list_queues

# Listar usuarios
docker-compose exec rabbitmq rabbitmqctl list_users

# Acceso a consola de administración (desde otro contenedor)
# Primero, ejecutar curl desde un contenedor con acceso a app_net:
docker run --rm --network=practica4_app_net curlimages/curl curl -u rabbituser:rabbitpass http://rabbitmq:15672/api/overview
```

### MinIO (Almacenamiento S3)
```bash
# Ver estado de MinIO
docker-compose exec minio mc admin info local/

# Listar buckets (desde otro contenedor con acceso a web_net)
docker run --rm --network=practica4_web_net minio/mc alias set local http://minio:9000 minioadmin minioadmin
docker run --rm --network=practica4_web_net minio/mc ls local/

# Usar cliente mc dentro del contenedor MinIO
docker-compose exec -it minio mc alias set local http://localhost:9000 minioadmin minioadmin
docker-compose exec minio mc ls local
```

### Metabase (BI)
```bash
# Ver logs de Metabase
docker-compose exec metabase tail -f /logs/metabase.log

# Verificar estado de salud
docker-compose exec metabase curl -f http://localhost:3000/api/health

# Acceso temporal (exponer puerto para desarrollo)
# 1. Detener metabase actual
docker-compose stop metabase

# 2. Ejecutar con puerto expuesto temporalmente
docker run --rm -p 3000:3000 \
  --network=practica4_functional_db_net \
  -e MB_DB_TYPE=postgres \
  -e MB_DB_HOST=postgres_bi \
  -e MB_DB_PORT=5432 \
  -e MB_DB_DBNAME=metabase \
  -e MB_DB_USER=metabase \
  -e MB_DB_PASS=metabase \
  metabase/metabase:latest

# 3. Restaurar configuración original después
docker-compose up -d metabase
```

### Aplicación Heredada (Tomcat)
```bash
# Ver logs de Tomcat
docker-compose exec tomcat tail -f /usr/local/tomcat/logs/catalina.out

# Acceder a aplicación JSP (desde otro contenedor con legacy_db_net)
docker run --rm --network=practica4_legacy_db_net curlimages/curl http://tomcat:8080/info.jsp

# Conectar a shell de Tomcat
docker-compose exec -it tomcat bash

# Listar aplicaciones desplegadas
docker-compose exec tomcat ls /usr/local/tomcat/webapps/
```

### MariaDB (Legacy Database)
```bash
# Conectar a MariaDB
docker-compose exec -it mariadb mysql -u root -prootpass legacy_db

# Comandos útiles dentro de mysql
SHOW DATABASES;
USE legacy_db;
SHOW TABLES;
SELECT * FROM [tabla];

# Comandos desde bash
docker-compose exec mariadb mysql -u root -prootpass -e "SHOW DATABASES;"
```

### Task Agent (Consumidor PHP)
```bash
# Ver logs del task agent
docker-compose logs task_agent

# Ver procesos PHP
docker-compose exec task_agent ps aux | grep php

# Ejecutar comandos en el task agent
docker exec -it practica4_task_agent_1 bash
docker-compose exec task_agent php -v
```

## 🧪 Pruebas de Conectividad entre Servicios

### Desde Apache (acceso a todos los servicios)
```bash
# Probar conexión a Redis
docker-compose exec apache1 curl -f http://redis:6379 || echo "Redis no responde HTTP, pero puede estar funcionando"

# Probar conexión a RabbitMQ
docker-compose exec apache1 curl -f http://rabbitmq:15672 || echo "RabbitMQ management no accesible"

# Probar conexión a PostgreSQL
docker-compose exec apache1 pg_isready -h postgres_write -U appuser -d appdb

# Probar conexión a MinIO
docker-compose exec apache1 curl -f http://minio:9000/minio/health/live

# Probar conexión a Tomcat
docker-compose exec apache1 curl -f http://tomcat:8080/info.jsp
```

### Desde Metabase
```bash
# Probar conexión a PostgreSQL BI
docker-compose exec metabase pg_isready -h postgres_bi -U metabase -d metabase

# Probar conexión a Tomcat
docker-compose exec metabase curl -f http://tomcat:8080/info.jsp
```

### Desde contenedores temporales
```bash
# Probar red web_net
docker run --rm --network=practica4_web_net curlimages/curl http://loadbalancer/health
docker run --rm --network=practica4_web_net curlimages/curl -f http://minio:9000/minio/health/live || echo "MinIO health check falló (puede estar funcionando)"

# Probar red app_net
docker run --rm --network=practica4_app_net curlimages/curl http://redis:6379 || echo "Redis funciona (no HTTP)"

# Probar red functional_db_net
docker run --rm --network=practica4_functional_db_net postgres:15-alpine pg_isready -h postgres_write -U appuser

# Probar red legacy_db_net
docker run --rm --network=practica4_legacy_db_net curlimages/curl http://tomcat:8080/info.jsp
```

## 🔧 Troubleshooting

### Servicios no arrancan
```bash
# Ver logs detallados
docker-compose logs --tail=100 [SERVICIO]

# Verificar dependencias
docker-compose ps

# Verificar health checks
docker-compose ps | grep -v "Up (healthy)"

# Forzar recreación de contenedor
docker-compose up -d --force-recreate [SERVICIO]
```

### Problemas de red
```bash
# Verificar que los contenedores están en las redes correctas
docker inspect practica4_apache1_1 | grep -A 10 Networks

# Probar DNS interno
docker-compose exec apache1 nslookup postgres_write
docker-compose exec apache1 nslookup redis
docker-compose exec apache1 nslookup tomcat

# Verificar conectividad básica
docker-compose exec apache1 ping -c 3 postgres_write
docker-compose exec apache1 ping -c 3 redis
```

### Problemas de volumen
```bash
# Ver volúmenes creados
docker volume ls | grep practica4

# Inspeccionar volumen
docker volume inspect practica4_postgres_write_data

# Limpiar volúmenes (¡CUIDADO! Elimina datos)
docker-compose down -v
docker volume prune -f
```

### Recursos del sistema
```bash
# Ver uso de memoria y CPU
docker stats --no-stream

# Ver espacio en disco
docker system df

# Limpiar recursos no utilizados
docker system prune -f
```

## 📊 Comandos Avanzados

### Ejecutar migraciones o scripts
```bash
# Ejecutar script SQL en PostgreSQL
docker exec -i practica4_postgres_write_1 psql -U appuser -d appdb < migracion.sql

# Ejecutar script en MariaDB
docker exec -i practica4_mariadb_1 mysql -u root -prootpass legacy_db < migracion_legacy.sql

# Ejecutar script PHP en Apache
docker-compose exec apache1 php /var/www/html/script.php
```

### Monitoreo en tiempo real
```bash
# Dashboard combinado
watch -n 2 'echo "=== SERVICIOS ==="; docker-compose ps; echo -e "\n=== RECURSOS ==="; docker stats --no-stream'

# Logs combinados
docker-compose logs -f --tail=10 2>&1 | grep -E "(ERROR|WARN|Exception|failed)"
```

### Backup y Restauración
```bash
# Backup de todas las bases de datos
docker-compose exec postgres_write pg_dumpall -U appuser > backup_postgres_all.sql
docker-compose exec postgres_bi pg_dumpall -U metabase > backup_metabase.sql
docker-compose exec mariadb mysqldump -u root -prootpass --all-databases > backup_mariadb.sql

# Backup de volúmenes
docker run --rm -v practica4_postgres_write_data:/volume -v $(pwd):/backup alpine tar czf /backup/postgres_write_backup.tar.gz -C /volume ./
```

## 🎯 Comandos Rápidos de Referencia

```bash
# Estado rápido
alias dcps='docker-compose ps'
alias dclogs='docker-compose logs -f --tail=50'
alias dcrestart='docker-compose restart'

# Acceso rápido a shells
alias apache1sh='docker-compose exec -it apache1 bash'
alias pgsqlsh='docker-compose exec -it postgres_write psql -U appuser -d appdb'
alias redissh='docker-compose exec -it redis redis-cli'
alias tomcatsh='docker-compose exec -it tomcat bash'

# Health checks rápidos
alias health='curl http://localhost/health'
alias health-all='docker-compose ps | grep -E "(Up|healthy|unhealthy)"'
```

---

**Nota**: Los nombres de contenedores pueden variar (`practica4_apache1_1`). Use `docker ps` para ver los nombres exactos en su sistema.

**Recordatorio**: Solo el balanceador (puerto 80) es accesible desde el exterior. Para acceder a otros servicios use `docker exec` o configure un proxy temporal si es necesario durante el desarrollo.