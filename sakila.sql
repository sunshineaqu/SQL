-- * 1a. Display the first and last names of all actors from the table `actor`.
USE sakila;

SELECT first_name, last_name
FROM actor;

-- * 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(upper(first_name), ' ', upper(last_name)) as 'Actor Name'
FROM actor;

-- * 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- * 2b. Find all actors whose last name contain the letters `GEN`:
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- * 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- * 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN  ('Afghanistan', 'Bangladesh', 'China');

-- * 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB NULL AFTER last_update;

-- * 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
DROP COLUMN description;

-- * 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, count(*)
FROM actor
GROUP BY last_name;

-- * 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, count(*)
FROM actor
GROUP BY last_name
HAVING count(*) > 1;

-- * 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.
SELECT *
FROM actor
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

SHOW VARIABLES LIKE 'sql_safe_updates';
SET SQL_SAFE_UPDATES = 0;

UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- * 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO' and last_name = 'WILLIAMS';

SET SQL_SAFE_UPDATES = 1;

-- * 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

CREATE TABLE `address` IF NOT EXISTS (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- * 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
-- USING is a handy way when the columns to join on have the same name
SELECT first_name, last_name, address, address2, district
FROM staff
LEFT JOIN address USING (address_id);

-- * 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT first_name, last_name, SUM(amount) AS 'Total Amount'
FROM staff
LEFT JOIN payment USING(staff_id)
WHERE payment_date LIKE '2005-08%'
GROUP BY staff_id;

-- * 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT title, count(actor_id)
FROM film
INNER JOIN film_actor USING (film_id)
GROUP BY film_id;

-- another way: use 'ON' instead of USING'
SELECT title, count(actor_id)
FROM film
INNER JOIN film_actor ON film.film_id=film_actor.film_id
GROUP BY film.film_id;

-- * 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT count(*)
FROM inventory
WHERE film_id in
(
 SELECT film_id
 FROM film
 WHERE lower(title) = 'hunchback impossible'
 );
  
-- * 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'Total Amount Paid'
FROM customer AS c
INNER JOIN payment AS p USING (customer_id)
GROUP BY c.customer_id;

-- * 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title
FROM film
WHERE title LIKE 'K%' OR title LIKE'Q%'
	AND language_id in
   (
	SELECT language_id
    FROM language
    WHERE name = 'English'
    );

-- * 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
 SELECT actor_id
 FROM film_actor
 WHERE film_id IN
 (
  SELECT film_id
  FROM film
  WHERE lower(title) = lower('Alone Trip')
  )
);

-- * 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name, last_name, email, country
FROM	customer
		INNER JOIN address USING (address_id)
        INNER JOIN city USING (city_id)
        INNER JOIN country USING (country_id)
WHERE country = 'Canada';

-- * 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN
(
 SELECT film_id
 FROM film_category
 WHERE category_id IN
 (
  SELECT category_id
  FROM category
  WHERE name = 'Family'
  )
);

-- * 7e. Display the most frequently rented movies in descending order.
SELECT title, count(rental_id) AS 'Total Rented Times'
FROM	film
		INNER JOIN inventory USING (film_id)
        INNER JOIN rental USING	(inventory_id)
GROUP BY film_id
ORDER BY count(rental_id) DESC;

-- * 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount)
FROM payment
INNER JOIN staff USING (staff_id)
GROUP BY store_id;

-- * 7g. Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country
FROM	store
		INNER JOIN address USING (address_id)
        INNER JOIN city USING (city_id)
        INNER JOIN country USING (country_id);
	
-- * 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT name, SUM(amount)
FROM	category
		INNER JOIN film_category USING (category_id)
        INNER JOIN inventory USING (film_id)
        INNER JOIN rental USING (inventory_id)
        INNER JOIN payment USING (rental_id)
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 0,5;

-- * 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_genres as
SELECT name, SUM(amount)
FROM	category
		INNER JOIN film_category USING (category_id)
        INNER JOIN inventory USING (film_id)
        INNER JOIN rental USING (inventory_id)
        INNER JOIN payment USING (rental_id)
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 0,5;

-- * 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- * 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW top_five_genres;

