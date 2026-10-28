# Evidencia 07 — Protección en reposo vs. protección en tránsito

## Objetivo
Asociar cada situación con el mecanismo apropiado y lo que protege.

## Comando o procedimiento
Análisis conceptual basado en las actividades 1 a 6 (no requiere comandos).

## Resultado obtenido
| Situación | Mecanismo apropiado | ¿Qué protege? |
|---|---|---|
| Contraseña de usuario | Hash con sal y algoritmo para contraseñas (bcrypt/Argon2id/scrypt); en PostgreSQL de laboratorio `crypt()` + `gen_salt('bf')` | Confidencialidad de la credencial ante una filtración (en reposo); no se puede recuperar, solo verificar |
| RFC almacenado en una tabla | Cifrado simétrico (`pgp_sym_encrypt`) con clave gestionada fuera de la BD, más control de acceso | Confidencialidad del dato en reposo frente a lectura directa de tablas, discos o respaldos |
| Consulta enviada desde un cliente al servidor | TLS (idealmente `sslmode=verify-full`) | Confidencialidad e integridad en tránsito, y autenticación del servidor |
| Respaldo de una base de datos | Cifrado del respaldo (p. ej. GPG/age o cifrado del almacenamiento) con clave separada | Confidencialidad del dato en reposo en archivos fuera del servidor |
| Clave criptográfica | Gestión segura de claves: gestor de secretos/KMS/HSM, acceso mínimo, rotación, respaldo y revocación | La clave misma, de la que depende toda la protección de los datos cifrados |

## Análisis
Los datos en reposo (contraseñas, RFC, respaldos) se protegen con hash o cifrado; los datos en tránsito, con TLS. Ningún mecanismo cubre los otros casos: TLS no protege una tabla leída directamente y el cifrado de columnas no protege la red. Todo el esquema depende de gestionar bien las claves.

## Conclusión
Cada riesgo requiere su propio control y se complementan entre sí.
