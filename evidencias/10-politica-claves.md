# Evidencia 10 — Política mínima de protección de claves

## Objetivo
Definir reglas para el ciclo de vida de las claves criptográficas de Comercializadora Norte S.A. de C.V.

## Comando o procedimiento
Redacción de política a partir de los conceptos de la práctica.

## Resultado obtenido — Política (10 reglas)

1. **Generación.** Las claves se generan con un generador criptográficamente seguro (p. ej. `openssl rand`, KMS o HSM), con longitud suficiente. Nunca se derivan de frases simples ni se reutilizan entre ambientes (desarrollo, pruebas, producción).
2. **Almacenamiento.** Se guardan en un gestor de secretos o KMS, nunca en el repositorio, scripts, tablas de la misma base que protegen ni en documentación.
3. **Separación.** La clave se almacena en un lugar distinto al de los datos y de sus respaldos; quien tenga el respaldo no debe tener la clave.
4. **Acceso.** Acceso por mínimo privilegio y necesidad de saber, con identidades individuales o de servicio, y con registro (auditoría) de cada uso.
5. **Rotación.** Se rotan periódicamente (p. ej. cada 12 meses) y de inmediato ante sospecha de compromiso o salida de personal con acceso; los datos se re-cifran con la nueva clave.
6. **Respaldo.** Existe una copia de las claves cifrada y protegida, probada periódicamente; perder una clave equivale a perder los datos cifrados.
7. **Revocación.** Las claves comprometidas o dadas de baja se revocan de inmediato, se deja de usarlas para cifrar y se documenta la fecha y el motivo.
8. **Exposición accidental.** Si una clave aparece en Git, logs o capturas, se considera comprometida: se rota, se re-cifran los datos, se revoca la anterior y se registra el incidente. Borrar el commit no es suficiente. Se usa `.gitignore` y verificación de secretos antes de cada commit.
9. **Eliminación.** Al terminar su vida útil, las claves se destruyen de forma segura y se conserva solo el tiempo necesario para descifrar datos históricos que aún deban recuperarse.
10. **Uso.** Las claves se entregan a las aplicaciones mediante variables de entorno o el gestor de secretos en tiempo de ejecución, no por consultas SQL escritas a mano, y se evita que aparezcan en logs (`log_statement`).

## Análisis
Las reglas cubren generación, almacenamiento, acceso, rotación, respaldo, revocación, exposición accidental y eliminación, y reconocen que la seguridad de los datos cifrados depende de la gestión de la clave.

## Conclusión
Una política escrita y verificable convierte el cifrado en un control real.
