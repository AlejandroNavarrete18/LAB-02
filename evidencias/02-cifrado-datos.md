# Evidencia 02 — Cifrado de información sensible (RFC)

## Objetivo
Proteger el campo RFC con cifrado simétrico (`pgp_sym_encrypt`) de forma que no sea legible con un simple `SELECT`, pero pueda recuperarse con la clave.

## Comando o procedimiento


## Resultado obtenido

### `SELECT * FROM clientes_protegidos;`
| ID | Nombre | RFC Cifrado |
| :--- | :--- | :--- |
| 1 | Ana López | `{"type": "Buffer", "data": [195, 13, 4, 7, 3, 2, 244, 67, 185, 4, 237, 67, 250, 94, 96, 210, 62, 1, 140, 28, 54, 117, 40, 109, 163, 189, 211, 102, 110, 155, 240, 24, 189, 235, 239, 205, 144, 37, 82, 36, 191, 180, 17, 152, 82, 173, 220, 183, 175, 90, 244, 134, 49, 192, 4, 95, 150, 191, 48, 63, 34, 166, 118, 93, 132, 85, 44, 182, 54, 38, 115, 66, 154, 174, 116, 158, 95, 140, 200]}` |
### `pgp_sym_decrypt(...)` con la clave correcta
| ID | Nombre | RFC |
| :--- | :--- | :--- |
| 1 | Ana López | LOPA900101ABC |
### Comparación de dos cifrados del mismo texto
| Cifrados Iguales |
| :--- |
| `false` |
### Clave incorrecta
```
NOTICE: Error con clave incorrecta: Wrong key or corrupt data
```

## Análisis
1. **`crypt()` vs `pgp_sym_encrypt()`:** `crypt()` genera un hash unidireccional para verificar contraseñas; `pgp_sym_encrypt()` produce texto cifrado (`bytea`) que se puede revertir con la clave.
2. **Permite recuperar el dato original:** `pgp_sym_encrypt()` (con `pgp_sym_decrypt()`).
3. **Clave incorrecta:** PostgreSQL lanza un error (`Wrong key or corrupt data`); no devuelve datos.
4. **Clave dentro de la consulta:** queda en scripts, historial de `psql`, logs del servidor (`log_statement`, `log_min_duration_statement`), `pg_stat_activity`, repositorios Git, capturas y respaldos. Además, la clave viaja al servidor junto con el dato, por lo que quien administre el servidor o lea sus logs puede obtenerla.

Observación: dos cifrados del mismo RFC con la misma clave son distintos porque PGP usa valores aleatorios; por eso no se puede buscar por igualdad sobre la columna cifrada.

## Conclusión
El RFC se almacena cifrado porque debe poder recuperarse con justificación. Esto protege contra lecturas directas de la tabla, pero no sustituye el control de acceso ni resuelve dónde guardar la clave.
