<?php
require __DIR__ . '/includes/config.php';

if (!empty($_SESSION['usuario'])) {
    header('Location: dashboard.php');
    exit;
}
$error = $_SESSION['login_error'] ?? null;
unset($_SESSION['login_error']);
?>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Iniciar sesión · Nexo CRM</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="assets/styles.css">
</head>
<body class="login">
  <aside class="login-marca">
    <div class="logo"><span class="logo-n">N</span> Nexo CRM</div>
    <div class="login-mensaje">
      <h1>Relaciones comerciales claras, decisiones más rápidas.</h1>
      <p>Centraliza contactos, empresas y oportunidades en un solo lugar.</p>
    </div>
    <small>© 2026 Nexo CRM · Uso interno corporativo</small>
  </aside>

  <main class="login-form">
    <form class="login-caja" method="post" action="login.php" novalidate>
      <div class="titulos">
        <h2 class="h1">Iniciar sesión</h2>
        <p>Ingresa con tu cuenta corporativa.</p>
      </div>

      <?php if ($error): ?>
        <div class="alerta" role="alert">
          <span class="alerta-icono"><img src="assets/icons/error.svg" width="18.3333" height="18.3333" alt=""></span>
          <div>
            <strong><?= e($error['titulo']) ?></strong>
            <p><?= e($error['mensaje']) ?></p>
          </div>
          <button type="button" class="alerta-cerrar" aria-label="Cerrar" onclick="this.parentElement.remove()">
            <img src="assets/icons/cerrar.svg" width="11.6667" height="11.6667" alt="">
          </button>
        </div>
      <?php endif; ?>

      <label class="campo">
        <span>Correo corporativo</span>
        <input type="email" name="correo" required autocomplete="username"
               placeholder="ana.torres@empresa.com" value="<?= e($error['correo'] ?? '') ?>">
      </label>

      <label class="campo<?= !empty($error['campo']) ? ' campo-error' : '' ?>">
        <span>Contraseña</span>
        <input type="password" name="password" required autocomplete="current-password" placeholder="••••••••••">
        <?php if (!empty($error['campo'])): ?>
          <small>La contraseña no coincide con el correo ingresado.</small>
        <?php endif; ?>
      </label>

      <div class="opciones">
        <label class="check"><input type="checkbox" name="recordarme" value="1"> Recordarme</label>
        <a href="#" onclick="return false" title="Contacta a soporte TI">¿Olvidaste tu contraseña?</a>
      </div>

      <input type="hidden" name="csrf" value="<?= e(csrf_token()) ?>">
      <button class="btn btn-primario btn-bloque" type="submit">Ingresar</button>
      <small class="tenue">¿Problemas para acceder? Contacta a soporte TI.</small>
    </form>
  </main>
</body>
</html>
