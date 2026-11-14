<?php
require __DIR__ . '/includes/config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: index.php');
    exit;
}

function fallar(string $titulo, string $mensaje, string $correo, bool $campo = false): never
{
    $_SESSION['login_error'] = compact('titulo', 'mensaje', 'correo', 'campo');
    header('Location: index.php');
    exit;
}

$correo   = trim($_POST['correo'] ?? '');
$password = $_POST['password'] ?? '';

if (!hash_equals($_SESSION['csrf'] ?? '', $_POST['csrf'] ?? '')) {
    fallar('Sesión expirada', 'Recarga la página e inténtalo de nuevo.', $correo);
}
if (!filter_var($correo, FILTER_VALIDATE_EMAIL) || $password === '') {
    fallar('Datos incompletos', 'Ingresa un correo válido y tu contraseña.', $correo);
}

$st = db()->prepare(
    'SELECT u.*, r.nombre AS rol FROM usuarios u JOIN roles r ON r.id = u.rol_id WHERE u.correo = ? AND u.activo = 1'
);
$st->execute([$correo]);
$u = $st->fetch();

if ($u && $u['bloqueado_hasta'] && strtotime($u['bloqueado_hasta']) > time()) {
    fallar('Cuenta bloqueada', 'Demasiados intentos fallidos. Intenta de nuevo en ' . MINUTOS_BLOQUEO . ' minutos.', $correo);
}

if (!$u || !password_verify($password, $u['password_hash'])) {
    if ($u) {
        $intentos = $u['intentos_fallidos'] + 1;
        $bloquear = $intentos >= MAX_INTENTOS;
        db()->prepare('UPDATE usuarios SET intentos_fallidos = ?, bloqueado_hasta = ? WHERE id = ?')->execute([
            $bloquear ? 0 : $intentos,
            $bloquear ? date('Y-m-d H:i:s', time() + MINUTOS_BLOQUEO * 60) : null,
            $u['id'],
        ]);
        $quedan = MAX_INTENTOS - $intentos;
        $msg = $bloquear
            ? 'Cuenta bloqueada por ' . MINUTOS_BLOQUEO . ' minutos.'
            : "Verifica tus credenciales. Te quedan $quedan " . ($quedan === 1 ? 'intento' : 'intentos') . ' antes del bloqueo.';
    } else {
        $msg = 'Verifica tus credenciales e inténtalo de nuevo.';
    }
    fallar('No pudimos iniciar sesión', $msg, $correo, true);
}

db()->prepare('UPDATE usuarios SET intentos_fallidos = 0, bloqueado_hasta = NULL, ultimo_acceso = NOW() WHERE id = ?')
    ->execute([$u['id']]);

session_regenerate_id(true);
$_SESSION['usuario'] = [
    'id'     => $u['id'],
    'nombre' => $u['nombre'],
    'apellido' => $u['apellido'],
    'puesto' => $u['puesto'],
    'rol'    => $u['rol'],
];

if (!empty($_POST['recordarme'])) {
    $p = session_get_cookie_params();
    setcookie(session_name(), session_id(), time() + 60 * 60 * 24 * 30, $p['path'], $p['domain'], $p['secure'], true);
}

header('Location: dashboard.php');
