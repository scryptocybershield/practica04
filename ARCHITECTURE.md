# Diagrama de Arquitectura - Práctica Docker Compose

## Diagrama de Redes y Servicios

```mermaid
graph TB
    %% Cliente externo
    CLIENTE[Cliente<br/>HTTP/HTTPS] --> LB[Balanceador<br/>Nginx:80]

    %% Red frontend_net
    subgraph "frontend_net - Red Frontend"
        LB --> APACHE1[Apache1:80<br/>App1]
        LB --> APACHE2[Apache2:80<br/>App2]
        LB --> APACHE3[Apache3:80<br/>App3]
        LB --> MINIO[MinIO<br/>S3 Storage]
        APACHE1 --> MINIO
        APACHE2 --> MINIO
        APACHE3 --> MINIO
    end

    %% Red backend_net
    subgraph "backend_net - Red Backend"
        APACHE1 --> REDIS[Redis<br/>Cache]
        APACHE2 --> REDIS
        APACHE3 --> REDIS
        APACHE1 --> RABBIT[RabbitMQ<br/>Message Queue]
        APACHE2 --> RABBIT
        APACHE3 --> RABBIT
        AGENT[Task Agent<br/>PHP] --> RABBIT
        AGENT --> REDIS
        APACHE1 --> PG_WRITE[PostgreSQL Write<br/>Base Principal]
        APACHE2 --> PG_WRITE
        APACHE3 --> PG_WRITE
        AGENT --> PG_WRITE
        PG_WRITE -.-> PG_READ[PostgreSQL Read<br/>Réplica]
    end

    %% Red bi_net
    subgraph "bi_net - Red Business Intelligence"
        METABASE[Metabase<br/>BI Tool] --> PG_BI[PostgreSQL BI<br/>Metabase DB]
    end

    %% Red legacy_net
    subgraph "legacy_net - Red Legacy"
        TOMCAT[Tomcat<br/>Legacy App] --> MARIADB[MariaDB<br/>Legacy DB]
    end

    %% Estilos
    classDef web fill:#e1f5fe
    classDef app fill:#f3e5f5
    classDef db fill:#e8f5e8
    classDef legacy fill:#fff3e0

    class LB,APACHE1,APACHE2,APACHE3,MINIO web
    class REDIS,RABBIT,AGENT app
    class PG_WRITE,PG_READ,PG_BI,METABASE db
    class TOMCAT,MARIADB legacy
```

## Descripción de la Microsegmentación

### **frontend_net** - Red Frontend
- **Servicios**: `loadbalancer`, `apache1`, `apache2`, `apache3`, `minio`
- **Propósito**: Comunicación entre balanceador y servidores web front-end
- **Puertos expuestos**: 80 (solo balanceador)

### **backend_net** - Red Backend
- **Servicios**: `apache1`, `apache2`, `apache3`, `redis`, `rabbitmq`, `task_agent`, `postgres_write`, `postgres_read`
- **Propósito**: Comunicación interna entre componentes de aplicación (cache, colas, bases de datos)
- **Sin acceso externo directo**

### **bi_net** - Red Business Intelligence
- **Servicios**: `metabase`, `postgres_bi`
- **Propósito**: Aislamiento de herramientas de inteligencia de negocio
- **Sin acceso externo directo**

### **legacy_net** - Red Legacy
- **Servicios**: `tomcat`, `mariadb`
- **Propósito**: Aislamiento de sistema heredado
- **Sin acceso externo directo**

## Puertos y Accesos

| Servicio | Puerto | Acceso | Propósito |
|----------|--------|--------|-----------|
| Nginx | 80 | Público | Balanceador principal (único punto de acceso externo) |
| Todos los demás servicios | Varios | Interno | Solo accesibles desde redes Docker internas |

## Flujo de Comunicación

1. **Cliente → Nginx (frontend_net)** - Entrada principal
2. **Nginx → Apache (frontend_net)** - Balanceo de carga
3. **Apache → MinIO (frontend_net)** - Almacenamiento de objetos
4. **Apache → Redis/RabbitMQ (backend_net)** - Cache y colas
5. **Apache → PostgreSQL (backend_net)** - Base de datos principal
6. **Task Agent → RabbitMQ (backend_net)** - Consumo de tareas
7. **Task Agent → PostgreSQL (backend_net)** - Procesamiento de datos
8. **Metabase → PostgreSQL BI (bi_net)** - Análisis de datos
9. **Tomcat → MariaDB (legacy_net)** - Aplicación heredada

## Beneficios de la Microsegmentación

- **Seguridad**: Aislamiento de servicios críticos
- **Rendimiento**: Reducción de tráfico innecesario
- **Mantenibilidad**: Dependencias claras entre servicios
- **Escalabilidad**: Facilita la escalabilidad horizontal