# Evidencia 03 — Gestión de claves

## Objetivo
Identificar el problema de colocar claves dentro de scripts y definir cómo evitarlo.

## Comando o procedimiento
Se creó temporalmente `sql/ejemplo-mala-practica.sql` con:
```sql
SELECT pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') FROM clientes_protegidos;
```
Se analizó y **se eliminó antes del commit**:
```powershell
Remove-Item sql\ejemplo-mala-practica.sql
dir sql
```
Después se revisó el repositorio:
```powershell
Get-ChildItem -Recurse -File | Select-String -Pattern 'password|passwd|secret|token|api_key|clave'
```

## Resultado obtenido
-- 7.4 Tabla con credenciales protegidas.
| Mode | LastWriteTime | Length | Name |
| :--- | :--- | :--- | :--- |
| -a---- | 27/10/2026 10:34 p. m. | 2021 | 01-credenciales.sql |
| -a---- | 27/10/2026 10:45 p. m. | 1884 | 02-cifrado-datos.sql |
| -a---- | 28/10/2026 01:22 p. m. | 616 | 03-verificacion-tls.sql |

| Archivo | Línea | Contenido |
| :--- | :--- | :--- |
| `evidencias\01-credenciales.md` | 13 | `<!-- id usuario password` |
| `evidencias\01-credenciales.md` | 14 | `1 juan Password123` |
| `evidencias\01-credenciales.md` | 17 | `### 2. Dos ejecuciones de crypt('Password123', gen_salt('bf'))` |
| `evidencias\01-credenciales.md` | 26 | `\| ID \| Usuario \| Password Hash \|` |
| `evidencias\01-credenciales.md` | 40 | Obtendría de inmediato `juan / Password123`. No necesita romper nada: una filtración de la tabla (SQL injection, respaldo robado, rol con SELECT excesivo) equivale a una filtración de credenciales. Además, como muchas personas reutilizan contraseñas, el daño se extiende a otros sistemas. |
| `evidencias\01-credenciales.md` | 53 | 4. Un hash es una función unidireccional sin clave ni operación de descifrado; el cifrado es reversible con la clave. Para contraseñas se necesita verificar, no recuperar. |
| `evidencias\02-cifrado-datos.md` | 4 | Proteger el campo RFC con cifrado simétrico (`pgp_sym_encrypt`) de forma que no sea legible con un simple `SELECT`, pero pueda recuperarse con la clave. |
| `evidencias\02-cifrado-datos.md` | 15 | `### pgp_sym_decrypt(...) con la clave correcta` |
| `evidencias\02-cifrado-datos.md` | 23 | `### Clave incorrecta` |
| `evidencias\02-cifrado-datos.md` | 25 | `NOTICE: Error con clave incorrecta: Wrong key or corrupt data` |
| `evidencias\02-cifrado-datos.md` | 29 | 1. **`crypt()` vs `pgp_sym_encrypt()`:** `crypt()` genera un hash unidireccional para verificar contraseñas; `pgp_sym_encrypt()` produce texto cifrado (`bytea`) que se puede revertir con la clave. |
| `evidencias\02-cifrado-datos.md` | 31 | 3. **Clave incorrecta:** PostgreSQL lanza un error (`Wrong key or corrupt data`); no devuelve datos. |
| `evidencias\02-cifrado-datos.md` | 32 | 4. **Clave dentro de la consulta:** queda en scripts, historial de `psql`, logs del servidor (`log_statement`, `log_min_duration_statement`), `pg_stat_activity`, repositorios Git, capturas y respaldos. Además, la clave viaja al servidor junto con el dato, por lo que quien administre el servidor o lea sus logs puede obtenerla. |
| `evidencias\02-cifrado-datos.md` | 34 | Observación: dos cifrados del mismo RFC con la misma clave son distintos porque PGP usa valores aleatorios; por eso no se puede buscar por igualdad sobre la columna cifrada. |
| `evidencias\02-cifrado-datos.md` | 37 | El RFC se almacena cifrado porque debe poder recuperarse con justificación. Esto protege contra lecturas directas de la tabla, pero no sustituye el control de acceso ni resuelve dónde guardar la clave. |
| `evidencias\03-gestion-claves.md` | 1 | `# Evidencia 03 — Gestión de claves` |
| `evidencias\03-gestion-claves.md` | 4 | Identificar el problema de colocar claves dentro de scripts y definir cómo evitarlo. |
| `evidencias\03-gestion-claves.md` | 9 | `SELECT pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') FROM clientes_protegidos;` |
| `evidencias\03-gestion-claves.md` | 13 | `grep -RniE 'password\|passwd\|secret\|token\|api_key\|clave' .` |
| `evidencias\03-gestion-claves.md` | 20 | Las coincidencias esperadas corresponden únicamente a valores ficticios de laboratorio (`Password123`, `CLAVE-DE-PRUEBA`) y a nombres de columnas/documentación. |
| `evidencias\03-gestion-claves.md` | 23 | **¿Qué ocurriría si la clave fuera real y el archivo se publicara en Git?** |
| `evidencias\03-gestion-claves.md` | 24 | - Cualquiera con acceso al repositorio podría descifrar todos los datos cifrados con esa clave, si además obtiene la base o un respaldo. |
| `evidencias\03-gestion-claves.md` | 25 | - Git conserva historial: borrar la clave en un commit posterior **no** la elimina de commits anteriores, forks ni clones. |
| `evidencias\03-gestion-claves.md` | 26 | - Habría que considerar la clave comprometida: generar una nueva, re-cifrar todos los datos, rotar y revocar la anterior, y revisar accesos. |
| `evidencias\03-gestion-claves.md` | 29 | **Alternativas correctas:** variables de entorno / variables de `psql` (`-v`), gestor de secretos o KMS (p. ej. Vault, servicios de nube), archivos con permisos restringidos fuera del repositorio, y `.gitignore` para archivos de configuración local. Idealmente el cifrado/descifrado se hace en la aplicación con la clave en un KMS, de modo que la clave nunca esté en el servidor de la base. |
| `evidencias\03-gestion-claves.md` | 32 | Cifrar es tan seguro como la protección de la clave. La clave se separa del código, de los datos y de los respaldos, y se gestiona con un ciclo de vida definido (ver evidencia 10). |
| `sql\01-credenciales.sql` | 13 | `password VARCHAR(100) NOT NULL` |
| `sql\01-credenciales.sql` | 15 | `INSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');` |
| `sql\01-credenciales.sql` | 19 | `SELECT crypt('Password123', gen_salt('bf')) AS hash_1;` |
| `sql\01-credenciales.sql` | 20 | `SELECT crypt('Password123', gen_salt('bf')) AS hash_2;` |
| `sql\01-credenciales.sql` | 22 | `-- 7.4 TINSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');SELECT * FROM usuarios_insegura;INSERT INTO usuarios_insegura (usuario, password) VALUES ('juan', 'Password123');abla con credenciales protegidas` |
| `sql\01-credenciales.sql` | 27 | `password_hash TEXT NOT NULL` |
| `sql\01-credenciales.sql` | 29 | `INSERT INTO usuarios_segura (usuario, password_hash)` |
| `sql\01-credenciales.sql` | 30 | `VALUES ('juan', crypt('Password123', gen_salt('bf')));` |
| `sql\01-credenciales.sql` | 34 | `SELECT usuario, password_hash = crypt('Password123', password_hash) AS contraseña_correcta` |
| `sql\01-credenciales.sql` | 36 | `SELECT usuario, password_hash = crypt('OtraPassword', password_hash) AS contraseña_correcta` |
| `sql\01-credenciales.sql` | 39 | `-- Extra: mismo password, dos usuarios -> hashes distintos gracias a la sal` |
| `sql\01-credenciales.sql` | 40 | `INSERT INTO usuarios_segura (usuario, password_hash)` |
| `sql\01-credenciales.sql` | 41 | `VALUES ('maria', crypt('Password123', gen_salt('bf', 10)));` |
| `sql\01-credenciales.sql` | 42 | `SELECT usuario, left(password_hash, 7) AS prefijo_algoritmo_costo, password_hash FROM usuarios_segura;` |
| `sql\02-cifrado-datos.sql` | 1 | `-- LAB-02 / Actividades 2 y 3 - Cifrado de información sensible y gestión de claves` |
| `sql\02-cifrado-datos.sql` | 2 | `-- La clave 'CLAVE-DE-PRUEBA' es ficticia y exclusiva de laboratorio.` |
| `sql\02-cifrado-datos.sql` | 3 | `-- Ejecutar: psql "..." -a -v clave_lab="$LAB_CLAVE" -f sql/02-cifrado-datos.sql` |
| `sql\02-cifrado-datos.sql` | 4 | `-- (export LAB_CLAVE=CLAVE-DE-PRUEBA en la terminal; así la clave no vive en el archivo .sql)` |
| `sql\02-cifrado-datos.sql` | 16 | `-- Versión del manual (clave literal, SOLO demostrativa)` |
| `sql\02-cifrado-datos.sql` | 18 | `VALUES ('Ana López', pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA'));` |
| `sql\02-cifrado-datos.sql` | 23 | `SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') AS rfc` |
| `sql\02-cifrado-datos.sql` | 26 | `-- Misma clave y mismo texto -> distinto texto cifrado (sal/clave de sesión aleatorias)` |
| `sql\02-cifrado-datos.sql` | 27 | `SELECT pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA') = pgp_sym_encrypt('LOPA900101ABC', 'CLAVE-DE-PRUEBA') AS cifrados_iguales;` |
| `sql\02-cifrado-datos.sql` | 29 | `-- Clave incorrecta: se captura el error para que el script continúe` |
| `sql\02-cifrado-datos.sql` | 32 | `PERFORM pgp_sym_decrypt(rfc_cifrado, 'CLAVE-INCORRECTA') FROM clientes_protegidos;` |
| `sql\02-cifrado-datos.sql` | 34 | `RAISE NOTICE 'Error con clave incorrecta: %', SQLERRM;` |
| `sql\02-cifrado-datos.sql` | 37 | `-- Mejor práctica: la clave llega como variable de psql, no escrita en el archivo` |
| `sql\02-cifrado-datos.sql` | 38 | `\if :{?clave_lab}` |
| `sql\02-cifrado-datos.sql` | 40 | `VALUES ('Luis Pérez', pgp_sym_encrypt('PEPL850505XYZ', :'clave_lab'));` |
| `sql\02-cifrado-datos.sql` | 41 | `SELECT id, nombre, pgp_sym_decrypt(rfc_cifrado, :'clave_lab') AS rfc FROM clientes_protegidos;` |
| `sql\02-cifrado-datos.sql` | 43 | `\echo 'AVISO: variable clave_lab no definida. Ejecuta con -v clave_lab="$LAB_CLAVE"'` |


## Análisis
**¿Qué ocurriría si la clave fuera real y el archivo se publicara en Git?**
- Cualquiera con acceso al repositorio podría descifrar todos los datos cifrados con esa clave, si además obtiene la base o un respaldo.
- Git conserva historial: borrar la clave en un commit posterior **no** la elimina de commits anteriores, forks ni clones.
- Habría que considerar la clave comprometida: generar una nueva, re-cifrar todos los datos, rotar y revocar la anterior, y revisar accesos.
- Un repositorio privado no lo evita: reduce exposición pero siguen teniendo acceso colaboradores, runners de CI, copias locales y posibles filtraciones de cuentas.

**Alternativas correctas:** variables de entorno / variables de `psql` (`-v`), gestor de secretos o KMS (p. ej. Vault, servicios de nube), archivos con permisos restringidos fuera del repositorio, y `.gitignore` para archivos de configuración local. Idealmente el cifrado/descifrado se hace en la aplicación con la clave en un KMS, de modo que la clave nunca esté en el servidor de la base.

## Conclusión
Cifrar es tan seguro como la protección de la clave. La clave se separa del código, de los datos y de los respaldos, y se gestiona con un ciclo de vida definido (ver evidencia 10).
