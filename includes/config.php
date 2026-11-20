<?php
if (is_file(__DIR__ . '/config.local.php')) {
    require __DIR__ . '/config.local.php';
}
defined('DB_HOST') || define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
defined('DB_NAME') || define('DB_NAME', getenv('DB_NAME') ?: 'nexo_crm');
defined('DB_USER') || define('DB_USER', getenv('DB_USER') ?: 'root');
defined('DB_PASS') || define('DB_PASS', getenv('DB_PASS') ?: '');

define('MAX_INTENTOS', 3);
define('MINUTOS_BLOQUEO', 15);

ini_set('display_errors', '0');
date_default_timezone_set('America/Mazatlan');
session_start(['cookie_httponly' => true, 'cookie_samesite' => 'Lax']);

function db(): PDO
{
    static $pdo;
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
