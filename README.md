# LAB-02 — Cifrado, credenciales y comunicaciones seguras

Alumno: *Navarrete Diaz Luis Alejandro* · Materia: Gestion de Seguridad y Fundamentos de Base de Datos· Motor: PostgreSQL 18

## 1. Introducción
Un esquema correcto de usuarios y permisos no basta: las contraseñas, los datos sensibles, las comunicaciones, las claves y los respaldos también deben protegerse. Este laboratorio implementa y verifica mecanismos básicos de protección criptográfica en PostgreSQL.

## 2. Protección de credenciales
- **Texto claro:** la contraseña se lee directamente; inaceptable.
- **Hash (con sal):** función unidireccional; solo permite verificar. Es lo correcto para contraseñas (`crypt()` + `gen_salt('bf')`).
- **Cifrado:** reversible con una clave; apropiado para datos que deben recuperarse (p. ej. RFC), no para contraseñas.
Ver `sql/01-credenciales.sql` y `evidencias/01-credenciales.md`.

## 3. Protección de datos sensibles
Se protegió el **RFC** con `pgp_sym_encrypt` en `clientes_protegidos`, porque es un dato personal/fiscal que debe poder recuperarse con justificación. Ver `sql/02-cifrado-datos.sql` y `evidencias/02-cifrado-datos.md`.

## 4. TLS
TLS protege confidencialidad, integridad y autenticación del servidor en tránsito. Se verificó con `SHOW ssl`, `ssl_min_protocol_version` y `pg_stat_ssl` (versión y cipher de la sesión). Se explicaron los `sslmode` y por qué `verify-full` es el modo de validación fuerte. Ver `sql/03-verificacion-tls.sql` y `evidencias/04-tls.md`.

## 5. Gestión de claves
Una clave junto a los scripts se expone vía Git (con historial), logs, respaldos y capturas, y quien la obtiene descifra todo. Las claves se guardan en un gestor de secretos/KMS, separadas de los datos y del código. Ver `evidencias/03-gestion-claves.md` y `evidencias/10-politica-claves.md`.

## 6. Resultados
*(Completa con tus resultados reales: hashes distintos por la sal, verificación `t`/`f`, RFC ilegible y recuperable con la clave, error con clave incorrecta, valores de `pg_stat_ssl`.)*

## 7. Problemas encontrados
*(Documenta aquí tus errores reales: p. ej. `pgcrypto` sin permisos de creación, `ssl = off`, conexión por socket que muestra `ssl = f`, etc.)*

## 8. Conclusiones
Aprendí que cada riesgo requiere su mecanismo: hash para contraseñas, cifrado para datos recuperables, TLS para tránsito, cifrado de respaldos y gestión de claves como base de todo. En producción aplicaría `verify-full`, contraseñas con Argon2id/bcrypt desde la aplicación, claves en un KMS con rotación, respaldos cifrados y revisión de secretos antes de cada commit.

> Nota: los valores `Password123` y `CLAVE-DE-PRUEBA` son ficticios y exclusivos del laboratorio; por eso pueden aparecer en la búsqueda con `grep`.

## Preguntas de reflexión
1. **¿Por qué una contraseña no debe almacenarse como texto claro?** una filtración o lectura de la tabla entrega las credenciales directamente, y como se reutilizan, afecta otros sistemas.
2. **¿Por qué un hash no es equivalente a un cifrado?** el hash es unidireccional y sirve para verificar; el cifrado es reversible con una clave.
3. **¿Por qué el cifrado de una columna no sustituye al control de acceso?** el cifrado no define quién puede pedir o descifrar datos; si un usuario tiene la clave o acceso a la función de descifrado, ve todo. Además, el cifrado no regula operaciones como borrar o modificar.
4. **¿Por qué TLS no sustituye a los mecanismos de autorización de PostgreSQL?** TLS protege el canal y autentica al servidor, pero no decide qué puede hacer un usuario autenticado; eso lo hacen roles y privilegios.
5. **¿Qué ocurriría si una organización pierde una clave utilizada para cifrar información?** los datos cifrados quedan irrecuperables (pérdida permanente de información), por eso se respalda la clave de forma segura.
6. **¿Qué ocurriría si una clave criptográfica se publica accidentalmente en GitLab?** queda comprometida y permanece en el historial; hay que rotarla, re-cifrar los datos, revocarla y revisar accesos.
7. **¿Por qué un repositorio privado no debe considerarse un almacén de secretos?** reduce la exposición pero no la elimina (colaboradores, CI, clones, cuentas comprometidas) y conserva el historial; los secretos pertenecen a un gestor de secretos.
8. **¿Qué diferencia existe entre proteger información almacenada y proteger información
durante su transmisión?** lo almacenado (tablas, discos, respaldos) se protege con cifrado/hash; lo que viaja por la red, con TLS.
9. **¿Por qué la gestión de claves es tan importante como el algoritmo criptográfico?** un algoritmo robusto es inútil si la clave se expone, se pierde o se gestiona mal; la seguridad práctica recae en la clave.
10. **¿Qué mecanismo adicional implementarías en una organización para proteger los respaldos de las bases de datos?** cifrado de los respaldos con claves separadas y gestionadas en un KMS, almacenamiento con acceso restringido, copias fuera del sitio y pruebas de restauración.

## Verificación final
- Contraseña: se protege con derivación/hash para contraseñas, no con cifrado.
- Enmascaramiento oculta parcialmente el dato para presentación; seudonimización sustituye identificadores manteniendo una relación recuperable separada; cifrado transforma el dato de forma reversible con clave.
- TLS protege la comunicación cliente-servidor.
- La clave se guarda en un gestor de secretos/KMS/HSM, no junto con código ni datos.
- ¿Subir una clave real a GitLab aunque sea privado? **No.**
