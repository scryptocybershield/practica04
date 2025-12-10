#!/bin/bash

# Script para crear la estructura de directorios necesaria para la práctica 4

echo "🔧 Creando estructura de directorios para la práctica 4..."

# Directorios principales
mkdir -p src/app1
mkdir -p src/app2
mkdir -p src/app3
mkdir -p db
mkdir -p legacy
mkdir -p docker

# Crear archivos composer.json básicos para las aplicaciones PHP
echo "📝 Creando archivos composer.json para las aplicaciones..."

cat > src/app1/composer.json << 'EOF'
{
    "name": "app1/app1",
    "description": "Aplicación 1",
    "type": "project",
    "require": {
        "php": "^8.3"
    },
    "autoload": {
        "psr-4": {
            "App1\\": "src/"
        }
    }
}
EOF

cat > src/app2/composer.json << 'EOF'
{
    "name": "app2/app2",
    "description": "Aplicación 2",
    "type": "project",
    "require": {
        "php": "^8.3"
    },
    "autoload": {
        "psr-4": {
            "App2\\": "src/"
        }
    }
}
EOF

cat > src/app3/composer.json << 'EOF'
{
    "name": "app3/app3",
    "description": "Aplicación 3",
    "type": "project",
    "require": {
        "php": "^8.3"
    },
    "autoload": {
        "psr-4": {
            "App3\\": "src/"
        }
    }
}
EOF

# Crear archivos de inicialización de bases de datos
echo "🗄️ Creando scripts de inicialización de bases de datos..."

cat > db/init_functional.sql << 'EOF'
-- Script de inicialización para PostgreSQL (Base de datos funcional)
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, email) VALUES
('admin', 'admin@example.com'),
('user1', 'user1@example.com'),
('user2', 'user2@example.com');

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOF

cat > db/init_legacy.sql << 'EOF'
-- Script de inicialización para MariaDB (Base de datos legacy)
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

# Crear archivo WAR dummy para Tomcat
echo "☕ Creando archivo WAR dummy para Tomcat legacy..."
touch legacy/report.war

# Crear archivos PHP básicos para las aplicaciones
echo "🐘 Creando archivos PHP básicos..."

cat > src/app1/index.php << 'EOF'
<?php
// Aplicación 1
header('Content-Type: text/html; charset=utf-8');
echo "<h1>🚀 Aplicación 1</h1>";
echo "<p>Esta es la aplicación 1 funcionando correctamente.</p>";
echo "<p>Conectada a PostgreSQL y RabbitMQ.</p>";
?>
EOF

cat > src/app2/index.php << 'EOF'
<?php
// Aplicación 2
header('Content-Type: text/html; charset=utf-8');
echo "<h1>🚀 Aplicación 2</h1>";
echo "<p>Esta es la aplicación 2 funcionando correctamente.</p>";
echo "<p>Conectada a PostgreSQL y RabbitMQ.</p>";
?>
EOF

cat > src/app3/index.php << 'EOF'
<?php
// Aplicación 3
header('Content-Type: text/html; charset=utf-8');
echo "<h1>🚀 Aplicación 3</h1>";
echo "<p>Esta es la aplicación 3 funcionando correctamente.</p>";
echo "<p>Conectada a PostgreSQL y RabbitMQ.</p>";
?>
EOF

# Mover Dockerfile.php al directorio docker si existe
if [ -f "Dockerfile.php" ]; then
    echo "📦 Moviendo Dockerfile.php al directorio docker..."
    mv Dockerfile.php docker/
fi

# Hacer el script ejecutable
chmod +x setup_directories.sh

echo "✅ Estructura de directorios creada exitosamente!"
echo ""
echo "📁 Directorios creados:"
echo "  - src/app1/     (Aplicación PHP 1)"
echo "  - src/app2/     (Aplicación PHP 2)"
echo "  - src/app3/     (Aplicación PHP 3)"
echo "  - db/           (Scripts de bases de datos)"
echo "  - legacy/       (Aplicación Tomcat legacy)"
echo "  - docker/       (Dockerfiles)"
echo ""
echo "📄 Archivos creados:"
echo "  - composer.json para cada aplicación"
echo "  - init_functional.sql (PostgreSQL)"
echo "  - init_legacy.sql (MariaDB)"
echo "  - report.war (Tomcat legacy)"
echo "  - index.php para cada aplicación"
echo ""
echo "🎯 Ahora puedes ejecutar: docker-compose up -d"