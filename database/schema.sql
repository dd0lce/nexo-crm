SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS notificaciones, archivos, notas, actividades, oportunidad_producto, productos,
  oportunidades, etapas, contactos, empresas, usuarios, rol_permiso, permisos, roles;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE roles (
  id          TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre      VARCHAR(40)  NOT NULL UNIQUE,
  descripcion VARCHAR(150)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE permisos (
  id          SMALLINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  clave       VARCHAR(50)  NOT NULL UNIQUE,
  descripcion VARCHAR(150)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE rol_permiso (
  rol_id      TINYINT UNSIGNED  NOT NULL,
  permiso_id  SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (rol_id, permiso_id),
  CONSTRAINT fk_rp_rol     FOREIGN KEY (rol_id)     REFERENCES roles(id)    ON DELETE CASCADE,
  CONSTRAINT fk_rp_permiso FOREIGN KEY (permiso_id) REFERENCES permisos(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE usuarios (
  id                INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  rol_id            TINYINT UNSIGNED NOT NULL,
  nombre            VARCHAR(60)  NOT NULL,
  apellido          VARCHAR(60)  NOT NULL,
  correo            VARCHAR(120) NOT NULL UNIQUE,
  password_hash     VARCHAR(255) NOT NULL,
  puesto            VARCHAR(80),
  estado            ENUM('activo','pendiente','inactivo') NOT NULL DEFAULT 'pendiente',
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
  estado          ENUM('activa','inactiva') NOT NULL DEFAULT 'activa',
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
  estado          ENUM('cliente','prospecto','inactivo') NOT NULL DEFAULT 'prospecto',
  cliente_desde   DATE NULL,
  creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_contactos_empresa     FOREIGN KEY (empresa_id)     REFERENCES empresas(id) ON DELETE SET NULL,
  CONSTRAINT fk_contactos_responsable FOREIGN KEY (responsable_id) REFERENCES usuarios(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE etapas (
  id            TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  nombre        VARCHAR(40) NOT NULL UNIQUE,
  orden         TINYINT UNSIGNED NOT NULL,
  probabilidad  TINYINT UNSIGNED NOT NULL,
  CHECK (probabilidad <= 100)
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
  fecha_cierre     DATE NULL,
  motivo_perdida   VARCHAR(200) NULL,
  creado_en        TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_op_cierre (fecha_cierre),
  CONSTRAINT fk_op_empresa     FOREIGN KEY (empresa_id)     REFERENCES empresas(id),
  CONSTRAINT fk_op_contacto    FOREIGN KEY (contacto_id)    REFERENCES contactos(id) ON DELETE SET NULL,
  CONSTRAINT fk_op_etapa       FOREIGN KEY (etapa_id)       REFERENCES etapas(id),
  CONSTRAINT fk_op_responsable FOREIGN KEY (responsable_id) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE productos (
  id           INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sku          VARCHAR(30)  NOT NULL UNIQUE,
  nombre       VARCHAR(120) NOT NULL,
  descripcion  VARCHAR(255),
  precio       DECIMAL(12,2) NOT NULL,
  activo       BOOLEAN NOT NULL DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE oportunidad_producto (
  oportunidad_id   INT UNSIGNED NOT NULL,
  producto_id      INT UNSIGNED NOT NULL,
  cantidad         INT UNSIGNED NOT NULL DEFAULT 1,
  precio_unitario  DECIMAL(12,2) NOT NULL,
  descuento        DECIMAL(5,2)  NOT NULL DEFAULT 0,
  PRIMARY KEY (oportunidad_id, producto_id),
  CONSTRAINT fk_opp_oportunidad FOREIGN KEY (oportunidad_id) REFERENCES oportunidades(id) ON DELETE CASCADE,
  CONSTRAINT fk_opp_producto    FOREIGN KEY (producto_id)    REFERENCES productos(id)
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
  INDEX idx_act_fecha (fecha_hora),
  CONSTRAINT fk_act_usuario     FOREIGN KEY (usuario_id)     REFERENCES usuarios(id),
  CONSTRAINT fk_act_contacto    FOREIGN KEY (contacto_id)    REFERENCES contactos(id) ON DELETE CASCADE,
  CONSTRAINT fk_act_oportunidad FOREIGN KEY (oportunidad_id) REFERENCES oportunidades(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notas (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contacto_id     INT UNSIGNED NOT NULL,
  usuario_id      INT UNSIGNED NOT NULL,
  contenido       TEXT NOT NULL,
  creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notas_contacto FOREIGN KEY (contacto_id) REFERENCES contactos(id) ON DELETE CASCADE,
  CONSTRAINT fk_notas_usuario  FOREIGN KEY (usuario_id)  REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE archivos (
  id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  contacto_id     INT UNSIGNED NOT NULL,
  usuario_id      INT UNSIGNED NOT NULL,
  nombre          VARCHAR(150) NOT NULL,
  ruta            VARCHAR(255) NOT NULL,
  tipo_mime       VARCHAR(80),
  tamano_bytes    INT UNSIGNED,
  creado_en       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_arch_contacto FOREIGN KEY (contacto_id) REFERENCES contactos(id) ON DELETE CASCADE,
  CONSTRAINT fk_arch_usuario  FOREIGN KEY (usuario_id)  REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE notificaciones (
  id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  usuario_id  INT UNSIGNED NOT NULL,
  titulo      VARCHAR(120) NOT NULL,
  mensaje     VARCHAR(255),
  enlace      VARCHAR(255),
  leida       BOOLEAN NOT NULL DEFAULT FALSE,
  creado_en   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO roles (nombre, descripcion) VALUES
 ('Administrador', 'Acceso total'),
 ('Supervisor',    'Ver y editar todo el equipo'),
 ('Vendedor',      'Solo sus registros'),
 ('Solo lectura',  'Consulta sin edición');

INSERT INTO permisos (clave, descripcion) VALUES
 ('ver_todo',            'Ver registros de todo el equipo'),
 ('editar_todo',         'Editar registros de todo el equipo'),
 ('editar_propios',      'Crear y editar sus propios registros'),
 ('eliminar',            'Eliminar registros'),
 ('ver_reportes',        'Consultar reportes'),
 ('administrar_usuarios','Gestionar usuarios, roles y configuración');

INSERT INTO rol_permiso (rol_id, permiso_id) VALUES
 (1,1),(1,2),(1,3),(1,4),(1,5),(1,6),
 (2,1),(2,2),(2,3),(2,5),
 (3,3),
 (4,1),(4,5);

INSERT INTO usuarios (rol_id, nombre, apellido, correo, password_hash, puesto, estado, ultimo_acceso) VALUES
 (2, 'Ana',     'Torres', 'ana.torres@empresa.com',  '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Gerente comercial',   'activo',    '2026-10-27 09:55:00'),
 (3, 'Luis',    'Pérez',  'luis.perez@empresa.com',  '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Ejecutivo de ventas', 'activo',    '2026-10-27 09:00:00'),
 (1, 'Carla',   'Ríos',   'carla.rios@empresa.com',  '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Administradora',      'activo',    '2026-10-26 18:20:00'),
 (3, 'Julio',   'Mena',   'julio.mena@empresa.com',  '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Ejecutivo de ventas', 'activo',    '2026-10-24 12:00:00'),
 (4, 'Paula',   'Soto',   'paula.soto@empresa.com',  '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Analista',            'pendiente', NULL),
 (3, 'Esteban', 'Gil',    'esteban.gil@empresa.com', '$2y$10$eR7O74TWabu3WjxR/FfcM.VwYnDWlaqQb8YZ6B0JA0V5/LcS483km', 'Ejecutivo de ventas', 'inactivo',  '2026-08-20 10:00:00');

INSERT INTO etapas (nombre, orden, probabilidad) VALUES
 ('Prospecto',1,10), ('Calificado',2,25), ('Propuesta',3,50), ('Negociación',4,75), ('Ganado',5,100), ('Perdido',6,0);

INSERT INTO empresas (nombre, rfc, industria, ciudad, estado, responsable_id) VALUES
 ('Grupo Andino',   'GAN010101AB1', 'Manufactura',           'CDMX',        'activa',   1),
 ('Textiles Sur',   'TSU020202CD2', 'Textil',                'Guadalajara', 'activa',   2),
 ('Logística MX',   'LMX030303EF3', 'Transporte',            'Monterrey',   'activa',   3),
 ('Agroval',        'AGR040404GH4', 'Agroindustria',         'Culiacán',    'activa',   1),
 ('FinanPlus',      'FPL050505IJ5', 'Servicios financieros', 'CDMX',        'activa',   2),
 ('Constructora H', 'CHE060606KL6', 'Construcción',          'Puebla',      'inactiva', 3),
 ('MediSalud',      'MSA070707MN7', 'Salud',                 'CDMX',        'activa',   1),
 ('TechNova',       'TNO080808OP8', 'Tecnología',            'Guadalajara', 'activa',   2);

INSERT INTO contactos (empresa_id, responsable_id, nombre, apellido, correo, telefono, puesto, estado, cliente_desde) VALUES
 (1, 1, 'María',   'González', 'maria.gonzalez@grupoandino.com', '+52 55 1234 5678', 'Directora de Compras', 'cliente',   '2024-03-12'),
 (2, 2, 'Jorge',   'Ramírez',  'jramirez@textilessur.com',       '+52 33 9876 5432', 'Gerente de RR. HH.',   'cliente',   '2025-01-20'),
 (3, 3, 'Laura',   'Castillo', 'lcastillo@logisticamx.com',      '+52 81 5555 1212', 'Directora general',    'cliente',   '2023-09-05'),
 (4, 1, 'Pedro',   'Morales',  'pmorales@agroval.com',           '+52 55 4433 2211', 'Gerente de TI',        'prospecto', NULL),
 (5, 2, 'Sofía',   'Vargas',   'svargas@finanplus.com',          '+52 55 7788 9900', 'CFO',                  'cliente',   '2024-11-02'),
 (6, 3, 'Ricardo', 'Herrera',  'rherrera@constructora-h.com',    '+52 22 1122 3344', 'Director de obra',     'inactivo',  NULL),
 (7, 1, 'Daniela', 'Núñez',    'dnunez@medisalud.com',           '+52 55 6655 4433', 'Jefa de sistemas',     'prospecto', NULL),
 (8, 2, 'Andrés',  'Flores',   'aflores@technova.com',           '+52 33 2233 4455', 'CTO',                  'cliente',   '2025-06-15');

INSERT INTO oportunidades (nombre, empresa_id, contacto_id, etapa_id, responsable_id, valor, cierre_estimado, fecha_cierre) VALUES
 ('Plataforma e-commerce B2B', 4, 4, 1, 1, 27300, '2026-12-20', NULL),
 ('Migración a la nube',       7, 7, 1, 1, 22000, '2027-01-15', NULL),
 ('CRM para sucursales',       6, 6, 1, 3, 15800, '2027-01-30', NULL),
 ('Licencias analítica',       5, 5, 2, 2, 41000, '2026-12-10', NULL),
 ('Portal de clientes',        8, 8, 2, 2, 29900, '2026-12-18', NULL),
 ('Módulo RR. HH.',            2, 2, 3, 2, 32500, '2026-11-30', NULL),
 ('Integración ERP',           5, 5, 3, 2, 55000, '2026-12-05', NULL),
 ('Renovación licencias 2027', 1, 1, 4, 1, 48000, '2026-11-15', NULL),
 ('Capacitación anual',        8, 8, 4, 2, 16200, '2026-11-22', NULL),
 ('Soporte anual premium',     3, 3, 5, 3, 18900, '2026-10-20', '2026-10-02');

INSERT INTO productos (sku, nombre, descripcion, precio) VALUES
 ('LIC-USR-ANUAL', 'Licencia por usuario (anual)', 'Acceso completo a Nexo CRM por usuario', 400.00),
 ('MOD-RRHH',      'Módulo RR. HH.',               'Gestión de personal y nómina',           12000.00),
 ('MOD-REPORTES',  'Módulo de reportes',           'Tableros e informes avanzados',           8500.00),
 ('SOP-PREMIUM',   'Soporte anual premium',        'Soporte 24/7 con SLA de 4 h',            18900.00),
 ('CAP-EQUIPO',    'Capacitación de equipo',       'Sesión de 8 h para hasta 20 personas',    5400.00),
 ('INT-ERP',       'Integración ERP',              'Conector bidireccional con ERP',         30000.00);

INSERT INTO oportunidad_producto (oportunidad_id, producto_id, cantidad, precio_unitario, descuento) VALUES
 (8, 1, 120, 400.00, 0),
 (6, 2, 1, 12000.00, 0),
 (6, 1, 51, 400.00, 0),
 (7, 6, 1, 30000.00, 0),
 (7, 1, 63, 400.00, 0),
 (9, 5, 3, 5400.00, 0),
 (10, 4, 1, 18900.00, 0);

INSERT INTO actividades (tipo, asunto, descripcion, fecha_hora, estado, usuario_id, contacto_id, oportunidad_id) VALUES
 ('llamada', 'Llamada con María González', 'Confirmó interés en renovar licencias para 2027. Solicita cotización por 120 usuarios.', '2026-10-27 10:30:00', 'pendiente', 1, 1, 8),
 ('correo',  'Enviar propuesta comercial', NULL, '2026-10-27 15:00:00', 'pendiente', 2, 2, 6),
 ('tarea',   'Actualizar etapa de oportunidad', NULL, '2026-10-27 17:00:00', 'pendiente', 2, 5, 7),
 ('reunion', 'Reunión de cierre', NULL, '2026-10-28 09:00:00', 'pendiente', 3, 3, 10),
 ('tarea',   'Seguimiento a prospecto', NULL, '2026-10-28 12:00:00', 'pendiente', 1, 4, 1),
 ('correo',  'Responder solicitud de demo', NULL, '2026-10-25 11:00:00', 'pendiente', 1, 7, 2),
 ('correo',  'Correo enviado', 'Se envió la propuesta comercial v2 con descuento por volumen.', '2026-10-24 12:00:00', 'completada', 1, 1, 8),
 ('reunion', 'Reunión presencial', 'Presentación del módulo de reportes al equipo de compras.', '2026-10-18 16:00:00', 'completada', 1, 1, 8);

INSERT INTO notas (contacto_id, usuario_id, contenido) VALUES
 (1, 1, 'Prefiere comunicación por correo antes de las 12:00.'),
 (5, 2, 'Evaluando proveedor alterno de ERP; priorizar demo de integración.');

INSERT INTO archivos (contacto_id, usuario_id, nombre, ruta, tipo_mime, tamano_bytes) VALUES
 (1, 1, 'Propuesta comercial v2.pdf', 'uploads/contactos/1/propuesta-v2.pdf', 'application/pdf', 245760);

INSERT INTO notificaciones (usuario_id, titulo, mensaje, enlace) VALUES
 (1, 'Actividad vencida', 'Responder solicitud de demo — MediSalud', 'actividades.php'),
 (1, 'Oportunidad ganada', 'Soporte anual premium — $18.900', 'oportunidades.php');
