/*Task 1. Create a view
Create a view called 'sales_revenue_by_category_qtr' that shows the film category and total sales revenue for the current quarter. 
The view should only display categories with at least one sale in the current quarter. The current quarter should be determined dynamically.
*/

/*In the view, I used inner joins to get the film category and total revenue for each category in current quarter. 
 * I used DATE_TRUNC in the WHERE clause to include the quarter along with the year*/

SET search_path TO public;

CREATE OR REPLACE VIEW sales_revenue_by_category_qtr AS
SELECT 	c.name, 
		SUM(p.amount) AS total_sales_revenue
FROM category c
INNER JOIN film_category fc ON c.category_id=fc.category_id 
INNER JOIN film f ON fc.film_id=f.film_id 
INNER JOIN inventory i ON f.film_id=i.film_id 
INNER JOIN rental r ON i.inventory_id=r.inventory_id 
INNER JOIN payment p ON r.rental_id=p.rental_id
WHERE DATE_TRUNC('QUARTER', p.payment_date) = DATE_TRUNC('QUARTER', now())
GROUP BY c.name
HAVING COUNT(p.payment_id)>=1;

/*Task 2. Create a query language functions
Create a query language function called 'get_sales_revenue_by_category_qtr' that accepts one parameter representing the current quarter 
and returns the same result as the 'sales_revenue_by_category_qtr' view.
*/

/*The function takes one IN parameter of type timestamptz, which defaults to the current quarter. 
 * This parameter is used in the WHERE clause in the SELECT statement. 
 * Like the view, the function returns a table with a category and total revenue column*/

CREATE OR REPLACE FUNCTION get_sales_revenue_by_category_qtr (IN current_quarter timestamptz DEFAULT DATE_TRUNC('QUARTER', now()))
RETURNS TABLE (category_name TEXT,
				revenue_by_category NUMERIC)
AS $$

SELECT 	c.name, 
		SUM(p.amount) AS total_sales_revenue
FROM category c
INNER JOIN film_category fc ON c.category_id=fc.category_id 
INNER JOIN film f ON fc.film_id=f.film_id 
INNER JOIN inventory i ON f.film_id=i.film_id 
INNER JOIN rental r ON i.inventory_id=r.inventory_id 
INNER JOIN payment p ON r.rental_id=p.rental_id
WHERE DATE_TRUNC('QUARTER', p.payment_date)=DATE_TRUNC('QUARTER', current_quarter)
GROUP BY c.name

$$
LANGUAGE SQL;


/*Task 3. Create procedure language functions
Create a function that takes a country as an input parameter and returns the most popular film in that specific country. 
The function should format the result set as follows:
Query (example):select * from core.most_popular_films_by_countries(array['Afghanistan','Brazil','United States’]);
*/

/*The function takes an array with the names of countries as a parameter. This function uses a loop that 
 * returns the record with the most popular movie (the movie with the most rentals) for each given country. 
 * I used RAISE NOTICE, so if there were no rentals in the given country, the function returns this information.*/

CREATE OR REPLACE FUNCTION most_popular_films_by_countries (specified_country TEXT[])
RETURNS TABLE (country TEXT, film TEXT, rating TEXT, "language" TEXT, "length" INT, release_year INT)
LANGUAGE plpgsql

AS $$
DECLARE 
		var_country_name TEXT;
BEGIN
	FOREACH var_country_name IN ARRAY specified_country
	LOOP
	SELECT 	most_popular_film.country,
			most_popular_film.title,
			most_popular_film.rating,
			most_popular_film."name",
			most_popular_film."length",
			most_popular_film.release_year 
	INTO    country,
            film,
            rating,
            "language",
            "length",
            release_year
	FROM (
		SELECT 	cn.country, 
				f.title, 
				f.rating, 
				l.name, 
				f.length, 
				f.release_year, 
				SUM(p.amount),
				COUNT(r.rental_id)
		FROM film f
		INNER JOIN "language" l ON f.language_id = l.language_id 
		INNER JOIN inventory i ON f.film_id = i.film_id 
		INNER JOIN rental r ON i.inventory_id = r.inventory_id 
		INNER JOIN payment p ON r.rental_id = p.rental_id 
		INNER JOIN customer c ON p.customer_id = c.customer_id
		INNER JOIN address a ON c.address_id = a.address_id 
		INNER JOIN city ct ON a.city_id = ct.city_id 
		INNER JOIN country cn ON ct.country_id = cn.country_id 
		WHERE UPPER(cn.country) = UPPER(var_country_name)
		GROUP BY cn.country, f.title, f.rating, l.name, f.length, f.release_year
		ORDER BY COUNT(r.rental_id) DESC, SUM(p.amount) DESC
		LIMIT 1) AS most_popular_film;
	RETURN NEXT;
        IF NOT FOUND THEN
            RAISE EXCEPTION 'No data found for country: %', var_country_name;
        END IF;
	END LOOP;
END;
$$;


--select * from most_popular_films_by_countries(array['Afghanistan','Brazil','United States'])



/*Task 4. Create procedure language functions

Create a function that generates a list of movies available in stock based on a partial title match (e.g., movies containing 
the word 'love' in their title). 
The titles of these movies are formatted as '%...%', and if a movie with the specified title is not in stock, return a message 
indicating that it was not found.
The function should produce the result set in the following format (note: the 'row_num' field is an automatically generated counter 
field, starting from 1 and incrementing for each entry, e.g., 1, 2, ..., 100, 101, ...).

                    Query (example):select * from core.films_in_stock_by_title('%love%’);*/

/*The function takes as an argument a parameter of type TEXT, which is a fragment of the movie title. 
 * The function returns a table with all available in stock movies containing this title. I treated as 
 * in stock films all copies that were never rented (there's no inventory_id in rental table) or were 
 * rented and returned (return_date IS NOT NULL). For each copy of the movie, the function returns the 
 * record associated with the last rental. I also used RAISE NOTICE in this function to get the 
 * appropriate information in case of missing title with partial_title provided*/

CREATE OR REPLACE FUNCTION films_in_stock_by_title (partial_title TEXT)
RETURNS TABLE (
    row_num BIGINT,
    title TEXT,
    "language" CHAR(20),
    customer_name TEXT,
    rental_date TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$

BEGIN
RETURN QUERY
WITH films_in_stock AS(
SELECT  f.title, 
		i.inventory_id,
		r.inventory_id,
		r.return_date, 
		r.rental_date, 
		l.name AS "language", 
		c.first_name || ' ' || c.last_name AS customer_name
FROM film f 
INNER JOIN "language" l ON f.language_id = l.language_id 
INNER JOIN inventory i ON f.film_id = i.film_id 
LEFT JOIN rental r ON i.inventory_id = r.inventory_id 
LEFT JOIN customer c ON r.customer_id = c.customer_id 
WHERE r.inventory_id IS NULL OR r.return_date IS NOT NULL AND r.rental_date =(SELECT MAX(r.rental_date)
																				FROM rental r
																				WHERE r.inventory_id = i.inventory_id)
ORDER BY i.inventory_id, r.rental_date DESC
)
SELECT 	ROW_NUMBER() OVER() AS row_num, 
		films_in_stock.title, 
		films_in_stock."language", 
		films_in_stock.customer_name, 
		films_in_stock.rental_date
FROM films_in_stock
WHERE UPPER(films_in_stock.title) LIKE UPPER(partial_title);
        IF NOT FOUND THEN
            RAISE NOTICE 'No films found containing in title: %', partial_title;
        END IF;

END;
$$;

--select * from films_in_stock_by_title('%love%')


/*Task 5. Create procedure language functions

Create a procedure language function called 'new_movie' that takes a movie title as a parameter and 
inserts a new movie with the given title in the film table. The function should generate a new unique 
film ID, set the rental rate to 4.99, the rental duration to three days, the replacement cost to 19.99. 
The release year and language are optional and by default should be current year and Klingon respectively. 
The function should also verify that the language exists in the 'language' table. Then, ensure that no 
such function has been created before; if so, replace it.*/

/* The function has one parameter: movie title which is title of movie to be inserted.
 * First, the function checks if Klingon language already exists in language table if not, it insert it 
 * and returns language_id into variable. Next, it inserts new movie into film table. Function also checks 
 * if such film already exists, not to duplicate it. */

CREATE OR REPLACE FUNCTION new_movie (movie_title text)
RETURNS TABLE (
    nfilm_id bigint,
    ntitle TEXT,
    nrelease_year YEAR,
    nlanguage_id int,
    nrental_duration int2,
    nrental_rate numeric(4,2),
    nreplacement_cost numeric(5,2)
)
LANGUAGE plpgsql
AS $$
 DECLARE var_language_id INT;
BEGIN
	
	IF EXISTS (SELECT title FROM film WHERE UPPER(title) = UPPER(movie_title)) THEN
    RAISE NOTICE 'Movie % already exists in the database.', movie_title;
    END IF;
	
    SELECT l.language_id
    INTO var_language_id
    FROM language l
    WHERE UPPER(name) = 'KLINGON';

    IF var_language_id IS NULL THEN
        INSERT INTO language (name)
        SELECT ('Klingon')
       RETURNING language_id INTO var_language_id;
    END IF;
	
INSERT INTO film(title, release_year, language_id, rental_duration, rental_rate, replacement_cost)
SELECT 	title, 
		release_year, 
		language_id, 
		rental_duration, 
		rental_rate, 
		replacement_cost
FROM(VALUES (movie_title, (SELECT 	EXTRACT(YEAR FROM NOW())), 
									var_language_id,
									3, 
									4.99, 
									19.99)) AS inserted_movie (title, release_year, language_id, rental_duration, rental_rate, replacement_cost)
WHERE NOT EXISTS (	SELECT film_id 
					FROM film f
					WHERE f.title = inserted_movie.title)
RETURNING * INTO     
	nfilm_id,
    ntitle,
    nrelease_year,
    nlanguage_id,
    nrental_duration,
    nrental_rate,
    nreplacement_cost;
RETURN NEXT;
			
END;
$$;
