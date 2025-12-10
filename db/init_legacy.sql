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
