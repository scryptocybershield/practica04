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
