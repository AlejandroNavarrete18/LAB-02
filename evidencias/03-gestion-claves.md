# Evidencia 03 — Gestión de claves

## Objetivo
Identificar el problema de colocar claves dentro de scripts y definir cómo evitarlo.

## Comando o procedimiento
Se creó temporalmente `sql/ejemplo-mala-practica.sql` con:
```sql
SELECT pgp_sym_decrypt(rfc_cifrado, 'CLAVE-DE-PRUEBA') FROM clientes_protegidos;
```
Se analizó y **se eliminó antes del commit** (`rm sql/ejemplo-mala-practica.sql`). Después se revisó el repositorio:
```bash
grep -RniE 'password|passwd|secret|token|api_key|clave' .
```

## Resultado obtenido
```
<!-- PEGA AQUÍ la salida del grep y confirma que ejemplo-mala-practica.sql ya no existe (ls sql/) -->
```
Las coincidencias esperadas corresponden únicamente a valores ficticios de laboratorio (`Password123`, `CLAVE-DE-PRUEBA`) y a nombres de columnas/documentación.

## Análisis
**¿Qué ocurriría si la clave fuera real y el archivo se publicara en Git?**
- Cualquiera con acceso al repositorio podría descifrar todos los datos cifrados con esa clave, si además obtiene la base o un respaldo.
- Git conserva historial: borrar la clave en un commit posterior **no** la elimina de commits anteriores, forks ni clones.
- Habría que considerar la clave comprometida: generar una nueva, re-cifrar todos los datos, rotar y revocar la anterior, y revisar accesos.
- Un repositorio privado no lo evita: reduce exposición pero siguen teniendo acceso colaboradores, runners de CI, copias locales y posibles filtraciones de cuentas.

**Alternativas correctas:** variables de entorno / variables de `psql` (`-v`), gestor de secretos o KMS (p. ej. Vault, servicios de nube), archivos con permisos restringidos fuera del repositorio, y `.gitignore` para archivos de configuración local. Idealmente el cifrado/descifrado se hace en la aplicación con la clave en un KMS, de modo que la clave nunca esté en el servidor de la base.

## Conclusión
Cifrar es tan seguro como la protección de la clave. La clave se separa del código, de los datos y de los respaldos, y se gestiona con un ciclo de vida definido (ver evidencia 10).
