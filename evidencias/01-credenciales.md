# Evidencia 01 — Protección de credenciales

## Objetivo
Demostrar por qué una contraseña en texto claro es un riesgo y cómo almacenar únicamente un hash con sal (bcrypt vía `pgcrypto`) permite verificar la contraseña sin poder recuperarla.

## Comando o procedimiento


## Resultado obtenido

### 1. Tabla insegura (`SELECT * FROM usuarios_insegura;`)
```
<!-- id	usuario	password
     1	juan	Password123
 -->
```
### 2. Dos ejecuciones de `crypt('Password123', gen_salt('bf'))`
```
<!-- 
    "hash_1": "$2a$06$SCf8JRvcR63a75Ayp9iRauRocL97yTQRcgORzORcu18izcMNN/v8G"
    "hash_2": "$2a$06$0JUoejj2iondybnnpvonwubPLoDTux6VJG2BY.aBNnsQ.HeIk4oWy"
 -->
```
### 3. Tabla `usuarios_segura`

| ID | Usuario | Password Hash |
| :--- | :--- | :--- |
| 1 | juan | `$2a$06$GFHmV4EX2iqQ4m3GkPHbVOnU3qwa2Du/io0AknschvZX7lHG7sdSO` |

### 4. Verificación (contraseña correcta / incorrecta)

| Usuario | Contraseña Correcta |
| :--- | :--- |
| juan | `true` |
| juan | `false` |

## Análisis

**7.1 ¿Qué ocurriría si alguien obtiene acceso de lectura a `usuarios_insegura`?**
Obtendría de inmediato `juan / Password123`. No necesita romper nada: una filtración de la tabla (SQL injection, respaldo robado, rol con SELECT excesivo) equivale a una filtración de credenciales. Además, como muchas personas reutilizan contraseñas, el daño se extiende a otros sistemas.

**7.3**
1. ¿Son iguales? **No**, cada ejecución produce un valor distinto.
2. ¿Por qué? Porque `gen_salt('bf')` genera una sal aleatoria nueva en cada llamada y la sal forma parte del resultado.
3. `gen_salt()` genera la sal aleatoria (y define el algoritmo y costo: `bf` = bcrypt). Evita que contraseñas iguales produzcan hashes iguales y vuelve poco útiles las tablas precalculadas.
4. `crypt()` combina la contraseña con la sal y calcula el hash (bcrypt, deliberadamente lento). El resultado incluye algoritmo, costo, sal y hash.
5. **No es cifrado reversible.** No existe una función para obtener la contraseña a partir del hash; solo se puede comprobar recalculando.

**7.5**
1. Con la contraseña correcta el resultado es `t` (true).
2. Con la incorrecta es `f` (false).
3. No hace falta recuperarla porque basta con recalcular `crypt(candidata, hash_guardado)`, que reutiliza la sal almacenada, y comparar.
4. Un hash es una función unidireccional sin clave ni operación de descifrado; el cifrado es reversible con la clave. Para contraseñas se necesita verificar, no recuperar.

**Extra:** `juan` y `maria` usan la misma contraseña y sus hashes son distintos por la sal.

**Limitaciones (7.6):** bcrypt (`bf`) es aceptable pero `pgcrypto` no ofrece Argon2id; bcrypt solo considera los primeros 72 bytes de la contraseña; el costo por defecto (6) es bajo, conviene subirlo (`gen_salt('bf', 12)`). En una aplicación real el hash se calcula normalmente en la aplicación con la librería del framework, para que la contraseña en claro no viaje en una consulta SQL que pudiera quedar en logs.

## Conclusión
Las contraseñas no se guardan ni se cifran: se almacena un hash con sal generado con un algoritmo diseñado para contraseñas. Esto limita el daño de una filtración, aunque no sustituye una buena política de contraseñas ni el control de acceso.
