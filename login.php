<?php
require __DIR__ . '/includes/config.php';

function volver(string $error, int $quedan = 0): never
{
    header('Location: index.html?error=' . $error . ($quedan ? "&quedan=$quedan" : ''));
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    volver('');
}

$correo   = trim($_POST['correo'] ?? '');
$password = $_POST['password'] ?? '';

if (!filter_var($correo, FILTER_VALIDATE_EMAIL) || $password === '') {
    volver('datos');
}

$st = db()->prepare(
    "SELECT u.*, r.nombre AS rol FROM usuarios u JOIN roles r ON r.id = u.rol_id WHERE u.correo = ? AND u.estado = 'activo'"
);
$st->execute([$correo]);
$u = $st->fetch();

if ($u && $u['bloqueado_hasta'] && strtotime($u['bloqueado_hasta']) > time()) {
    volver('bloqueado');
}

if (!$u || !password_verify($password, $u['password_hash'])) {
    if (!$u) {
        volver('credenciales');
    }
    $intentos = $u['intentos_fallidos'] + 1;
    $bloquear = $intentos >= MAX_INTENTOS;
    db()->prepare('UPDATE usuarios SET intentos_fallidos = ?, bloqueado_hasta = ? WHERE id = ?')->execute([
        $bloquear ? 0 : $intentos,
        $bloquear ? date('Y-m-d H:i:s', time() + MINUTOS_BLOQUEO * 60) : null,
        $u['id'],
    ]);
    $bloquear ? volver('bloqueado') : volver('credenciales', MAX_INTENTOS - $intentos);
}

db()->prepare('UPDATE usuarios SET intentos_fallidos = 0, bloqueado_hasta = NULL, ultimo_acceso = NOW() WHERE id = ?')
    ->execute([$u['id']]);

session_regenerate_id(true);
$_SESSION['usuario'] = [
    'id'       => $u['id'],
    'nombre'   => $u['nombre'],
    'apellido' => $u['apellido'],
    'puesto'   => $u['puesto'],
    'rol'      => $u['rol'],
];

if (!empty($_POST['recordarme'])) {
    $p = session_get_cookie_params();
    setcookie(session_name(), session_id(), time() + 60 * 60 * 24 * 30, $p['path'], $p['domain'], $p['secure'], true);
}

header('Location: dashboard.php');
