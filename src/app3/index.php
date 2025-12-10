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
