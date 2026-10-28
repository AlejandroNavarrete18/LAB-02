-- LAB-02 / Actividades 2 y 3 - Cifrado de información sensible y gestión de claves
-- La clave 'CLAVE-DE-PRUEBA' es ficticia y exclusiva de laboratorio.
-- Ejecutar: psql "..." -a -v clave_lab="$LAB_CLAVE" -f sql/02-cifrado-datos.sql
-- (export LAB_CLAVE=CLAVE-DE-PRUEBA en la terminal; así la clave no vive en el archivo .sql)

CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- 8.1 Tabla de demostración
DROP TABLE IF EXISTS clientes_protegidos;
CREATE TABLE clientes_protegidos (
  id BIGSERIAL PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  rfc_cifrado BYTEA NOT NULL
);

-- Versión del manual (clave literal, SOLO demostrativa)
INSERT INTO clientes_protegidos (nombre, rfc_cifrado)
VALUES ('Ana López', pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA'));

SELECT * FROM clientes_protegidos;

-- 8.2 Recuperar el dato
SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') AS rfc
FROM clientes_protegidos;

-- Misma clave y mismo texto -> distinto texto cifrado (sal/clave de sesión aleatorias)
SELECT pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA') = pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA') AS cifrados_iguales;

-- Clave incorrecta: se captura el error para que el script continúe
DO $$
BEGIN
  PERFORM pgp_sym_decrypt(rfc_cifrado, 'CLAVE-INCORRECTA') FROM clientes_protegidos;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'Error con clave incorrecta: %', SQLERRM;
END $$;

-- Mejor práctica: la clave llega como variable de psql, no escrita en el archivo
\if :{?clave_lab}
  INSERT INTO clientes_protegidos (nombre, rfc_cifrado)
  VALUES ('Luis Pérez', pgp_sym_encrypt('PEPL850505XYZ', :'clave_lab'));
  SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, :'clave_lab') AS rfc FROM clientes_protegidos;
\else
  \echo 'AVISO: variable clave_lab no definida. Ejecuta con -v clave_lab="$LAB_CLAVE"'
\endif


