-- LAB-02 / Actividad 1 - Protección de credenciales
-- Todos los valores son ficticios (solo laboratorio).
-- Ejecutar: psql "host=localhost dbname=TU_BASE user=TU_USUARIO" -a -f sql/01-credenciales.sql

CREATE EXTENSION IF NOT EXISTS pgcrypto;
SELECT extname FROM pg_extension WHERE extname = 'pgcrypto';

-- 7.1 Implementación INCORRECTA (texto claro)
DROP TABLE IF EXISTS usuarios_insegura;
CREATE TABLE usuarios_insegura (
  id BIGSERIAL PRIMARY KEY,
  usuario VARCHAR(50) NOT NULL,
  password VARCHAR(100) NOT NULL
);
INSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');
SELECT * FROM usuarios_insegura;
SELECT * FROM usuarios_insegura;
-- 7.3 Hash con sal aleatoria: ejecutar dos veces y comparar
SELECT crypt('Password123', gen_salt('bf')) AS hash_1;
SELECT crypt('Password123', gen_salt('bf')) AS hash_2;

-- 7.4 TINSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');SELECT * FROM usuarios_insegura;INSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');abla con credenciales protegidas
DROP TABLE IF EXISTS usuarios_segura;
CREATE TABLE usuarios_segura (
  id BIGSERIAL PRIMARY KEY,
  usuario VARCHAR(50) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL
);
INSERT INTO usuarios_segura (usuario, password_hash)
VALUES ('juan', crypt('Password123', gen_salt('bf')));
SELECT * FROM usuarios_segura;

-- 7.5 Verificación
SELECT usuario, password_hash = crypt('Password123', password_hash) AS contraseña_correcta
FROM usuarios_segura WHERE usuario = 'juan';
SELECT usuario, password_hash = crypt('OtraPassword', password_hash) AS contraseña_correcta
FROM usuarios_segura WHERE usuario = 'juan';

-- Extra: mismo password, dos usuarios -> hashes distintos gracias a la sal
INSERT INTO usuarios_segura (usuario, password_hash)
VALUES ('maria', crypt('Password123', gen_salt('bf', 10)));
SELECT usuario, left(password_hash, 7) AS prefijo_algoritmo_costo, password_hash FROM usuarios_segura;
