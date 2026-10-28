-- LAB-02 / Actividades 4-6 - Verificación de TLS

SHOW ssl;
SHOW ssl_min_protocol_version;
SHOW port;
SHOW listen_addresses;

SELECT inet_client_addr(), inet_client_port();

-- ¿Mi sesión usa TLS?
SELECT ssl, version, cipher FROM pg_stat_ssl WHERE pid = pg_backend_pid();

-- Todas las conexiones activas y su estado TLS
SELECT a.pid, a.usename, a.client_addr, s.ssl, s.version, s.cipher
FROM pg_stat_ssl s JOIN pg_stat_activity a USING (pid)
WHERE a.backend_type = 'client backend';

-- Parámetros ssl del servidor
SELECT name, setting FROM pg_settings WHERE name LIKE 'ssl%' ORDER BY name;
