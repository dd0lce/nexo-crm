<?php
require_once __DIR__ . '/config.php';

const MODULOS = [
    'dashboard'     => ['Dashboard',     '#e64980', 'dashboard',     16.6667, 16.6667],
    'contactos'     => ['Contactos',     '#845ef7', 'contactos',     18.3333, 16.6667],
    'empresas'      => ['Empresas',      '#f76707', 'empresas',      15,      18.3333],
    'oportunidades' => ['Oportunidades', '#228be6', 'oportunidades', 18.3333, 16.6667],
    'actividades'   => ['Actividades',   '#15aabf', 'actividades',   16.6667, 18.3333],
    'reportes'      => ['Reportes',      '#37b24d', 'reportes',      16.6667, 16.6667],
    'configuracion' => ['Configuración', '#5c677d', 'configuracion', 20, 16.6667],
];

function icono(string $nombre, float $w, float $h): string
{
    return '<span class="ic"><img src="assets/icons/' . $nombre . '.svg" width="' . $w . '" height="' . $h . '" alt=""></span>';
}

function layout_inicio(string $actual): array
{
    $u = requiere_login();
    $iniciales = mb_substr($u['nombre'], 0, 1) . mb_substr($u['apellido'], 0, 1);
    $titulo = MODULOS[$actual][0];
    ?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><?= e($titulo) ?> · Nexo CRM</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body class="app">
  <aside class="sidebar">
    <a class="logo" href="dashboard.php"><span class="logo-n">N</span> Nexo CRM</a>
    <label class="buscar buscar-menu">
      <?= icono('buscar', 16.6667, 16.6667) ?>
      <input type="search" placeholder="Buscar…" aria-label="Buscar en menú"
             oninput="document.querySelectorAll('.nav a').forEach(a=>a.hidden=!a.textContent.toLowerCase().includes(this.value.toLowerCase()))">
    </label>
    <nav class="nav">
      <span class="nav-seccion">TODAS LAS APPS</span>
      <?php foreach (MODULOS as $clave => [$nombre, $color, $ic, $w, $h]): ?>
        <a href="<?= $clave ?>.php" class="<?= $clave === $actual ? 'activo' : '' ?>"<?= $clave === $actual ? ' aria-current="page"' : '' ?>>
          <span class="nav-ic" style="background:<?= $color ?>"><?= icono($ic, $w, $h) ?></span>
          <?= e($nombre) ?>
        </a>
      <?php endforeach; ?>
    </nav>
    <div class="sidebar-usuario">
      <span class="avatar"><?= e($iniciales) ?></span>
      <div>
        <strong><?= e($u['nombre'] . ' ' . $u['apellido']) ?></strong>
        <small><?= e($u['puesto']) ?></small>
      </div>
      <a href="logout.php" title="Cerrar sesión" aria-label="Cerrar sesión"><?= icono('salir', 16.6667, 16.6667) ?></a>
    </div>
  </aside>

  <div class="principal">
    <header class="topbar">
      <label class="buscar">
        <?= icono('buscar', 16.6667, 16.6667) ?>
        <input type="search" placeholder="Buscar contactos, empresas, oportunidades…" aria-label="Buscar">
      </label>
      <div class="acciones">
        <span class="notif" title="Notificaciones"><?= icono('campana', 16.6668, 18.3378) ?><i></i></span>
        <span class="sep"></span>
        <details class="perfil">
          <summary>
            <span class="avatar avatar-claro"><?= e($iniciales) ?></span>
            <?= e($u['nombre'] . ' ' . $u['apellido']) ?>
            <?= icono('abajo', 11.6667, 6.66667) ?>
          </summary>
          <div class="menu">
            <a href="configuracion.php">Configuración</a>
            <a href="logout.php">Cerrar sesión</a>
          </div>
        </details>
      </div>
    </header>
    <main class="contenido">
    <?php
    return $u;
}

function layout_fin(): void
{
    echo "    </main>\n  </div>\n</body>\n</html>\n";
}

function pagina_vacia(string $modulo, string $descripcion): void
{
    layout_inicio($modulo);
    [$nombre, $color, $ic, $w, $h] = MODULOS[$modulo];
    ?>
      <div class="encabezado">
        <div class="titulos">
          <h1 class="h1"><?= e($nombre) ?></h1>
          <p><?= e($descripcion) ?></p>
        </div>
      </div>
      <section class="tarjeta vacio">
        <span class="nav-ic nav-ic-grande" style="background:<?= $color ?>"><?= icono($ic, $w, $h) ?></span>
        <h3>Módulo en construcción</h3>
        <p>Esta sección se implementará en la siguiente entrega.</p>
        <a class="btn btn-secundario" href="dashboard.php">Volver al Dashboard</a>
      </section>
    <?php
    layout_fin();
}
