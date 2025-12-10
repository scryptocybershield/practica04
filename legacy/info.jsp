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
