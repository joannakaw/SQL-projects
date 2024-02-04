--creating db, this script should be run separately at the beginning, then new database connection should be establish

--DROP DATABASE IF EXISTS household_appliances_store;
--CREATE DATABASE household_appliances_store;

--creating schema and setting search_path to this schema
CREATE SCHEMA IF NOT EXISTS store;
SET search_path TO store;

--creating all tables in database, each table has a primary key, all relationship are established with foreign key and references
CREATE TABLE IF NOT EXISTS customer (
	customer_id serial4 NOT NULL,
	first_name varchar(50) NOT NULL,
	last_name varchar(50) NOT NULL,
	email varchar (50) NOT NULL,
	phone_number varchar(50)NOT NULL UNIQUE,
	CONSTRAINT PK_customer PRIMARY KEY (customer_id)
);

CREATE TABLE IF NOT EXISTS employee (
	employee_id serial4 NOT NULL,
	first_name varchar(50) NOT NULL,
	last_name varchar(50) NOT NULL,
	position_name varchar(50),
	email varchar (50) NOT NULL,
	phone_number varchar (50),
	CONSTRAINT PK_employee PRIMARY KEY (employee_id)
);

CREATE TABLE IF NOT EXISTS city (
	city_id serial4 NOT NULL,
	city_name varchar(50) NOT NULL,
	CONSTRAINT PK_city PRIMARY KEY (city_id)
);

CREATE TABLE IF NOT EXISTS zipcode (
	zipcode_id serial4 NOT NULL,
	zipcode varchar(10) NOT NULL,
	city_id int,
	CONSTRAINT PK_zipcode PRIMARY KEY (zipcode_id),
	CONSTRAINT FK_city_id FOREIGN KEY (city_id) REFERENCES city(city_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS address (
	address_id serial4 NOT NULL,
	street varchar(50) NOT NULL,
	zipcode_id int NOT NULL,
	CONSTRAINT PK_address PRIMARY KEY (address_id),
	CONSTRAINT FK_zipcode_id FOREIGN KEY (zipcode_id) REFERENCES zipcode(zipcode_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS supplier (
	supplier_id serial4 NOT NULL,
	supplier_name varchar(50) NOT NULL,
	email varchar (50),
	phone_number varchar (50),
	CONSTRAINT PK_supplier PRIMARY KEY (supplier_id)
);

CREATE TABLE IF NOT EXISTS category (
	category_id serial4 NOT NULL,
	category_name varchar(50) NOT NULL,
	CONSTRAINT PK_category PRIMARY KEY (category_id)
);


CREATE TABLE IF NOT EXISTS "order" (
	order_id serial4 NOT NULL,
	order_code varchar(10) NOT NULL UNIQUE,
	customer_id int NOT NULL,
	employee_id int NOT NULL,
	status varchar(20),
	order_date timestamptz NOT NULL,
	delivery_date timestamptz,
	address_id int NOT NULL,
	last_updated timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT PK_order PRIMARY KEY (order_id),
	CONSTRAINT FK_customer_id FOREIGN KEY (customer_id) REFERENCES customer(customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT FK_employee_id FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT FK_address_id FOREIGN KEY (address_id) REFERENCES address(address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS payment (
	payment_id serial4 NOT NULL,
	payment_method varchar(50) NOT NULL,
	amount numeric(8,2) NOT NULL,
	payment_date timestamptz,
	order_id int NOT NULL,
	last_updated timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT PK_payment PRIMARY KEY (payment_id),
	CONSTRAINT FK_order_id FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS product (
	product_id serial4 NOT NULL,
	product_name varchar(20),
	brand varchar(20),
	model varchar(20),
	category_id int NOT NULL,
	sell_price_net numeric(6,2) NOT NULL,
	sell_price_gross numeric(6,2) NOT NULL GENERATED ALWAYS AS (sell_price_net *1.23) STORED,
	stock_quantity int NOT NULL,
	last_updated timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT PK_product PRIMARY KEY (product_id),
	CONSTRAINT FK_category_id FOREIGN KEY (category_id) REFERENCES category(category_id) ON DELETE RESTRICT ON UPDATE CASCADE	
);

CREATE TABLE IF NOT EXISTS product_supplier (
	product_supplier_id serial4 NOT NULL,
	supplier_id int NOT NULL,
	product_id int NOT NULL,
	buy_price numeric(6,2) NOT NULL,
	quantity int NOT NULL,
	supply_date timestamptz NOT NULL,
	last_updated timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT PK_product_supplier PRIMARY KEY (product_supplier_id),
	CONSTRAINT FK_product_id FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE	
);

CREATE TABLE IF NOT EXISTS order_detail (
	order_detail_id serial4 NOT NULL,
	order_id int NOT NULL,
	product_id int NOT NULL,
	quantity int NOT NULL,
	discount_percentage int,
	last_updated timestamptz NOT NULL DEFAULT now(),
	CONSTRAINT PK_order_detail PRIMARY KEY (order_detail_id),
	CONSTRAINT FK_product_id FOREIGN KEY (product_id) REFERENCES product(product_id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT FK_order_id FOREIGN KEY (order_id) REFERENCES "order"(order_id) ON DELETE RESTRICT ON UPDATE CASCADE	
);


-- additional constraints from the task requirements
/*Use ALTER TABLE to add seven check constraints across the tables to restrict certain values, as example 
date to be inserted, which must be greater than October 20, 2023
inserted measured value that cannot be negative
inserted value that can only be a specific value
unique
not null
Give meaningful names to your CHECK constraints. 
Use appropriate data types for each column and apply DEFAULT, STORED AS and GENERATED ALWAYS AS columns as required.
*/

ALTER TABLE product
DROP CONSTRAINT IF EXISTS product_sell_price_check;
ALTER TABLE product 
ADD CONSTRAINT product_sell_price_check CHECK (sell_price_net > 0);

ALTER TABLE product_supplier
DROP CONSTRAINT IF EXISTS product_supplier_buy_price_check;
ALTER TABLE product_supplier
ADD CONSTRAINT product_supplier_buy_price_check CHECK (buy_price > 0);

ALTER TABLE payment
DROP CONSTRAINT IF EXISTS payment_method_check;
ALTER TABLE payment
ADD CONSTRAINT payment_method_check CHECK (payment_method IN ('bank transfer', 'cash', 'card'));

ALTER TABLE "order"
DROP CONSTRAINT IF EXISTS order_status_check;
ALTER TABLE "order"
ADD CONSTRAINT order_status_check CHECK (status IN ('pending', 'shipped', 'delivered'));

ALTER TABLE "order"
ALTER COLUMN status DROP DEFAULT;
ALTER TABLE "order"
ALTER COLUMN status SET DEFAULT 'pending';

ALTER TABLE employee
DROP CONSTRAINT IF EXISTS employee_position_name_check;
ALTER TABLE employee
ADD CONSTRAINT employee_position_name_check CHECK (position_name IN ('manager', 'senior_assistant', 'assistant'));

ALTER TABLE employee
ALTER COLUMN position_name DROP DEFAULT;
ALTER TABLE employee
ALTER COLUMN position_name SET DEFAULT 'assistant';

ALTER TABLE customer
DROP CONSTRAINT IF EXISTS customer_email_unique;
ALTER TABLE customer
ADD CONSTRAINT customer_email_unique UNIQUE (email);

ALTER TABLE customer
DROP CONSTRAINT IF EXISTS customer_email_check;
ALTER TABLE customer
ADD CONSTRAINT customer_email_check CHECK (email LIKE '%@%.%');

ALTER TABLE employee
DROP CONSTRAINT IF EXISTS employee_email_unique;
ALTER TABLE employee
ADD CONSTRAINT employee_email_unique UNIQUE (email);

ALTER TABLE employee
DROP CONSTRAINT IF EXISTS employee_email_check;
ALTER TABLE employee
ADD CONSTRAINT employee_email_check CHECK (email LIKE '%@%.%');

ALTER TABLE product
ALTER COLUMN product_name DROP NOT NULL;
ALTER TABLE product 
ALTER COLUMN product_name SET NOT NULL;

ALTER TABLE "order"
DROP CONSTRAINT IF EXISTS order_dates_check;
ALTER TABLE "order"
ADD CONSTRAINT order_dates_check CHECK (order_date < delivery_date);

ALTER TABLE payment
DROP CONSTRAINT IF EXISTS payment_date_check;
ALTER TABLE payment
ADD CONSTRAINT payment_date_check CHECK (payment_date > '2023-10-23'::timestamptz);

/*Populate the tables with the sample data generated, ensuring each table has at least 7+ rows (for a total of 70+ rows in all the tables) for the last 3 months.
Create DML scripts for insert your data. 
Ensure that the DML scripts do not include values for surrogate keys, as these keys should be generated by the database during runtime. 
Also, ensure that any DEFAULT values required are specified appropriately in the DML scripts. 
These DML scripts should be designed to successfully adhere to all previously defined constraints
*/
--Script for populating tables

INSERT INTO customer (first_name, last_name, email, phone_number)
SELECT 	first_name, 
		last_name, 
		email,
		phone_number
FROM (VALUES ('Jan', 'Kowalski', 'jan.kowalski@gmail.com', '(+48)222333444'), 				
			('Maria', 'Kowalska','mkowalska@gmail.com',  '(+48)22345677'), 
			('John', 'Smith','jsmith@gmail.com', '(52)11111111444'), 
			('Anna', 'Nowak', 'anowak123@gmail.com', '608-608-608'), 
			('Jon', 'Snow','jonsnow@gmail.com', '(52)123-123-123'), 
			('Ned', 'Stark', 'ned.stark@gmail.com', '608-608-666'), 
			('Adam', 'Nowacki', 'adam.nowacki@gmail.com',  '(+48)313313312')) AS customers (first_name, last_name, email, phone_number)
WHERE NOT EXISTS (SELECT c.customer_id 
					FROM customer c
					WHERE c.email=customers.email)
RETURNING *;


INSERT INTO employee (first_name, last_name, email, phone_number)
SELECT 	first_name, 
		last_name, 
		email,
		phone_number
FROM (VALUES ('Jacek', 'Jackowski', 'jjack@gmail.com', '(+48)123-456-789'), 				
			('Fox', 'Mulder','f.mulder@gmail.com',  '(+48)1313-1313-13'), 
			('Amy', 'Green','amy.g@gmail.com', '(52)22-33-44-55'), 
			('Julia', 'Nowak', 'julia.nowak@gmail.com', '608-690-608'), 
			('Rachel', 'Green','rachel.green@gmail.com', '(52)156-123-123'), 
			('Bruce', 'Wayne', 'bw@gmail.com', '608-111-666'), 
			('Jan', 'Jankowski', 'jan.jankowski@gmail.com',  '(+48)999-000-99')) AS employees (first_name, last_name, email, phone_number)
WHERE NOT EXISTS (SELECT e.employee_id 
					FROM employee e
					WHERE e.email=employees.email)
RETURNING *;


INSERT INTO city (city_name)
SELECT city_name
FROM (VALUES ('Warszawa'), ('Gdansk'), ('Gdynia'), ('Sopot'), ('Poznan'), ('Krakow'), ('Wroclaw')) AS cities (city_name)
WHERE NOT EXISTS (SELECT c.city_id
					FROM city c
					WHERE UPPER(c.city_name)=UPPER(cities.city_name))
RETURNING *;


INSERT INTO zipcode (zipcode, city_id)
SELECT zipcode, city_id
FROM (VALUES	('80-888', (SELECT city_id 
							FROM city 
							WHERE UPPER(city_name)='GDANSK')),
				('82-834', (SELECT city_id 
							FROM city 
							WHERE UPPER(city_name)='GDYNIA')),
				('82-123', (SELECT city_id 
							FROM city 
							WHERE UPPER(city_name)='GDANSK')),
				('80-100', (SELECT city_id 
							FROM city 
							WHERE UPPER(city_name)='SOPOT')),
				('00-123', (SELECT city_id 
							FROM city 
							WHERE UPPER(city_name)='WARSZAWA')),
				('00-100', (SELECT city_id 
							FROM city 
							WHERE UPPER(city_name)='WARSZAWA')),
				('00-220', (SELECT city_id 
							FROM city 
							WHERE UPPER(city_name)='WARSZAWA'))) AS zipcodes (zipcode, city_id)
WHERE NOT EXISTS (SELECT z.zipcode_id
					FROM zipcode z
					WHERE z.zipcode=zipcodes.zipcode)
RETURNING *;


INSERT INTO address (street, zipcode_id)
SELECT street, zipcode_id
FROM (VALUES	('Warszawska 20', (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='80-888')),
				('Zielona 13/2', (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='80-888')),
				('Grunwaldzka 10/3', (SELECT zipcode_id 
										FROM zipcode 
										WHERE zipcode='82-834')),
				('Kwiatowa 15/1', (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='80-100')),
				('Kopernika 18', (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='00-100')),
				('Kopernika 3/2', (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='00-100')),
				('Abrahama 132', (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='00-123'))) AS addresses (street, zipcode_id)
WHERE NOT EXISTS (SELECT a.address_id
					FROM address a
					WHERE UPPER(a.street)=UPPER(addresses.street) AND
					a.zipcode_id=addresses.zipcode_id)
RETURNING *;


INSERT INTO supplier (supplier_name, email, phone_number)
SELECT 	supplier_name,  
		email,
		phone_number
FROM (VALUES ('Supplier A', 'supA@gmail.com', '(+48)123-456-790'), 				
			('Supplier B', 'supB@gmail.com',  '(+48)123-131-13'), 
			('Supplier C', 'supC@gmail.com', '(52)55-33-44-55'), 
			('Supplier D', 'supD@gmail.com', '655-690-608'), 
			('Supplier E', 'supE@gmail.com', '(52)555-123-123'), 
			('Supplier F', 'supF@gmail.com', '608-111-555'), 
			('Supplier G', 'supG@gmail.com',  '(+48)999-555-99')) AS suppliers (supplier_name, email, phone_number)
WHERE NOT EXISTS (SELECT s.supplier_id 
					FROM supplier s
					WHERE s.supplier_name=suppliers.supplier_name)
RETURNING *;


INSERT INTO category (category_name)
SELECT category_name
FROM (VALUES ('washing machine'), ('dryer'), ('refrigerator'), ('stove'), ('microvawe'), ('dishwasher'), ('TV'), ('vacuum'), ('oven')) AS categories (category_name)
WHERE NOT EXISTS (SELECT c.category_id
					FROM category c
					WHERE UPPER(c.category_name)=UPPER(categories.category_name))
RETURNING *;


INSERT INTO "order" (order_code, customer_id, employee_id, order_date, address_id)
SELECT 	order_code,
		customer_id, 
		employee_id, 
		order_date, 
		address_id
FROM (VALUES 	('0001AB',(SELECT customer_id 
							FROM customer 
							WHERE LOWER(email) = 'jsmith@gmail.com'), 
				(SELECT employee_id 
				FROM employee 
				WHERE LOWER(email) = 'bw@gmail.com'), '2023-10-30'::timestamptz, 
				(SELECT address_id 
				FROM address 
				WHERE UPPER(street)= 'WARSZAWSKA 20' 
				AND zipcode_id IN (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='80-888'))),
				('0001BB',(SELECT customer_id 
							FROM customer 
							WHERE LOWER(email) = 'jonsnow@gmail.com'), 
				(SELECT employee_id 
				FROM employee 
				WHERE LOWER(email) = 'rachel.green@gmail.com'), '2023-10-29'::timestamptz, 
				(SELECT address_id 
				FROM address 
				WHERE UPPER(street)= 'ZIELONA 13/2' 
				AND zipcode_id IN (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='80-888'))),
				('0002AB',(SELECT customer_id 
							FROM customer 
							WHERE LOWER(email) = 'anowak123@gmail.com'), 
				(SELECT employee_id 
				FROM employee 
				WHERE LOWER(email) = 'rachel.green@gmail.com'), '2023-11-08'::timestamptz, 
				(SELECT address_id 
				FROM address 
				WHERE UPPER(street)= 'ABRAHAMA 132' 
				AND zipcode_id IN (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='00-123'))),
				('0003AB',(SELECT customer_id 
							FROM customer 
							WHERE LOWER(email) = 'adam.nowacki@gmail.com'), 
				(SELECT employee_id 
				FROM employee 
				WHERE LOWER(email) = 'bw@gmail.com'), '2023-11-20'::timestamptz, 
				(SELECT address_id 
				FROM address 
				WHERE UPPER(street)= 'KOPERNIKA 18' 
				AND zipcode_id IN (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='00-100'))),
				('0001CC',(SELECT customer_id 
							FROM customer 
							WHERE LOWER(email) = 'ned.stark@gmail.com'), 
				(SELECT employee_id 
				FROM employee 
				WHERE LOWER(email) = 'bw@gmail.com'), '2023-11-15'::timestamptz, 
				(SELECT address_id 
				FROM address 
				WHERE UPPER(street)= 'KOPERNIKA 3/2' 
				AND zipcode_id IN (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='00-100'))),
				('0008AB',(SELECT customer_id 
							FROM customer 
							WHERE LOWER(email) = 'mkowalska@gmail.com'), 
				(SELECT employee_id 
				FROM employee 
				WHERE LOWER(email) = 'rachel.green@gmail.com'), '2023-09-30'::timestamptz, 
				(SELECT address_id 
				FROM address 
				WHERE UPPER(street)= 'GRUNWALDZKA 10/3' 
				AND zipcode_id IN (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='82-834'))),
				('0101AC',(SELECT customer_id 
							FROM customer 
							WHERE LOWER(email) = 'jonsnow@gmail.com'), 
				(SELECT employee_id 
				FROM employee 
				WHERE LOWER(email) = 'amy.g@gmail.com'), '2023-10-28'::timestamptz, 
				(SELECT address_id 
				FROM address 
				WHERE UPPER(street)= 'KWIATOWA 15/1' 
				AND zipcode_id IN (SELECT zipcode_id 
									FROM zipcode 
									WHERE zipcode='80-100')))
				)  AS orders (order_code, customer_id, employee_id, order_date, address_id)
WHERE NOT EXISTS (SELECT o.order_id
					FROM "order" o
					WHERE o.order_code=orders.order_code)
RETURNING *;


INSERT INTO payment (payment_method, amount, payment_date, order_id)
SELECT 	payment_method, 
		amount, 
		payment_date, 
		order_id
FROM (VALUES 	('bank transfer', 1000, '2023-11-30'::timestamptz, (SELECT order_id 
																	FROM "order" 
																	WHERE UPPER(order_code)='0001AB')),
				('cash', 999.99, '2023-11-30'::timestamptz, (SELECT order_id 
															FROM "order" 
															WHERE UPPER(order_code)='0008AB')),
				('card', 450.99, '2023-11-30'::timestamptz, (SELECT order_id 
															FROM "order" 
															WHERE UPPER(order_code)='0001BB')),
				('card', 1234, '2023-11-30'::timestamptz, (SELECT order_id 
															FROM "order" 
															WHERE UPPER(order_code)='0003AB')),
				('card', 799.99, '2023-11-30'::timestamptz, (SELECT order_id 
															FROM "order" 
															WHERE UPPER(order_code)='0001CC')),
				('bank transfer', 3299.99, '2023-11-30'::timestamptz, (SELECT order_id 
																		FROM "order" 
																		WHERE UPPER(order_code)='0101AC')),
				('bank transfer', 199.99, '2023-11-30'::timestamptz, (SELECT order_id 
																	FROM "order" 
																	WHERE UPPER(order_code)='0101AC')))AS payments(payment_method, amount, payment_date, order_id)
WHERE NOT EXISTS (SELECT p.payment_id
					FROM payment p
					WHERE p.order_id=payments.order_id AND p.amount=payments.amount)
RETURNING *;


INSERT INTO product (product_name, brand, model, category_id, sell_price_net, stock_quantity)
SELECT 	product_name, 
		brand, 
		model, 
		category_id, 
		sell_price_net, 
		stock_quantity
FROM (VALUES 	('Dryer A500', 'Good Brand', 'X2890', (SELECT category_id 
														FROM category 
														WHERE UPPER(category_name) = 'DRYER'), 999.99, 10),
				('Washing Machine III', 'ABC Home', 'X2890', (SELECT category_id 
																FROM category 
																WHERE UPPER(category_name) = 'WASHING MACHINE'), 699.50, 50),
				('Beko 23', 'Beko', 'S20', (SELECT category_id 
											FROM category 
											WHERE UPPER(category_name) = 'DISHWASHER'), 500.99, 23),
				('Sony X800', 'Sony', 'VA', (SELECT category_id 
											FROM category 
											WHERE UPPER(category_name) = 'TV'), 1299.99, 59),
				('Xiaomi 123', 'Xiaomi', '4', (SELECT category_id 
												FROM category 
												WHERE UPPER(category_name) = 'TV'), 2999.99, 14),
				('Microvawe I', 'Brand C', '5', (SELECT category_id 
												FROM category 
												WHERE UPPER(category_name) = 'MICROVAWE'), 199.99, 40),
				('vacuum cleaner PRO', 'ABC Home', 's12', (SELECT category_id 
															FROM category 
															WHERE UPPER(category_name) = 'VACUUM'), 599.90, 30)) AS products (product_name, brand, model, category_id, sell_price_net, stock_quantity)
WHERE NOT EXISTS (SELECT p.product_id
					FROM product p
					WHERE UPPER(p.product_name)=UPPER(products.product_name) AND UPPER(p.brand)=UPPER(products.brand))
RETURNING *;


INSERT INTO product_supplier (supplier_id, product_id, buy_price, quantity, supply_date)
SELECT 	supplier_id, 
		product_id, 
		buy_price, 
		quantity, 
		supply_date
FROM (VALUES 	((SELECT supplier_id 
				FROM supplier 
				WHERE UPPER(supplier_name)='SUPPLIER A'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='DRYER A500'), 599.99, 10, '2023-10-28'::timestamptz),
				((SELECT supplier_id 
				FROM supplier 
				WHERE UPPER(supplier_name)='SUPPLIER A'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='WASHING MACHINE III'), 399.99, 5, '2023-10-28'::timestamptz),
				((SELECT supplier_id 
				FROM supplier 
				WHERE UPPER(supplier_name)='SUPPLIER B'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='BEKO 23'), 299.99, 9, '2023-10-28'::timestamptz),
				((SELECT supplier_id 
				FROM supplier 
				WHERE UPPER(supplier_name)='SUPPLIER B'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='VACUUM CLEANER PRO'), 199.99, 10, '2023-10-28'::timestamptz),
				((SELECT supplier_id 
				FROM supplier 
				WHERE UPPER(supplier_name)='SUPPLIER C'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='XIAOMI 123'), 1299.99, 5, '2023-10-28'::timestamptz),
				((SELECT supplier_id 
				FROM supplier 
				WHERE UPPER(supplier_name)='SUPPLIER D'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='XIAOMI 123'), 1199.99, 10, '2023-10-28'::timestamptz),
				((SELECT supplier_id 
				FROM supplier 
				WHERE UPPER(supplier_name)='SUPPLIER F'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='DRYER A500'), 499.99, 2, '2023-10-28'::timestamptz)) AS product_suppliers (supplier_id, product_id, buy_price, quantity, supply_date)
RETURNING *;


INSERT INTO order_detail (order_id, product_id, quantity, discount_percentage)
SELECT 	order_id, 
		product_id, 
		quantity, 
		discount_percentage
FROM (VALUES 	((SELECT order_id 
				FROM "order" 
				WHERE UPPER(order_code)='0001AB'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='XIAOMI 123'), 2, 15),
				((SELECT order_id 
				FROM "order" 
				WHERE UPPER(order_code)='0001AB'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='VACUUM CLEANER PRO'), 1, NULL),
				((SELECT order_id 
				FROM "order" 
				WHERE UPPER(order_code)='0001AB'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='MICROVAWE I'), 1, 5),
				((SELECT order_id 
				FROM "order" 
				WHERE UPPER(order_code)='0002AB'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='DRYER A500'), 1, 10),
				((SELECT order_id 
				FROM "order" 
				WHERE UPPER(order_code)='0008AB'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='SONY X800'), 3, 20),
				((SELECT order_id 
				FROM "order" 
				WHERE UPPER(order_code)='0008AB'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='DRYER A500'), 2, 15),
				((SELECT order_id 
				FROM "order" 
				WHERE UPPER(order_code)='0001CC'), 
				(SELECT product_id 
				FROM product 
				WHERE UPPER(product_name)='BEKO 23'), 1, NULL)) AS order_details (order_id, product_id, quantity, discount_percentage)
WHERE NOT EXISTS (SELECT order_detail_id
					FROM order_detail o
					WHERE o.order_id=order_details.order_id AND o.product_id=order_details.product_id)
RETURNING *;

--FUNCTIONS
/*5.1 Create a function that updates data in one of your tables. This function should take the following input arguments:
The primary key value of the row you want to update
The name of the column you want to update
The new value you want to set for the specified column
This function should be designed to modify the specified row in the table, updating the specified column with the new value.
*/

/*function updates specific row in customer table, it takes input parameters: customer_id, column_name and the new_value. 
 * Firstly it checks if given primary_key exists in table, then using dynamic SQL the specific value in choosen column is updated. In customer
 * table all columns have varchar datatype, so there's second option with function updating row in product table to handle some various data type issues.
 * I used conditional statements to update the specified column based on its data type */

CREATE OR REPLACE FUNCTION customer_table_updating (i_customer_id int, column_name varchar(50), new_value varchar(50))
RETURNS TABLE (
	ncustomer_id int,
	nfirst_name varchar(50),
	nlast_name varchar(50),
	nemail varchar(50),
	nphone_number varchar(50)
)
LANGUAGE plpgsql
AS $$

BEGIN
	
	IF NOT EXISTS (SELECT customer_id 
					FROM customer 
					WHERE customer_id = i_customer_id) THEN
    RAISE NOTICE 'Customer with customer_id %  doesn''t exists in the database.', i_customer_id;
   	RETURN;
    END IF;
   
    EXECUTE '
        UPDATE customer 
        SET ' || column_name || ' = $1 
        WHERE customer_id = $2 
        RETURNING *'
    USING new_value, i_customer_id;
    RETURN QUERY
    SELECT *
    FROM customer
    WHERE customer_id = i_customer_id;			
END;
$$;

--SELECT * FROM customer_table_updating(2, 'last_name', 'Black')

--SECOND OPTION
CREATE OR REPLACE FUNCTION product_table_updating(
    p_product_id int,
    p_column_name varchar(50),
    p_new_value varchar(50)
)
RETURNS TABLE (
    nproduct_id int,
    nproduct_name varchar(20),
    nbrand varchar(20),
    nmodel varchar(20),
    ncategory_id int,
    nsell_price_net numeric(6,2),
    nsell_price_gross numeric(6,2),
    nstock_quantity int,
    nlast_updated timestamptz
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS (SELECT product_id 
    				FROM product 
    				WHERE product_id = p_product_id) THEN
        RAISE EXCEPTION 'Product with product_id % does not exist.', p_product_id;
    END IF;

    IF p_column_name IN ('stock_quantity', 'category_id') THEN
        EXECUTE 'UPDATE product SET ' || p_column_name || ' = $1 WHERE product_id = $2'
        USING p_new_value::integer, p_product_id;
    ELSIF p_column_name IN ('sell_price_net', 'sell_price_gross') THEN
        EXECUTE 'UPDATE product SET ' || p_column_name || ' = $1 WHERE product_id = $2'
        USING p_new_value::numeric, p_product_id;
    
	ELSE
	    EXECUTE 'UPDATE product SET ' || p_column_name || ' = $1 WHERE product_id = $2'
        USING p_new_value, p_product_id;
    END IF;

    RETURN QUERY
    SELECT *
    FROM product
    WHERE product_id = p_product_id;
END;
$$;

--SELECT * FROM product_table_updating(2, 'sell_price_net', '700.12')


/*5. 2 Create a function that adds a new transaction to your transaction table. 
You can define the input arguments and output format. 
Make sure all transaction attributes can be set with the function (via their natural keys). 
The function does not need to return a value but should confirm the successful insertion of the new transaction.
*/

/*The function inserts new record to order_detail table. As input parameter it takes code of order, name of product, ordered quantity
 * and eventually discount. Function checks if there's id for given product and order, if not it raises notice. In other way
 * it saves product_id and order_id into variables and then inserting new order details into order_detail table. Function also chceks 
 * if ordered quantity is available in stock.*/

CREATE OR REPLACE FUNCTION new_order_details (code_of_order varchar(50), ordered_product varchar(50), ordered_quantity int, discount int)
RETURNS TABLE (
    norderdetail_id int,
    norder_id int,
    nproduct_id int,
    nquantity int,
    ndiscount_percentage int
)
LANGUAGE plpgsql
AS $$
 DECLARE var_product_id INT;
 DECLARE var_order_id INT;
BEGIN
	
	IF NOT EXISTS (SELECT product_id 
					FROM product 
					WHERE UPPER(product_name) = UPPER(ordered_product)) THEN
    RAISE NOTICE 'There''s no product named % exists in the store.', ordered_product;
    END IF;
   
    IF NOT EXISTS (SELECT order_id 
    				FROM "order" 
    				WHERE UPPER(order_code) = UPPER(code_of_order)) THEN
    RAISE NOTICE 'There''s no order with code % exists in the store database.', code_of_order;
    END IF;
   
    SELECT product_id
    INTO var_product_id
    FROM product
    WHERE UPPER(product_name) = UPPER(ordered_product);
	
    SELECT order_id
    INTO var_order_id
    FROM "order"
    WHERE UPPER(order_code) = UPPER(code_of_order);

    IF (SELECT stock_quantity 
    	FROM product 
    	WHERE UPPER(product_name) = UPPER(ordered_product))<ordered_quantity THEN
	    RAISE NOTICE 'The selected number % of product is unavailable in the stock.', ordered_quantity;
	    ELSE
	   
		INSERT INTO order_detail(order_id, product_id, quantity, discount_percentage)
		SELECT 	order_id, product_id, quantity, discount_percentage
		FROM(VALUES (var_order_id, var_product_id, ordered_quantity, discount)) AS order_details (order_id, product_id, quantity, discount_percentage)
		WHERE NOT EXISTS (	SELECT order_detail_id
							FROM order_detail o
							WHERE o.order_id=order_details.order_id AND o.product_id=order_details.product_id)
		RETURNING * INTO     
	    	norderdetail_id,
	    	norder_id,
	    	nproduct_id,
	    	nquantity,
	    	ndiscount_percentage;
		RETURN NEXT;
		RAISE NOTICE 'Order details successfully inserted for order %.', code_of_order;
	END IF;		
END;
$$;

--SELECT * FROM new_order_details ('0001AB', 'sony X800', 1, 12)

/*6. Create a view that presents analytics for the most recently added quarter in your database. 
 * Ensure that the result excludes irrelevant fields such as surrogate keys and duplicate entries.*/

/*The view presents revenue and quantity among each product category during last quarter.*/

CREATE OR REPLACE VIEW sales_analytics_qtr AS
SELECT c.category_name, 
       COALESCE(SUM(od.quantity), 0) AS number_of_sold_products,
       COALESCE(SUM(p.amount), 0) AS total_sales_revenue
FROM category c
LEFT OUTER JOIN product pr ON c.category_id = pr.category_id 
LEFT OUTER JOIN order_detail od ON od.product_id = pr.product_id 
LEFT OUTER JOIN "order" o ON o.order_id = od.order_id  
LEFT OUTER JOIN payment p ON p.order_id = o.order_id AND DATE_TRUNC('QUARTER', p.payment_date) = DATE_TRUNC('QUARTER', now())
GROUP BY c.category_name
ORDER BY COALESCE(SUM(p.amount), 0) DESC;

--SELECT * FROM sales_analytics_qtr



/*7. Create a read-only role for the manager. This role should have permission to perform 
 * SELECT queries on the database tables, and also be able to log in. 
 Please ensure that you adhere to best practices for database security when defining this role*/

/*Read-only role has permission to perform SELECT queries. I created manageruser role, and then granted privileges SELECT on all tables
 * in db. I also granted schema level privileges to use specified schema. */

DO
$$
BEGIN
	IF NOT EXISTS (SELECT * FROM pg_roles WHERE rolname='manageruser') THEN 
		CREATE ROLE manageruser LOGIN PASSWORD 'managerpassword';
	END IF;
GRANT CONNECT ON DATABASE household_appliances_store TO manageruser;
GRANT USAGE ON SCHEMA store TO manageruser;
GRANT SELECT ON ALL TABLES IN SCHEMA store TO manageruser;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA store TO manageruser;
END
$$
;

--SET ROLE manageruser
--SELECT*FROM store.customer