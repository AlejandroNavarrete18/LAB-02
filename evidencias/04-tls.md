# Evidencia 04 — Verificación de TLS en PostgreSQL

## Objetivo
Verificar el estado real de TLS en el servidor y en la sesión actual, y comprender los distintos `sslmode`.

## Comando o procedimiento
1. Se verificó el estado de TLS en el servidor con las sentencias de `sql/03-verificacion-tls.sql`, desde SQLTools (conexión Lab01, postgres@localhost:5432).
2. Como `ssl` estaba en `off`, se generó un certificado autofirmado de laboratorio en la carpeta de datos de PostgreSQL 18:
```powershell
openssl req -new -x509 -days 365 -nodes -text -out server.crt -keyout server.key -subj "/CN=localhost"
```
3. Se configuró TLS con `ALTER SYSTEM SET ssl_cert_file`, `ssl_key_file`, `ssl_min_protocol_version = 'TLSv1.2'` y `ssl = on`, y se reinició el servicio.
4. Se comprobó una sesión con TLS desde `psql`:
```powershell
psql "host=localhost port=5432 dbname=postgres user=postgres sslmode=require"
```
## Resultado obtenido
## Resultado obtenido
| ssl | ssl_min_protocol_version | port | listen_addresses |
| :--- | :--- | :--- | :--- |
| `on` | TLSv1.2 | `5432` | `*` |

| inet_client_addr | inet_client_port |
| :--- | :--- |
| `::1` | `57630` |

| ssl | version | cipher |
| :--- | :--- | :--- |
| `t` | TLSv1.3 | `TLS_AES_256_GCM_SHA384` |

## Análisis
1. **¿La conexión usa TLS?** La sesión de SQLTools no (ssl = false). La de psql con sslmode=require sí (ssl = t).
2. **Versión:** TLSv1.3 (sesión de `psql` con `sslmode=require`).
3. **Algoritmo:** TLS_AES_256_GCM_SHA384 (AES de 256 bits en modo GCM).
4. **Con TLS vs. sin TLS:** sin TLS, consultas, resultados y credenciales viajan legibles y modificables para quien observe la red; con TLS hay confidencialidad, integridad y (con validación de certificados) autenticación del servidor.

**sslmode:**
| Modo | Qué hace |
|---|---|
| disable | Sin TLS |
| prefer | Intenta TLS, cae a texto claro si falla (vulnerable a downgrade) |
| require | Exige TLS, no valida certificado: protege de escuchas pasivas, no de suplantación |
| verify-ca | TLS + certificado firmado por CA confiable |
| verify-full | verify-ca + el nombre del host coincide con el certificado; el modo recomendado cuando importa la identidad del servidor |

`SHOW ssl = on` solo indica que el servidor soporta TLS; lo que realmente protege es lo que muestra `pg_stat_ssl` por sesión.

## Conclusión
En este laboratorio se activó TLS en PostgreSQL 18 con un certificado autofirmado y se comprobó con `pg_stat_ssl` que una conexión con `sslmode=require` negoció TLSv1.3. Como el certificado es autofirmado y `require` no lo valida, esta configuración cifra el tráfico pero no garantiza la identidad del servidor; para eso se necesitaría una CA confiable y `verify-full`.