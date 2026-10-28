# Evidencia 08 — Análisis de escenario de seguridad

## Objetivo
Identificar riesgos y controles en una empresa con usuarios y roles correctos pero con otras debilidades criptográficas.

## Comando o procedimiento
Análisis del escenario de la Actividad 8.

## Resultado obtenido

### Pregunta 1 ¿Cuáles son los principales riesgos?
| Debilidad | Riesgo |
|---|---|
| Contraseñas en texto claro | Una filtración o lectura de la tabla entrega credenciales utilizables, también en otros sistemas por reutilización |
| RFC en texto claro | Exposición de datos personales/fiscales; riesgo de suplantación de identidad e incumplimiento normativo |
| Conexiones sin validación del servidor | Escucha o modificación de tráfico y ataques de intermediario (MITM), suplantación del servidor |
| Claves en archivos SQL | Cualquiera con acceso al archivo o al repositorio puede descifrar datos; la clave queda en el historial |
| Respaldos sin protección | Un respaldo robado o mal compartido expone toda la base saltándose usuarios y roles |

La información financiera y los datos como nombre y correo quedan expuestos si no se aplican los mismos controles.

### Pregunta 2 ¿Qué mecanismo utilizarías para cada elemento?
| Elemento | Mecanismo |
|---|---|
| Nombre, correo | Control de acceso, enmascaramiento según rol; TLS en tránsito |
| Contraseña | Hash con sal (Argon2id/bcrypt/scrypt) |
| RFC | Cifrado de columna con clave externa (o enmascaramiento/seudonimización si no se requiere el valor) |
| Información financiera | Cifrado de columna o de disco, mínimo privilegio, auditoría |
| Claves criptográficas | Gestor de secretos/KMS, rotación, acceso restringido, nunca en el código |
| Conexiones | TLS con `verify-full` y CA confiable |
| Respaldos | Cifrado del respaldo, claves separadas, acceso restringido |

### Pregunta 3 ¿Cuál de los problemas consideras más crítico y por qué?
**Las claves criptográficas en archivos SQL.** Una clave expuesta anula el cifrado de todos los datos que protege, y en Git queda en el historial aunque se borre, de modo que el cifrado deja de ofrecer protección real. Además, una vez expuesta, la clave permite descifrar cualquier dato cifrado con ella (RFC, información financiera) si el atacante obtiene la base o un respaldo, y los respaldos sin protección de este escenario lo facilitan.

Las contraseñas en texto claro son el segundo problema más grave: el impacto es inmediato y no requiere esfuerzo del atacante, pero afecta a las credenciales y se corrige con hash y cambio de contraseñas, mientras que una clave comprometida obliga a rotarla y re-cifrar todos los datos.

### Pregunta 4 ¿Tener correctamente configurados los usuarios y permisos elimina estos riesgos?
**No.** El control de acceso solo regula quién puede consultar a través del motor. No protege contra: robo de respaldos o discos, lectura del tráfico de red, exposición de claves en código, ni contra un DBA o atacante con privilegios altos que lea datos en claro. Por eso la protección es por capas (defensa en profundidad): acceso, cifrado, TLS, gestión de claves y respaldos protegidos.

## Análisis
Un buen esquema de roles es necesario pero no suficiente; cada debilidad del escenario abre una ruta que evita el control de acceso.

## Conclusión
La seguridad debe analizarse de forma integral: datos almacenados, comunicaciones, credenciales, claves y respaldos.
