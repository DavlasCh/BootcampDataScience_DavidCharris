## TALLER 02 – SQL Práctico (Sakila)
## Base de datos: SAKILA
## Descripción: Resolución de ejercicios prácticos de SQL
##      usando SELECT, WHERE, ORDER BY, JOIN,
##      INSERT, UPDATE, DELETE y consultas avanzadas.


USE sakila;

##PARTE 1 – SELECT y WHERE

##1. Mostrar nombre y apellido de todos los clientes
##Tablas usadas: customer
##Se seleccionan las columnas first_name y last_name de la tabla customer
SELECT
    first_name  AS Nombre,
    last_name   AS Apellido
FROM customer;

##2. Películas con duración mayor a 120 minutos
##Tablas usadas: film
##Se filtra con WHERE sobre la columna length (duración en minutos)
SELECT
    title       AS Titulo,
    length      AS Duracion_minutos
FROM film
WHERE length > 120;

##PARTE 2 – ORDER BY

##1. Ordenar clientes por apellido (A → Z)
##Tablas usadas: customer
##ORDER BY last_name ASC ordena alfabéticamente de forma ascendente
SELECT
    first_name  AS Nombre,
    last_name   AS Apellido
FROM customer
ORDER BY last_name ASC;

##2. Top 5 películas más largas
##Tablas usadas: film
##ORDER BY length DESC trae primero las más largas; LIMIT 5 restringe a 5 filas
SELECT
    title       AS Titulo,
    length      AS Duracion_minutos
FROM film
ORDER BY length DESC
LIMIT 5;

##PARTE 3 – INNER JOIN

##1. Cantidad pagada y fecha del pago con nombre y apellido del cliente
##Tablas usadas: payment (p) JOIN customer (c)
##La llave de unión es customer_id presente en ambas tablas
SELECT
    c.first_name    AS Nombre,
    c.last_name     AS Apellido,
    p.amount        AS Monto_pagado,
    p.payment_date  AS Fecha_pago
FROM payment p
INNER JOIN customer c ON p.customer_id = c.customer_id;

-- 2. Películas alquiladas
--    Tablas usadas: rental (r) → inventory (i) → film (f)
--    rental.inventory_id une con inventory.inventory_id
--    inventory.film_id une con film.film_id
SELECT
    f.title         AS Titulo_pelicula,
    r.rental_date   AS Fecha_alquiler,
    r.return_date   AS Fecha_devolucion
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f      ON i.film_id       = f.film_id;

##PARTE 4 – LEFT JOIN

##1. Clientes sin pagos
## Tablas usadas: customer LEFT JOIN payment
##El LEFT JOIN conserva todos los clientes; el WHERE filtra
##únicamente aquellos cuyo customer_id NO aparece en payment
SELECT
    c.first_name    AS Nombre,
    c.last_name     AS Apellido
FROM customer c
LEFT JOIN payment p ON c.customer_id = p.customer_id
WHERE p.customer_id IS NULL;

##2. Películas sin actores (título y duración)
##Tablas usadas: film (f) LEFT JOIN film_actor (fa)
##film_actor es la tabla intermedia entre film y actor
##El LEFT JOIN conserva todas las películas; el WHERE filtra
##las que no tienen ningún actor asociado (actor_id IS NULL)
SELECT
    f.title     AS Titulo_pelicula,
    f.length    AS Duracion_minutos
FROM film f
LEFT JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id IS NULL;

##PARTE 5 – INSERT, UPDATE, DELETE (DML)

##1. Insertar actor temporal
##Se agrega un actor de prueba con nombre 'DAV' y apellido 'CHAR'
INSERT INTO actor (first_name, last_name)
VALUES ('DAV', 'CHAR');

##Verificar el actor insertado (se puede revisar el ID generado)
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'DAV' AND last_name = 'CHAR';

##2. Actualizar actor
##Se actualiza el registro del actor temporal recién insertado.
##Se usa LAST_INSERT_ID() para referenciar el ID generado automáticamente,
##lo que evita modificar actores existentes.
UPDATE actor
SET
    first_name = 'DAVID',
    last_name  = 'CHARRIS'
WHERE actor_id = LAST_INSERT_ID();

##Verificar la actualización
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id = LAST_INSERT_ID();

##3. Eliminar actor
##Se elimina únicamente el actor temporal usando su actor_id
DELETE FROM actor
WHERE actor_id = LAST_INSERT_ID();

##Verificar que fue eliminado (debe retornar 0 filas)
SELECT actor_id, first_name, last_name
FROM actor
WHERE actor_id = LAST_INSERT_ID();

##PARTE 6 – Consultas Avanzadas

##1. Top 5 clientes con mayor dinero pagado
##Tablas usadas: payment JOIN customer
##SUM(p.amount) acumula el total pagado por cada customer_id
##GROUP BY agrupa por cliente, ORDER BY total DESC trae los mayores primero
##LIMIT 5 restringe al top 5
SELECT
    c.first_name                AS Nombre,
    c.last_name                 AS Apellido,
    SUM(p.amount)               AS Total_pagado
FROM payment p
INNER JOIN customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id, c.first_name, c.last_name
ORDER BY Total_pagado DESC
LIMIT 5;

##2. Top 5 películas más alquiladas
## Tablas usadas: rental, inventory, film (f)
## COUNT(r.rental_id) cuenta cuántas veces se alquiló cada película
## GROUP BY agrupa por película, ORDER BY total DESC muestra las más alquiladas
## LIMIT 5 restringe al top 5
SELECT
    f.title             AS Titulo_pelicula,
    COUNT(r.rental_id)  AS Total_alquileres
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f      ON i.film_id       = f.film_id
GROUP BY f.film_id, f.title
ORDER BY Total_alquileres DESC
LIMIT 5;