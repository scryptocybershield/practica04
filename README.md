# Práctica de Docker Compose - Arquitectura Web Completa

## Descripción
Esta práctica implementa una arquitectura web completa utilizando Docker Compose, siguiendo los requisitos especificados en el enunciado.

## Arquitectura

### 1. Balancejador de Càrrega (Nginx)
- Servicio: `loadbalancer`
- Puerto: 80
- Función: Distribuye la carga entre los 3 servidores Apache

### 2. Front-end (3 servidores Apache + PHP)
- Servicios: `apache1`, `apache2`, `apache3`
- Puerto interno: 80
- Función: Servir aplicaciones PHP con balanceo de carga

### 3. Almacenamiento de Objetos (MinIO)
- Servicio: `minio`
- Función: Almacenamiento compatible con S3

### 4. Back-end
- **Bases de datos PostgreSQL**: `postgres_write` (escritura), `postgres_read` (lectura)
- **Cache Redis**: `redis`
- **Cola de mensajes**: `rabbitmq`
- **Agente de tareas**: `task_agent` (PHP)

### 5. Inteligencia de Negocio (Metabase)
- Servicio: `metabase`
- Puerto: 3000
- Base de datos: `postgres_bi`

### 6. Aplicación Heretada
- **Tomcat**: `tomcat` (Puerto: 8080)
- **MariaDB**: `mariadb`

## Redes
- `frontend_net`: Balanceador y servidores Apache
- `backend_net`: Servicios del back-end
- `bi_net`: Metabase y su base de datos
- `legacy_net`: Aplicación heredada

## Instrucciones de Despliegue

### 1. Preparar el entorno
```bash
chmod +x setup_complete.sh
./setup_complete.sh
```

### 2. Desplegar todos los servicios
```bash
docker-compose up -d
```

### 3. Desplegar servicios específicos
```bash
# Solo front-end y balanceador
docker-compose up -d loadbalancer apache1 apache2 apache3

# Solo aplicación legacy
docker-compose up -d tomcat mariadb

# Solo Metabase
docker-compose up -d metabase postgres_bi
```

### 4. Verificar el funcionamiento
- Balanceador: http://localhost
- Tomcat: http://localhost:8080/info.jsp
- Metabase: http://localhost:3000

### 5. Detener y eliminar
```bash
docker-compose down
```

## URLs de Acceso
- **Balanceador de carga**: http://localhost
- **Aplicación legacy (Tomcat)**: http://localhost:8080/info.jsp
- **Metabase (BI)**: http://localhost:3000
- **RabbitMQ Management**: http://localhost:15672 (usuario: rabbituser, contraseña: rabbitpass)
- **MinIO Console**: http://localhost:9001 (usuario: minioadmin, contraseña: minioadmin)

## Estructura del Proyecto
```
├── docker/
│   ├── Dockerfile.apache
│   ├── Dockerfile.task_agent
│   ├── task_agent.php
│   └── nginx.conf
├── src/
│   ├── app1/index.php
│   ├── app2/index.php
│   └── app3/index.php
├── legacy/
│   └── info.jsp
├── db/
│   ├── init.sql
│   └── init_legacy.sql
├── docker-compose.yml
├── setup_complete.sh
└── README.md
```

## Credenciales
- **PostgreSQL**: appuser/apppass
- **RabbitMQ**: rabbituser/rabbitpass
- **MariaDB**: root/rootpass
- **Metabase DB**: metabase/metabase
- **MinIO**: minioadmin/minioadmin

## Notas Técnicas
- Las aplicaciones PHP muestran información del sistema usando `phpinfo()`
- La aplicación legacy muestra propiedades del sistema Java
- El balanceador distribuye carga round-robin entre los 3 servidores Apache
- Los volúmenes de datos son persistentes
