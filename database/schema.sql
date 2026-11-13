-- Nexo CRM · Esquema de base de datos (MySQL 5.7+/8, MariaDB 10.3+)
-- Importar en phpMyAdmin (InfinityFree) o: mysql -u USER -p DB < schema.sql

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS actividades, oportunidades, etapas, contactos, empresas, usuarios, roles;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
  id      TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre  VARCHAR(40) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE usuarios (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  rol_id            TINYINT UNSIGNED NOT NULL,
  nombre            VARCHAR(60)  NOT NULL,
  apellido          VARCHAR(60)  NOT NULL,
  correo            VARCHAR(120) NOT NULL UNIQUE,
  password_hash     VARCHAR(255) NOT NULL,
  puesto            VARCHAR(80),
  activo            BOOLEAN      NOT NULL DEFAULT TRUE,
  intentos_fallidos TINYINT UNSIGNED NOT NULL DEFAULT 0,
  bloqueado_hasta   DATETIME NULL,
  ultimo_acceso     DATETIME NULL,
  creado_en         TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_usuarios_rol FOREIGN KEY (rol_id) REFERENCES roles(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE empresas (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre          VARCHAR(120) NOT NULL,
  rfc             VARCHAR(13)  UNIQUE,
  industria       VARCHAR(80),
  telefono        VARCHAR(20),
  sitio_web       VARCHAR(160),
  direccion       VARCHAR(200),
  ciudad          VARCHAR(80),
  responsable_id  INT UNSIGNED NULL,
  creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_empresas_responsable FOREIGN KEY (responsable_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE contactos (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  empresa_id      INT UNSIGNED NULL,
  responsable_id  INT UNSIGNED NULL,
  nombre          VARCHAR(60)  NOT NULL,
  apellido        VARCHAR(60)  NOT NULL,
  correo          VARCHAR(120),
  telefono        VARCHAR(20),
  puesto          VARCHAR(80),
  estado          ENUM('activo','inactivo','prospecto') NOT NULL DEFAULT 'prospecto',
  creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_contactos_empresa     FOREIGN KEY (empresa_id)     REFERENCES empresas(id) ON DELETE SET NULL,
  CONSTRAINT fk_contactos_responsable FOREIGN KEY (responsable_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE etapas (
  id            TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(40) NOT NULL UNIQUE,
  orden         TINYINT UNSIGNED NOT NULL,
  probabilidad  TINYINT UNSIGNED NOT NULL COMMENT 'Porcentaje 0-100'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE oportunidades (
  id               INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre           VARCHAR(150) NOT NULL,
  empresa_id       INT UNSIGNED NOT NULL,
  contacto_id      INT UNSIGNED NULL,
  etapa_id         TINYINT UNSIGNED NOT NULL,
  responsable_id   INT UNSIGNED NOT NULL,
  valor            DECIMAL(12,2) NOT NULL DEFAULT 0,
  cierre_estimado  DATE,
  creado_en        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_op_empresa     FOREIGN KEY (empresa_id)     REFERENCES empresas(id),
  CONSTRAINT fk_op_contacto    FOREIGN KEY (contacto_id)    REFERENCES contactos(id) ON DELETE SET NULL,
  CONSTRAINT fk_op_etapa       FOREIGN KEY (etapa_id)       REFERENCES etapas(id),
  CONSTRAINT fk_op_responsable FOREIGN KEY (responsable_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE actividades (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tipo            ENUM('llamada','correo','reunion','tarea') NOT NULL,
  asunto          VARCHAR(150) NOT NULL,
  descripcion     TEXT,
  fecha_hora      DATETIME NOT NULL,
  estado          ENUM('pendiente','completada','cancelada') NOT NULL DEFAULT 'pendiente',
  usuario_id      INT UNSIGNED NOT NULL,
  contacto_id     INT UNSIGNED NULL,
  oportunidad_id  INT UNSIGNED NULL,
  creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_act_usuario     FOREIGN KEY (usuario_id)     REFERENCES usuarios(id),
  CONSTRAINT fk_act_contacto    FOREIGN KEY (contacto_id)    REFERENCES contactos(id) ON DELETE CASCADE,
  CONSTRAINT fk_act_oportunidad FOREIGN KEY (oportunidad_id) REFERENCES oportunidades(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ───────── Datos de prueba ─────────
INSERT INTO roles (nombre) VALUES ('Administrador'), ('Gerente comercial'), ('Ejecutivo de ventas');

-- Contraseña de los 3 usuarios: Nexo2026!
INSERT INTO usuarios (rol_id, nombre, apellido, correo, password_hash, puesto) VALUES
 (2, 'Ana',   'Torres', 'ana.torres@empresa.com', '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Gerente comercial'),
 (3, 'Luis',  'Pérez',  'luis.perez@empresa.com', '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Ejecutivo de ventas'),
 (1, 'Carla', 'Ríos',   'admin@empresa.com',      '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Administradora del sistema');

INSERT INTO etapas (nombre, orden, probabilidad) VALUES
 ('Prospecto',1,10), ('Calificado',2,25), ('Propuesta',3,50), ('Negociación',4,75), ('Ganado',5,100), ('Perdido',6,0);

INSERT INTO empresas (nombre, rfc, industria, ciudad, responsable_id) VALUES
 ('Grupo Andino',  'GAN010101AB1', 'Manufactura', 'Monterrey',   1),
 ('Textiles Sur',  'TSU020202CD2', 'Textil',      'Puebla',      2),
 ('Logística MX',  'LMX030303EF3', 'Transporte',  'La Paz',      3);

INSERT INTO contactos (empresa_id, responsable_id, nombre, apellido, correo, telefono, puesto, estado) VALUES
 (1, 1, 'Jorge',  'Medina', 'jmedina@grupoandino.mx', '8112345678', 'Director de compras', 'activo'),
 (2, 2, 'Sofía',  'Luna',   'sluna@textilessur.mx',   '2229876543', 'Gerente de RR. HH.', 'activo'),
 (3, 3, 'Ramiro', 'Castro', 'rcastro@logisticamx.mx', '6121112233', 'CEO',                'prospecto');

INSERT INTO oportunidades (nombre, empresa_id, contacto_id, etapa_id, responsable_id, valor, cierre_estimado) VALUES
 ('Renovación licencias 2027',     1, 1, 4, 1, 48000, '2026-11-15'),
 ('Implementación módulo RR. HH.', 2, 2, 3, 2, 32500, '2026-11-30'),
 ('Soporte anual premium',         3, 3, 5, 3, 18900, '2026-10-20');

INSERT INTO actividades (tipo, asunto, fecha_hora, usuario_id, contacto_id, oportunidad_id) VALUES
 ('llamada', 'Llamada — Grupo Andino',  '2026-11-21 10:30:00', 1, 1, 1),
 ('correo',  'Propuesta — Textiles Sur', '2026-11-21 15:00:00', 2, 2, 2),
 ('reunion', 'Cierre — Logística MX',   '2026-11-22 09:00:00', 3, 3, 3);
