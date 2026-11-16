# Nexo CRM · Entregable 2

Arquitectura de datos y esqueleto funcional del CRM corporativo (UABCS), basado en el prototipo de Figma *CRM Corporativo — Prototipo*.

- **MER:** [`docs/MER.png`](docs/MER.png) · [`docs/MER.pdf`](docs/MER.pdf) · fuente en [`docs/mer.html`](docs/mer.html)
- **Script SQL:** [`database/schema.sql`](database/schema.sql) (tablas + datos de prueba)
- **Stack:** HTML, CSS y PHP 8 (PDO) + MySQL. Sin frameworks.

## Usuarios de prueba

| Correo | Contraseña | Rol |
|---|---|---|
| `ana.torres@empresa.com` | `Nexo2026!` | Gerente comercial |
| `luis.perez@empresa.com` | `Nexo2026!` | Ejecutivo de ventas |
| `admin@empresa.com` | `Nexo2026!` | Administrador |

Tras 3 intentos fallidos la cuenta se bloquea 15 minutos.

## Estructura

```
index.php          Login (diseño Figma 01 y alerta 13)
login.php          Valida contra la BD (password_verify, CSRF, bloqueo por intentos)
logout.php         Cierra sesión
dashboard.php      Página principal (Figma 02)
contactos.php … configuracion.php   Páginas destino de cada módulo
includes/config.php   Conexión PDO + sesión
includes/layout.php   Sidebar + topbar compartidos
assets/            CSS e iconos SVG exportados de Figma
database/schema.sql
docs/              MER
```

## Despliegue en InfinityFree

1. Crear cuenta y sitio en https://infinityfree.com.
2. Panel → **MySQL Databases** → crear BD. Anotar host (`sqlXXX.infinityfree.com`), nombre, usuario (`if0_…`) y contraseña.
3. Panel → **phpMyAdmin** → seleccionar la BD → **Importar** → `database/schema.sql`.
4. Editar `includes/config.php` y poner esos 4 datos en `DB_HOST`, `DB_NAME`, `DB_USER`, `DB_PASS`.
5. **File Manager** (o FTP) → subir todo el proyecto (excepto `docs/` y `database/`, opcional) a `htdocs/`.
6. Abrir `https://TU-SITIO.infinityfreeapp.com` e iniciar sesión.

## Correr local con Docker

```bash
docker network create nexo
docker run -d --name nexo-db --network nexo -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=nexo_crm mysql:8
docker exec -i nexo-db mysql -uroot -proot nexo_crm < database/schema.sql
docker run -d --name nexo-web --network nexo -p 8088:80 -e DB_HOST=nexo-db -e DB_PASS=root \
  -v "$PWD":/var/www/html php:8.2-apache sh -c "docker-php-ext-install pdo_mysql && apache2-foreground"
# http://localhost:8088
```
