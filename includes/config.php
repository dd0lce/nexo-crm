<?php
// Datos de conexión. En InfinityFree: Panel → MySQL Databases (host tipo sqlXXX.infinityfree.com, BD/usuario if0_XXXX).
define('DB_HOST', getenv('DB_HOST') ?: 'localhost');
define('DB_NAME', getenv('DB_NAME') ?: 'nexo_crm');
define('DB_USER', getenv('DB_USER') ?: 'root');
define('DB_PASS', getenv('DB_PASS') ?: '');

define('MAX_INTENTOS', 3);
define('MINUTOS_BLOQUEO', 15);

date_default_timezone_set('America/Mazatlan');
session_start();

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

function csrf_token(): string
{
    return $_SESSION['csrf'] ??= bin2hex(random_bytes(16));
}

function requiere_login(): array
{
    if (empty($_SESSION['usuario'])) {
        header('Location: index.php');
        exit;
    }
    return $_SESSION['usuario'];
}
