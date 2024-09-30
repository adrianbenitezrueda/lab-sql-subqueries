-- Challenge 1: Write SQL queries to perform the following tasks using the Sakila database:
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(*) AS number_of_copies
FROM sakila.inventory AS sinv
JOIN sakila.film AS sfi ON sinv.film_id = sfi.film_id
WHERE sfi.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT sfi.title, sfi.length
FROM sakila.film AS sfi
WHERE length > (SELECT AVG(length) FROM sakila.film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT sac.first_name, sac.last_name
FROM sakila.actor AS sac
WHERE sac.actor_id IN (
    SELECT sfa.actor_id
    FROM film_actor AS sfa
    WHERE film_id = (SELECT sfi.film_id FROM sakila.film AS sfi WHERE sfi.title = 'Alone Trip')
);


-- Bonus:
-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT sfi.title
FROM sakila.film AS sfi
JOIN film_category AS sfc ON sfi.film_id = sfc.film_id
JOIN category AS sca ON sfc.category_id = sca.category_id
WHERE sca.name = 'Family';

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins.
-- To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT scu.first_name, scu.last_name, scu.email
FROM sakila.customer AS scu
JOIN sakila.address AS sad ON scu.address_id = sad.address_id
JOIN sakila.city AS sci ON sad.city_id = sci.city_id
JOIN sakila.country AS sco ON sci.country_id = sco.country_id
WHERE sco.country = 'Canada';


-- 6. Determine which films were starred by the most prolific actor in the Sakila database.
-- A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
--  Find most prolific actor
SELECT sfa.actor_id, sac.first_name, sac.last_name, COUNT(film_id) AS film_count
FROM sakila.film_actor AS sfa
JOIN sakila.actor AS sac ON sfa.actor_id = sac.actor_id
GROUP BY actor_id
ORDER BY film_count DESC
LIMIT 1;

SELECT sfi.title
FROM sakila.film AS sfi
JOIN sakila.film_actor AS sfa ON sfi.film_id = sfa.film_id
WHERE sfa.actor_id = (
    SELECT sfa.actor_id
    FROM sakila.film_actor AS sfa
    GROUP BY actor_id
    ORDER BY COUNT(film_id) DESC
    LIMIT 1
);


-- 7. Find the films rented by the most profitable customer in the Sakila database.
-- You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
SELECT sfi.title
FROM sakila.film AS sfi
JOIN sakila.inventory AS sinv ON sfi.film_id = sinv.film_id
JOIN sakila.rental AS sre ON sinv.inventory_id = sre.inventory_id
JOIN sakila.payment AS spa ON sre.rental_id = spa.rental_id
JOIN sakila.customer AS scu ON spa.customer_id = scu.customer_id
WHERE scu.customer_id = (
    SELECT spa.customer_id
    FROM sakila.payment AS spa
    GROUP BY spa.customer_id
    ORDER BY SUM(spa.amount) DESC
    LIMIT 1
);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
-- You can use subqueries to accomplish this.
SELECT spa.customer_id, SUM(spa.amount) AS total_amount_spent
FROM sakila.payment AS spa
GROUP BY spa.customer_id
HAVING total_amount_spent > (
    SELECT AVG(subquery_avg.total_spent) 
    FROM (
        SELECT SUM(spa.amount) AS total_spent
        FROM sakila.payment AS spa
        GROUP BY spa.customer_id
    ) AS subquery_avg
);
