#!/bin/bash

# Script de configuración completa para la práctica de Docker Compose
# Este script crea toda la estructura de directorios y archivos necesarios

echo "🚀 Configurando estructura completa para la práctica..."

# Crear directorios principales
mkdir -p docker
mkdir -p src/app1
mkdir -p src/app2
mkdir -p src/app3
mkdir -p legacy
mkdir -p db

echo "✅ Directorios principales creados"

# Crear archivos de configuración de Docker
echo "📝 Creando Dockerfiles..."

# Dockerfile para Apache
cat > docker/Dockerfile.apache << 'EOF'
# Dockerfile para servidor Apache con PHP
FROM php:8.3-apache

# Instalar extensiones de PHP básicas (sin PostgreSQL para simplificar)
RUN docker-php-ext-install pdo pdo_mysql

# Habilitar mod_rewrite para Apache
RUN a2enmod rewrite

# Configurar Apache para escuchar en el puerto 80
RUN sed -i 's/Listen 80/Listen 80/' /etc/apache2/ports.conf

# Crear un archivo de configuración para Apache
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Exponer el puerto 80
EXPOSE 80

# Comando para iniciar Apache
CMD ["apache2-foreground"]
EOF

# Dockerfile para el agente de tareas
cat > docker/Dockerfile.task_agent << 'EOF'
# Dockerfile para el agente consumidor de tareas RabbitMQ
FROM php:8.3-cli

# Instalar extensiones de PHP necesarias
RUN docker-php-ext-install pdo pdo_mysql

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Crear directorio de trabajo
WORKDIR /app

# Copiar archivos del agente
COPY docker/task_agent.php /app/

# Comando para ejecutar el agente
CMD ["php", "task_agent.php"]
EOF

# Script del agente de tareas
cat > docker/task_agent.php << 'EOF'
<?php
// Agente consumidor de tareas RabbitMQ (ejemplo)
echo "Agente de tareas RabbitMQ iniciado\n";

// Simular procesamiento de tareas
while (true) {
  echo "Procesando tareas...\n";
  sleep(10); // Esperar 10 segundos entre tareas
}
?>
EOF

# Configuración de Nginx
cat > docker/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

  server {
    listen 80;

    # Balanceador de carga para la carga dinámica (PHP)
    location / {
      proxy_pass http://apache_backend;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Carga estática hacia MinIO (ejemplo)
    location /static/ {
      # En un entorno real, aquí se configuraría la redirección a MinIO
      # Para esta práctica, lo dejamos como ejemplo
      return 404 "MinIO integration not implemented in this demo";
    }
  }
    # Carga estática hacia MinIO (ejemplo)
    location /static/ {
      # En un entorno real, aquí se configuraría la redirección a MinIO
      # Para esta práctica, lo dejamos como ejemplo
      return 404 "MinIO integration not implemented in this demo";
    }
  }
}
EOF

echo "✅ Archivos de Docker creados"

# Crear aplicaciones PHP
echo "📝 Creando aplicaciones PHP..."

# Aplicación 1
cat > src/app1/index.php << 'EOF'
<?php
// Aplicación 1 - Front-end
header('Content-Type: text/html; charset=utf-8');

echo "<h1>🚀 Aplicación 1</h1>";
echo "<p>Esta es la aplicación 1 funcionando correctamente.</p>";
echo "<p>Servidor: " . ($_ENV['APP_NAME'] ?? 'App1') . "</p>";

echo "<h2>Información del sistema:</h2>";
echo "<pre>";
phpinfo(INFO_GENERAL | INFO_CONFIGURATION | INFO_MODULES);
echo "</pre>";
?>
EOF

# Aplicación 2
cat > src/app2/index.php << 'EOF'
<?php
// Aplicación 2 - Front-end
header('Content-Type: text/html; charset=utf-8');

echo "<h1>🚀 Aplicación 2</h1>";
echo "<p>Esta es la aplicación 2 funcionando correctamente.</p>";
echo "<p>Servidor: " . ($_ENV['APP_NAME'] ?? 'App2') . "</p>";

echo "<h2>Información del sistema:</h2>";
echo "<pre>";
phpinfo(INFO_GENERAL | INFO_CONFIGURATION | INFO_MODULES);
echo "</pre>";
?>
EOF

# Aplicación 3
cat > src/app3/index.php << 'EOF'
<?php
// Aplicación 3 - Front-end
header('Content-Type: text/html; charset=utf-8');

echo "<h1>🚀 Aplicación 3</h1>";
echo "<p>Esta es la aplicación 3 funcionando correctamente.</p>";
echo "<p>Servidor: " . ($_ENV['APP_NAME'] ?? 'App3') . "</p>";

echo "<h2>Información del sistema:</h2>";
echo "<pre>";
phpinfo(INFO_GENERAL | INFO_CONFIGURATION | INFO_MODULES);
echo "</pre>";
?>
EOF

echo "✅ Aplicaciones PHP creadas"

# Crear aplicación legacy JSP
echo "📝 Creando aplicación legacy..."

cat > legacy/info.jsp << 'EOF'
<%@ page import="java.util.Properties" %>
<!DOCTYPE html>
<html>
<head>
  <title>Aplicación Heredada - Información del Sistema</title>
  <meta charset="UTF-8">
</head>
<body>
  <h1>🚀 Aplicación Heredada</h1>
  <p>Esta es la aplicación antigua funcionando correctamente.</p>

  <h2>Propiedades del Sistema</h2>
  <pre>
  <%
    Properties props = System.getProperties();
    out.println("<h3>System Properties</h3>");
    for (String key : props.stringPropertyNames()) {
      out.println(key + " = " + props.getProperty(key) + "<br>");
    }
  %>
  </pre>

  <h2>Información del Servidor</h2>
  <p>Server Info: <%= application.getServerInfo() %></p>
  <p>Servlet Version: <%= application.getMajorVersion() %>.<%= application.getMinorVersion() %></p>
  <p>JSP Version: <%= JspFactory.getDefaultFactory().getEngineInfo().getSpecificationVersion() %></p>
</body>
</html>
EOF

echo "✅ Aplicación legacy creada"

# Crear scripts de inicialización de bases de datos
echo "📝 Creando scripts de bases de datos..."

# Script para PostgreSQL principal
cat > db/init.sql << 'EOF'
-- Script de inicialización para la base de datos principal
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (name, email) VALUES
('Usuario 1', 'usuario1@example.com'),
('Usuario 2', 'usuario2@example.com');
EOF

# Script para MariaDB legacy
cat > db/init_legacy.sql << 'EOF'
-- Script de inicialización para MariaDB (Base de datos legacy)
CREATE DATABASE IF NOT EXISTS legacy_db;
USE legacy_db;

CREATE TABLE IF NOT EXISTS legacy_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    report_name VARCHAR(100) NOT NULL,
    report_data TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO legacy_reports (report_name, report_data) VALUES
('Reporte Mensual', 'Datos del reporte mensual'),
('Reporte Anual', 'Datos del reporte anual');
EOF

echo "✅ Scripts de bases de datos creados"

# Crear archivo docker-compose.yml
echo "📝 Creando docker-compose.yml..."

cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  # === 1. BALANCEADOR DE CARGA (Nginx) ===
  loadbalancer:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - ./docker/nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - apache1
      - apache2
      - apache3
    networks:
      - frontend_net

  # === 2. FRONT-END (3 servidors Apache + PHP) ===
  apache1:
    build:
      context: .
      dockerfile: docker/Dockerfile.apache
    volumes:
      - ./src/app1:/var/www/html:ro
    environment:
      - APP_NAME=App1
    networks:
      - frontend_net
      - backend_net

  apache2:
    build:
      context: .
      dockerfile: docker/Dockerfile.apache
    volumes:
      - ./src/app2:/var/www/html:ro
    environment:
      - APP_NAME=App2
    networks:
      - frontend_net
      - backend_net

  apache3:
    build:
      context: .
      dockerfile: docker/Dockerfile.apache
    volumes:
      - ./src/app3:/var/www/html:ro
    environment:
      - APP_NAME=App3
    networks:
      - frontend_net
      - backend_net

  # Almacenament d'objectes S3
  minio:
    image: minio/minio:latest
    environment:
      - MINIO_ROOT_USER=minioadmin
      - MINIO_ROOT_PASSWORD=minioadmin
    command: server /data --console-address :9001
    networks:
      - frontend_net
    volumes:
      - minio_data:/data

  # === 3. BACK-END ===
  # Base de dades principal (escriptura)
  postgres_write:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=apppass
      - POSTGRES_DB=appdb
    volumes:
      - postgres_write_data:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - backend_net

  # Base de dades secundària (lectura)
  postgres_read:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=appuser
      - POSTGRES_PASSWORD=apppass
      - POSTGRES_DB=appdb
    volumes:
      - postgres_read_data:/var/lib/postgresql/data
    networks:
      - backend_net

  # Cache Redis
  redis:
    image: redis:alpine
    networks:
      - backend_net

  # Cua de missatges RabbitMQ
  rabbitmq:
    image: rabbitmq:3-management-alpine
    environment:
      - RABBITMQ_DEFAULT_USER=rabbituser
      - RABBITMQ_DEFAULT_PASS=rabbitpass
    networks:
      - backend_net

  # Agent consumidor de tasques (PHP)
  task_agent:
    build:
      context: .
      dockerfile: docker/Dockerfile.task_agent
    networks:
      - backend_net
    depends_on:
      - rabbitmq
      - postgres_write
      - redis

  # === 4. INTEL·LIGÈNCIA DE NEGOCI (Metabase) ===
  metabase:
    image: metabase/metabase:latest
    environment:
      - MB_DB_TYPE=postgres
      - MB_DB_HOST=postgres_bi
      - MB_DB_PORT=5432
      - MB_DB_DBNAME=metabase
      - MB_DB_USER=metabase
      - MB_DB_PASS=metabase
    networks:
      - bi_net
    ports:
      - "3000:3000"

  # Base de dades de Metabase
  postgres_bi:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=metabase
      - POSTGRES_PASSWORD=metabase
      - POSTGRES_DB=metabase
    volumes:
      - postgres_bi_data:/var/lib/postgresql/data
    networks:
      - bi_net

  # === 5. APLICACIÓ HERETADA (Tomcat + MariaDB) ===
  tomcat:
    image: tomcat:9.0-jdk11-openjdk-slim
    volumes:
      - ./legacy:/usr/local/tomcat/webapps/ROOT:ro
    networks:
      - legacy_net
    ports:
      - "8080:8080"

  mariadb:
    image: mariadb:10.11
    environment:
      - MARIADB_ROOT_PASSWORD=rootpass
      - MARIADB_DATABASE=legacy_db
    volumes:
      - mariadb_data:/var/lib/mysql
      - ./db/init_legacy.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - legacy_net

networks:
  frontend_net:
  backend_net:
  bi_net:
  legacy_net:

volumes:
  minio_data:
  postgres_write_data:
  postgres_read_data:
  postgres_bi_data:
  mariadb_data:
EOF

echo "✅ docker-compose.yml creado"

# Crear README.md
echo "📝 Creando documentación..."

cat > README.md << 'EOF'
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
EOF

echo "✅ README.md creado"

# Hacer ejecutable el script
chmod +x setup_complete.sh

echo ""
echo "🎉 Configuración completa finalizada!"
echo ""
echo "📁 Estructura creada:"
echo "   ├── docker/"
echo "   │   ├── Dockerfile.apache"
echo "   │   ├── Dockerfile.task_agent"
echo "   │   ├── task_agent.php"
echo "   │   └── nginx.conf"
echo "   ├── src/"
echo "   │   ├── app1/index.php"
echo "   │   ├── app2/index.php"
echo "   │   └── app3/index.php"
echo "   ├── legacy/"
echo "   │   └── info.jsp"
echo "   ├── db/"
echo "   │   ├── init.sql"
echo "   │   └── init_legacy.sql"
echo "   ├── docker-compose.yml"
echo "   ├── setup_complete.sh"
echo "   └── README.md"
echo ""
echo "🚀 Para desplegar los contenedores:"
echo "   docker-compose up -d"
echo ""
echo "🌐 URLs de acceso:"
echo "   - Balanceador: http://localhost"
echo "   - Tomcat: http://localhost:8080/info.jsp"
echo "   - Metabase: http://localhost:3000"
echo ""
echo "🛑 Para detener y eliminar todo:"
echo "   docker-compose down"
echo ""
echo "📋 Para verificar el estado:"
echo "   docker-compose ps"
echo ""