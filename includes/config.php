<?php
if (is_file(__DIR__ . '/config.local.php')) {
    require __DIR__ . '/config.local.php';
}

foreach (['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASS'] as $name) {
    if (!defined($name) && ($value = getenv($name)) !== false) {
        define($name, $value);
    }
}

define('MAX_INTENTOS', 3);
define('MINUTOS_BLOQUEO', 15);

ini_set('display_errors', '0');
date_default_timezone_set('America/Mazatlan');
session_start(['cookie_httponly' => true, 'cookie_samesite' => 'Lax']);

function db(): PDO
{
    static $pdo;
    $faltantes = array_filter(
        ['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASS'],
        static fn(string $name): bool => !defined($name)
            || ($name !== 'DB_PASS' && constant($name) === '')
    );
    if ($faltantes) {
        throw new RuntimeException(
            'Configura DB_HOST, DB_NAME, DB_USER y DB_PASS en includes/config.local.php o como variables de entorno.'
        );
    }

    return $pdo ??= new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASS,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
    );
}

function e(?string $s): string
{
    return htmlspecialchars($s ?? '', ENT_QUOTES, 'UTF-8');
}

function requiere_login(): array
{
    if (empty($_SESSION['usuario'])) {
        header('Location: index.html');
        exit;
    }
    return $_SESSION['usuario'];
}
