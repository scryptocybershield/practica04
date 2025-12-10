# Diagrama de Arquitectura - Práctica Docker Compose

## Diagrama de Redes y Servicios

```mermaid
graph TB
    %% Cliente externo
    CLIENTE[Cliente<br/>HTTP/HTTPS] --> LB[Balancejador<br/>Nginx:80]

    %% Red web_net
    subgraph "web_net - Red Externa"
        LB --> APACHE1[Apache1:80<br/>App1]
        LB --> APACHE2[Apache2:80<br/>App2]
        LB --> APACHE3[Apache3:80<br/>App3]
        LB --> MINIO[MinIO<br/>S3 Storage]
        APACHE1 --> MINIO
        APACHE2 --> MINIO
        APACHE3 --> MINIO
    end

    %% Red app_net
    subgraph "app_net - Red de Aplicación"
        APACHE1 --> REDIS[Redis<br/>Cache]
        APACHE2 --> REDIS
        APACHE3 --> REDIS
        APACHE1 --> RABBIT[RabbitMQ<br/>Message Queue]
        APACHE2 --> RABBIT
        APACHE3 --> RABBIT
        AGENT[Task Agent<br/>PHP] --> RABBIT
        AGENT --> REDIS
    end

    %% Red functional_db_net
    subgraph "functional_db_net - Red de Bases de Datos Funcionales"
        APACHE1 --> PG_WRITE[PostgreSQL Write<br/>Base Principal]
        APACHE2 --> PG_WRITE
        APACHE3 --> PG_WRITE
        AGENT --> PG_WRITE
        PG_WRITE -.-> PG_READ[PostgreSQL Read<br/>Réplica]
        METABASE[Metabase<br/>BI Tool] --> PG_BI[PostgreSQL BI<br/>Metabase DB]
    end

    %% Red legacy_db_net
    subgraph "legacy_db_net - Red de Aplicación Legacy"
        TOMCAT[Tomcat<br/>Legacy App] --> MARIADB[MariaDB<br/>Legacy DB]
        APACHE1 --> TOMCAT
        APACHE2 --> TOMCAT
        APACHE3 --> TOMCAT
        METABASE --> TOMCAT
    end

    %% Conexiones entre redes
    APACHE1 -.-> AGENT
    APACHE2 -.-> AGENT
    APACHE3 -.-> AGENT
    AGENT -.-> PG_BI

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

### **web_net** - Red Externa
- **Servicios**: `loadbalancer`, `apache1`, `apache2`, `apache3`, `minio`
- **Propósito**: Comunicación entre balanceador y front-end (único punto de acceso externo)
- **Puertos expuestos**: 80 (solo balanceador)

### **app_net** - Red de Aplicación
- **Servicios**: `apache1`, `apache2`, `apache3`, `redis`, `rabbitmq`, `task_agent`
- **Propósito**: Comunicación interna entre componentes de aplicación (cache, colas, almacenamiento)
- **Sin acceso externo directo**

### **functional_db_net** - Red de Bases de Datos Funcionales
- **Servicios**: `postgres_write`, `postgres_read`, `postgres_bi`, `metabase`, `task_agent`, `apache1`, `apache2`, `apache3`
- **Propósito**: Comunicación con bases de datos funcionales (Apache accede a PostgreSQL para gestión de datos)
- **Aislamiento**: Solo servicios autorizados pueden acceder

### **legacy_db_net** - Red de Aplicación Legacy
- **Servicios**: `tomcat`, `mariadb`, `apache1`, `apache2`, `apache3`, `metabase`
- **Propósito**: Aislamiento de sistema heredado con acceso controlado (Apache y Metabase consultan API Tomcat)
- **Sin acceso externo directo**

## Puertos y Accesos

| Servicio | Puerto | Acceso | Propósito |
|----------|--------|--------|-----------|
| Nginx | 80 | Público | Balanceador principal (único punto de acceso externo) |
| Todos los demás servicios | Varios | Interno | Solo accesibles desde redes Docker internas |

## Flujo de Comunicación

1. **Cliente → Nginx (web_net)** - Entrada principal
2. **Nginx → Apache (web_net)** - Balanceo de carga
3. **Apache → Redis/RabbitMQ (app_net)** - Cache y colas
4. **Apache → MinIO (web_net)** - Almacenamiento de objetos
5. **Apache → PostgreSQL (functional_db_net)** - Base de datos principal
6. **Apache → Tomcat (legacy_db_net)** - Consulta API heredada
7. **Task Agent → RabbitMQ (app_net)** - Consumo de tareas
8. **Task Agent → PostgreSQL (functional_db_net)** - Procesamiento de datos
9. **Metabase → PostgreSQL BI (functional_db_net)** - Análisis de datos
10. **Metabase → Tomcat (legacy_db_net)** - Consulta datos legacy
11. **Tomcat → MariaDB (legacy_db_net)** - Aplicación heredada

## Beneficios de la Microsegmentación

- **Seguridad**: Aislamiento de servicios críticos
- **Rendimiento**: Reducción de tráfico innecesario
- **Mantenibilidad**: Dependencias claras entre servicios
- **Escalabilidad**: Facilita la escalabilidad horizontal