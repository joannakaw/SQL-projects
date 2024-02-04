/*
1.Create a physical database with a separate database and schema and give it an appropriate domain-related name. 
Use the relational model you've created while studying DB Basics module. Task 2 (designing a logical data model on the chosen topic). Make sure you have made any changes to your model after your mentor's comments.
2.Your database must be in 3NF
3.Use appropriate data types for each column and apply DEFAULT values, and GENERATED ALWAYS AS columns as required.
4.Create relationships between tables using primary and foreign keys.
5.Apply five check constraints across the tables to restrict certain values, including
	-date to be inserted, which must be greater than January 1, 2000
	-inserted measured value that cannot be negative
	-inserted value that can only be a specific value (as an example of gender)
	-unique
	-not null
6.Populate the tables with the sample data generated, ensuring each table has at least two rows (for a total of 20+ rows in all the tables).
7.Add a not null 'record_ts' field to each table using ALTER TABLE statements, set the default value to current_date, and check to make sure the value has been set for the existing rows.
*/

/*Firstly I created database recruitment_agency, after that I have to add new database connection to 
 * connect with my new database in DBeaver. Then I created new schema and two enum data type which were used later in tables.  */

/*DROP DATABASE IF EXISTS recruitment_agency;
CREATE DATABASE recruitment_agency;*/

CREATE SCHEMA IF NOT EXISTS agency;

DROP TYPE IF EXISTS agency."job_cat";
CREATE TYPE agency."job_cat" AS ENUM (
	'full-time',
	'part-time',
	'casual'
);

DROP TYPE IF EXISTS agency."emp_type" CASCADE;
CREATE TYPE agency."emp_type" AS ENUM (
	'contract of employment',
	'B2B',
	'contract work',
	'mandate contract'
);


/*In this part I created all tables with appropriate data type and some of constraints. For each table PK constraint
 * was specified. For example, the default constraint was used in agency.job_skill table, and GENERATED ALWAYS AS
 * was used in agency.service table. For agency.job_offer table were applied created erlier data types to limit values
 * chosen in particular columns. In general, some constraints were defined while creating table and some were defined
 * later in separate ALTER TABLE clauses.*/

-- agency.employer definition

CREATE TABLE IF NOT EXISTS agency.employer (
	employer_id serial4 NOT NULL,
	employer_name varchar(50) NOT NULL,
	industry varchar (50) NOT NULL,
	email varchar (50),
	phone_number varchar (50),
	CONSTRAINT PK_employer PRIMARY KEY (employer_id)
);


-- agency.country definition
CREATE TABLE IF NOT EXISTS agency.country (
	country_id serial4 NOT NULL,
	country varchar(50) NOT NULL UNIQUE,
	CONSTRAINT PK_country PRIMARY KEY (country_id)
);


-- agency.location definition
CREATE TABLE IF NOT EXISTS agency.location (
	location_id serial4 NOT NULL,
	country_id int NOT NULL,
	city varchar(50) NOT NULL,
	CONSTRAINT PK_location PRIMARY KEY (location_id)
);


-- agency.seniority_level definition
CREATE TABLE IF NOT EXISTS agency.seniority_level (
	seniority_level_id serial4 NOT NULL,
	seniority_level varchar(50) NOT NULL UNIQUE,
	CONSTRAINT PK_seniority_level PRIMARY KEY (seniority_level_id)
);


-- agency.job_offer definition
CREATE TABLE IF NOT EXISTS agency.job_offer (
	job_offer_id serial4 NOT NULL,
	job_category agency.job_cat NULL DEFAULT 'full-time':: agency.job_cat,
	position varchar (50) NOT NULL,
	employment_type agency.emp_type NULL DEFAULT 'contract of employment':: agency.emp_type,
	work_model varchar (50),
	salary int,
	location_id int NOT NULL,
	employer_id int NOT NULL,
	seniority_level_id int NOT NULL,
	CONSTRAINT PK_job_offer PRIMARY KEY (job_offer_id)
);


-- agency.recruiter definition
CREATE TABLE IF NOT EXISTS agency.recruiter (
	recruiter_id serial4 NOT NULL,
	firstname varchar(50) NOT NULL,
	lastname varchar (50) NOT NULL,
	email varchar (50) NOT NULL,
	phone_number varchar (50),
	CONSTRAINT PK_recruiter PRIMARY KEY (recruiter_id)
);


-- agency.candidate definition
CREATE TABLE IF NOT EXISTS agency.candidate (
	candidate_id serial4 NOT NULL,
	firstname varchar(50) NOT NULL,
	lastname varchar (50) NOT NULL,
	email varchar (50),
	phone_number varchar (50),
	candidate_status varchar(50),
	location_id int,
	recruiter_id int NOT NULL,
	CONSTRAINT PK_candidate PRIMARY KEY (candidate_id)
);


-- agency.service definition
CREATE TABLE IF NOT EXISTS agency.service (
	service_id serial4 NOT NULL,
	service_name varchar(50) NOT NULL,
	duration int,
	price_net int,
	price_gross numeric(5,2) GENERATED ALWAYS AS (price_net * 1.23) STORED,
	CONSTRAINT PK_service PRIMARY KEY (service_id)
);


-- agency.applied_service definition
CREATE TABLE IF NOT EXISTS agency.applied_service (
	applied_service_id serial4 NOT NULL,
	candidate_id int NOT NULL,
	recruiter_id int NOT NULL,
	service_id int NOT NULL,
	CONSTRAINT PK_applied_service PRIMARY KEY (applied_service_id)
);


-- agency.application_status definition
CREATE TABLE IF NOT EXISTS agency.application_status (
	application_status_id serial4 NOT NULL,
	status varchar(50) NOT NULL UNIQUE,
	CONSTRAINT PK_application_status PRIMARY KEY (application_status_id)
);


-- agency.application definition
CREATE TABLE IF NOT EXISTS agency.application (
	application_id serial4 NOT NULL,
	candidate_id int NOT NULL,
	job_offer_id int NOT NULL,
	application_date date NOT NULL,
	application_status_id int NOT NULL,
	CONSTRAINT PK_application PRIMARY KEY (application_id)
);


-- agency.document definition
CREATE TABLE IF NOT EXISTS agency.document (
	document_id serial4 NOT NULL,
	candidate_id int NOT NULL,
	document_name varchar(50) NOT NULL,
	CONSTRAINT PK_document PRIMARY KEY (document_id)
);


-- agency.education definition
CREATE TABLE IF NOT EXISTS agency.education (
	education_id serial4 NOT NULL,
	candidate_id int NOT NULL,
	school_name varchar(50) NOT NULL,
	field varchar(50) NOT NULL,
	degree varchar(50) NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	CONSTRAINT PK_education PRIMARY KEY (education_id)
);


-- agency.experience definition
CREATE TABLE IF NOT EXISTS agency.experience (
	experience_id serial4 NOT NULL,
	candidate_id int NOT NULL,
	company varchar(50) NOT NULL,
	work_position varchar(50) NOT NULL,
	start_date date NOT NULL,
	end_date date NOT NULL,
	CONSTRAINT PK_experience PRIMARY KEY (experience_id)
);


-- agency.skill definition
CREATE TABLE IF NOT EXISTS agency.skill (
	skill_id serial4 NOT NULL,
	skill_name varchar(50) NOT NULL UNIQUE,
	CONSTRAINT PK_skill PRIMARY KEY (skill_id)
);


-- agency.candidate_skill definition
CREATE TABLE IF NOT EXISTS agency.job_skill (
	job_skill_id serial4 NOT NULL,
	job_offer_id int NOT NULL,
	skill_id int NOT NULL,
	familarity_level int DEFAULT(3),
	CONSTRAINT PK_job_skill PRIMARY KEY (job_skill_id)
);


-- agency.job_skill definition
CREATE TABLE IF NOT EXISTS agency.candidate_skill (
	candidate_skill_id serial4 NOT NULL,
	candidate_id int NOT NULL,
	skill_id int NOT NULL,
	familarity_level int DEFAULT(3),
	CONSTRAINT PK_candidate_skill PRIMARY KEY (candidate_skill_id)
);



--references
/*Below statements established relationships between tables. They specified foreign keys in each table (FOREIGN KEY constraint) and 
 * reference to other table with primary key*/

ALTER TABLE agency.location
DROP CONSTRAINT IF EXISTS FK_location_country_id;
ALTER TABLE agency.location 
ADD CONSTRAINT FK_location_country_id FOREIGN KEY (country_id) REFERENCES agency.country(country_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.job_offer
DROP CONSTRAINT IF EXISTS FK_job_offer_location_id;
ALTER TABLE agency.job_offer 
ADD CONSTRAINT FK_job_offer_location_id FOREIGN KEY (location_id) REFERENCES agency.location(location_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.job_offer
DROP CONSTRAINT IF EXISTS FK_job_offer_employer_id;
ALTER TABLE agency.job_offer 
ADD CONSTRAINT FK_job_offer_employer_id FOREIGN KEY (employer_id) REFERENCES agency.employer(employer_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.job_offer
DROP CONSTRAINT IF EXISTS FK_job_offer_seniority_level_id;
ALTER TABLE agency.job_offer 
ADD CONSTRAINT FK_job_offer_seniority_level_id FOREIGN KEY (seniority_level_id) REFERENCES agency.seniority_level(seniority_level_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.candidate
DROP CONSTRAINT IF EXISTS FK_candidate_location_id;
ALTER TABLE agency.candidate 
ADD CONSTRAINT FK_candidate_location_id FOREIGN KEY (location_id) REFERENCES agency.location(location_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.candidate
DROP CONSTRAINT IF EXISTS FK_candidate_recruiter_id;
ALTER TABLE agency.candidate 
ADD CONSTRAINT FK_candidate_recruiter_id FOREIGN KEY (recruiter_id) REFERENCES agency.recruiter(recruiter_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.applied_service 
DROP CONSTRAINT IF EXISTS FK_applied_service_candidate_id;
ALTER TABLE agency.applied_service 
ADD CONSTRAINT FK_applied_service_candidate_id FOREIGN KEY (candidate_id) REFERENCES agency.candidate(candidate_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.applied_service 
DROP CONSTRAINT IF EXISTS FK_applied_service_recruiter_id;
ALTER TABLE agency.applied_service 
ADD CONSTRAINT FK_applied_service_recruiter_id FOREIGN KEY (recruiter_id) REFERENCES agency.recruiter(recruiter_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.applied_service 
DROP CONSTRAINT IF EXISTS FK_applied_service_service_id;
ALTER TABLE agency.applied_service 
ADD CONSTRAINT FK_applied_service_service_id FOREIGN KEY (service_id) REFERENCES agency.service(service_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.application 
DROP CONSTRAINT IF EXISTS FK_application_candidate_id;
ALTER TABLE agency.application 
ADD CONSTRAINT FK_application_candidate_id FOREIGN KEY (candidate_id) REFERENCES agency.candidate(candidate_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.application 
DROP CONSTRAINT IF EXISTS FK_application_job_offer_id;
ALTER TABLE agency.application 
ADD CONSTRAINT FK_application_job_offer_id FOREIGN KEY (job_offer_id) REFERENCES agency.job_offer(job_offer_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.application 
DROP CONSTRAINT IF EXISTS FK_application_application_status_id;
ALTER TABLE agency.application 
ADD CONSTRAINT FK_application_application_status_id FOREIGN KEY (application_status_id) REFERENCES agency.application_status(application_status_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.document 
DROP CONSTRAINT IF EXISTS FK_document_candidate_id;
ALTER TABLE agency.document 
ADD CONSTRAINT FK_document_candidate_id FOREIGN KEY (candidate_id) REFERENCES agency.candidate(candidate_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.education 
DROP CONSTRAINT IF EXISTS FK_education_candidate_id;
ALTER TABLE agency.education 
ADD CONSTRAINT FK_education_candidate_id FOREIGN KEY (candidate_id) REFERENCES agency.candidate(candidate_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.experience 
DROP CONSTRAINT IF EXISTS FK_experience_candidate_id;
ALTER TABLE agency.experience 
ADD CONSTRAINT FK_experience_candidate_id FOREIGN KEY (candidate_id) REFERENCES agency.candidate(candidate_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.job_skill 
DROP CONSTRAINT IF EXISTS FK_job_skill_job_offer_id;
ALTER TABLE agency.job_skill 
ADD CONSTRAINT FK_job_skill_job_offer_id FOREIGN KEY (job_offer_id) REFERENCES agency.job_offer(job_offer_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.job_skill 
DROP CONSTRAINT IF EXISTS FK_job_skill_skill_id;
ALTER TABLE agency.job_skill 
ADD CONSTRAINT FK_job_skill_skill_id FOREIGN KEY (skill_id) REFERENCES agency.skill(skill_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.candidate_skill 
DROP CONSTRAINT IF EXISTS FK_candidate_skill_candidate_id;
ALTER TABLE agency.candidate_skill 
ADD CONSTRAINT FK_candidate_skill_candidate_id FOREIGN KEY (candidate_id) REFERENCES agency.candidate(candidate_id) ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE agency.candidate_skill 
DROP CONSTRAINT IF EXISTS FK_candidate_skill_skill_id;
ALTER TABLE agency.candidate_skill 
ADD CONSTRAINT FK_candidate_skill_skill_id FOREIGN KEY (skill_id) REFERENCES agency.skill(skill_id) ON DELETE RESTRICT ON UPDATE CASCADE;


/*Next step was to applied other constarints which weren't applied while creating tables. For instance, CHECK constraint in
 * job_offer table to check if salary column has positive values since it can't be negative value. Similarily for 
 * service table and price_net column. In job_offer table I added CHECK constraint which specifies allowed work_model,
 * the same for candidate table - CHECK specifies values for candidate_status column and in job_skill and candidate_skill CHECK for familarity level.
 * There's as well CHECK constraint for application_date column in application table, for dates greater than 1st January 2000, accordingly
 * to condition given in task. For email column in candidate and employer tables was applied CHECK to verify the correctness of email. 
 * For education and experience table were applied CHECK constraints for veryfing correct order of dates. */

ALTER TABLE agency.job_offer 
DROP CONSTRAINT IF EXISTS job_offer_salary_check;
ALTER TABLE agency.job_offer 
ADD CONSTRAINT job_offer_salary_check CHECK (salary > 0);

ALTER TABLE agency.service 
DROP CONSTRAINT IF EXISTS service_price_net_check;
ALTER TABLE agency.service 
ADD CONSTRAINT service_price_net_check CHECK (price_net > 0);

ALTER TABLE agency.job_offer 
DROP CONSTRAINT IF EXISTS work_model_check;
ALTER TABLE agency.job_offer
ADD CONSTRAINT work_model_check CHECK (work_model IN ('office work', 'hybrid', 'remote'));

ALTER TABLE agency.job_offer 
ALTER COLUMN salary SET NOT NULL;

ALTER TABLE agency.application 
DROP CONSTRAINT IF EXISTS application_date_check;
ALTER TABLE agency.application 
ADD CONSTRAINT application_date_check CHECK (application_date > '2020-01-01':: DATE);

ALTER TABLE agency.candidate 
DROP CONSTRAINT IF EXISTS candidate_status_check;
ALTER TABLE agency.candidate
ADD CONSTRAINT candidate_status_check CHECK (candidate_status IN ('active', 'passive'));

ALTER TABLE agency.candidate
ALTER COLUMN candidate_status SET DEFAULT 'active';

ALTER TABLE agency.employer 
DROP CONSTRAINT IF EXISTS employer_email_check;
ALTER TABLE agency.employer
ADD CONSTRAINT employer_email_check CHECK (email LIKE '%@%.%');

ALTER TABLE agency.candidate 
ALTER COLUMN email SET NOT NULL;

ALTER TABLE agency.employer 
DROP CONSTRAINT IF EXISTS employer_email_unique;
ALTER TABLE agency.employer
ADD CONSTRAINT employer_email_unique UNIQUE (email);

ALTER TABLE agency.recruiter 
DROP CONSTRAINT IF EXISTS recruiter_email_unique;
ALTER TABLE agency.recruiter
ADD CONSTRAINT recruiter_email_unique UNIQUE (email);

ALTER TABLE agency.candidate 
DROP CONSTRAINT IF EXISTS candidate_email_check;
ALTER TABLE agency.candidate
ADD CONSTRAINT candidate_email_check CHECK (email LIKE '%@%.%');

ALTER TABLE agency.candidate 
DROP CONSTRAINT IF EXISTS candidate_email_unique;
ALTER TABLE agency.candidate
ADD CONSTRAINT candidate_email_unique UNIQUE (email);

ALTER TABLE agency.education 
DROP CONSTRAINT IF EXISTS education_dates_check;
ALTER TABLE agency.education
ADD CONSTRAINT education_dates_check CHECK (start_date < end_date);

ALTER TABLE agency.experience 
DROP CONSTRAINT IF EXISTS experience_dates_check;
ALTER TABLE agency.experience
ADD CONSTRAINT experience_dates_check CHECK (start_date < end_date);

ALTER TABLE agency.candidate_skill 
DROP CONSTRAINT IF EXISTS candidate_skill_level_check;
ALTER TABLE agency.candidate_skill
ADD CONSTRAINT candidate_skill_level_check CHECK (familarity_level IN(1,2,3,4,5));

ALTER TABLE agency.job_skill 
DROP CONSTRAINT IF EXISTS job_skill_level_check;
ALTER TABLE agency.job_skill
ADD CONSTRAINT job_skill_level_check CHECK (familarity_level IN(1,2,3,4,5));




--POPULATING TABLES
/*Following statements populate the tables with sample data. Some columns with DEFAULT values 
 * or without NOT NULL constraints can be ommitted. All inserted data must meet all constraint rules. For each 
 * insertion I added WHERE NOT EXISTS clause to avoid potencial the errors. */

--employer
INSERT INTO agency.employer (employer_name, industry, email, phone_number)
SELECT 'Design Hub',
		'architecture',
		'hr@designhub.pl',
		'(+48)8877799'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.employer 
					WHERE UPPER(employer_name) ='DESIGN HUB')
UNION ALL
SELECT 'Good Store',
		'commerce',
		'good_store@gmail.com',
		'(+48)821821821'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.employer 
					WHERE UPPER(employer_name) ='GOOD STORE')
RETURNING *;


--country
WITH country_names AS(
SELECT 'Poland'
UNION
SELECT 'Czech Republic')
INSERT INTO agency.country (country)
SELECT * FROM country_names
WHERE NOT EXISTS (	SELECT * 
					FROM agency.country 
					WHERE UPPER(country) IN ('POLAND', 'CZECH REPUBLIC'))
RETURNING *;


--location
INSERT INTO agency.location(country_id, city)
SELECT (SELECT country_id 
		FROM agency.country 
		WHERE UPPER(country) = 'POLAND'),
		'Warsaw'
WHERE NOT EXISTS (	SELECT city 
					FROM agency.location 
					WHERE UPPER(city) = 'WARSAW')
UNION ALL
SELECT (SELECT country_id 
		FROM agency.country 
		WHERE UPPER(country) = 'CZECH REPUBLIC'),
		'Prague'
WHERE NOT EXISTS (	SELECT city 
					FROM agency.location 
					WHERE UPPER(city) = 'PRAGUE')
RETURNING *;


--seniority_level
WITH seniority_name AS(
SELECT 'trainee'
UNION
SELECT 'junior'
UNION 
SELECT 'mid'
UNION 
SELECT 'senior')
INSERT INTO agency.seniority_level (seniority_level)
SELECT * FROM seniority_name
WHERE NOT EXISTS (	SELECT * 
					FROM agency.seniority_level 
					WHERE UPPER(seniority_level) IN ('TRAINEE', 'JUNIOR', 'MID', 'SENIOR'))
RETURNING *;


--job_offer
INSERT INTO agency.job_offer (job_category, "position", work_model, salary, location_id, employer_id, seniority_level_id)
SELECT 	job_category,
		"position",
		work_model,
		salary,
		location_id,
		employer_id, 
		seniority_level_id
FROM (VALUES('full-time', 'architect', 'hybrid', 7000, (SELECT location_id FROM agency."location" 
		WHERE UPPER(city)='WARSAW'), (SELECT employer_id FROM agency.employer WHERE UPPER(employer_name) = 'DESIGN HUB'), 
		(SELECT seniority_level_id FROM agency.seniority_level WHERE UPPER(seniority_level) = 'MID')),
		('part-time', 'seller', 'office work', 3000, 		(SELECT location_id 
		FROM agency."location" 
		WHERE UPPER(city)='PRAGUE'),
		(SELECT employer_id 
		FROM agency.employer 
		WHERE UPPER(employer_name) = 'GOOD STORE'),
		(SELECT seniority_level_id 
		FROM agency.seniority_level
		WHERE UPPER(seniority_level) = 'JUNIOR'))) AS offers (job_category, "position", work_model, salary, location_id, employer_id, seniority_level_id)
WHERE NOT EXISTS (	SELECT job_offer_id 
					FROM agency.job_offer jo
					WHERE 	jo.job_category = offers.job_category AND
							jo."position" = offers."position" AND
							jo.work_model = offers.work_model AND
							jo.salary = offers.salary AND
							jo.location_id = offers.location_id AND
							jo.employer_id = offers.employer_id AND
							jo.seniority_level_id = offers.seniority_level_id)
RETURNING *;

--recruiter
INSERT INTO agency.recruiter (firstname, lastname, email, phone_number)
SELECT 'Michael',
		'Scott',
		'mscott@recruitment.com',
		'(45)222-333-22'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.recruiter 
					WHERE LOWER(email) = 'mscott@recruitment.com')
UNION ALL
SELECT  'Hannah',
		'Green',
		'hgreen@recruitment.com',
		'(45)222-333-33'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.recruiter 
					WHERE LOWER(email) = 'hgreen@recruitment.com')
RETURNING *;


--candidate
INSERT INTO agency.candidate (firstname, lastname, email, location_id, recruiter_id)
SELECT 	'John',
		'Snow',
		'jsnow@gmail.com',
		(SELECT location_id 
		FROM agency."location" 
		WHERE UPPER(city)='WARSAW'),
		(SELECT recruiter_id 
		FROM agency.recruiter
		WHERE LOWER(email)='hgreen@recruitment.com')
WHERE NOT EXISTS (	SELECT * 
					FROM agency.candidate 
					WHERE LOWER(email) = 'adams.amy@gmail.com')
UNION ALL 
SELECT 	'Amy',
		'Adams',
		'adams.amy@gmail.com',
		(SELECT location_id 
		FROM agency."location" 
		WHERE UPPER(city)='WARSAW'),
		(SELECT recruiter_id 
		FROM agency.recruiter
		WHERE LOWER(email)='hgreen@recruitment.com')
WHERE NOT EXISTS (	SELECT * 
					FROM agency.candidate 
					WHERE LOWER(email) = 'adams.amy@gmail.com')
RETURNING *;


--service
INSERT INTO agency.service (service_name, duration, price_net)
SELECT 'resume writing',
		2,
		50
WHERE NOT EXISTS (	SELECT * 
					FROM agency.service 
					WHERE LOWER(service_name) = 'resume writing')
UNION ALL
SELECT 	'interview practicing',
		5,
		200
WHERE NOT EXISTS (	SELECT * 
					FROM agency.service 
					WHERE LOWER(service_name) = 'interview practicing')
RETURNING *;


--applied_service
INSERT INTO agency.applied_service (candidate_id, recruiter_id, service_id)
SELECT 	candidate_id, 
		recruiter_id, 
		service_id
FROM (VALUES((SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'adams.amy@gmail.com'),
		(SELECT recruiter_id
		FROM agency.recruiter 
		WHERE LOWER(email) = 'mscott@recruitment.com'),
		(SELECT service_id
		FROM agency.service WHERE LOWER(service_name) = 'resume writing')),
		((SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'adams.amy@gmail.com'),
		(SELECT recruiter_id
		FROM agency.recruiter 
		WHERE LOWER(email) = 'mscott@recruitment.com'),
		(SELECT service_id
		FROM agency.service WHERE LOWER(service_name) = 'interview practicing'))) AS app_serv (candidate_id, recruiter_id, service_id)
WHERE NOT EXISTS (	SELECT applied_service_id
					FROM agency.applied_service aps
					WHERE 	aps.candidate_id = app_serv.candidate_id AND
							aps.recruiter_id = app_serv.recruiter_id AND
							aps.service_id = app_serv.service_id)
RETURNING *;


--application_status
INSERT INTO agency.application_status (status)
SELECT 'sent'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.application_status 
					WHERE LOWER(status) IN('sent'))
UNION
SELECT 'verification'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.application_status 
					WHERE LOWER(status) IN('verification'))
UNION 
SELECT 'refusal'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.application_status 
					WHERE LOWER(status) IN('refusal' ))
UNION 
SELECT 'approval'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.application_status 
					WHERE LOWER(status) IN('approval' ))
RETURNING *;


--application
INSERT INTO agency.application (candidate_id, job_offer_id, application_date, application_status_id)
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'adams.amy@gmail.com'),
		(SELECT job_offer_id 
		FROM agency.job_offer WHERE LOWER("position") = 'architect' AND
									employer_id IN(	SELECT employer_id 
													FROM agency.employer
													WHERE UPPER(employer_name) = 'DESIGN HUB')),
		NOW()::date,
		(SELECT application_status_id
		FROM agency.application_status
		WHERE LOWER(status) = 'sent')
UNION ALL
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'jsnow@gmail.com'),
		(SELECT job_offer_id 
		FROM agency.job_offer WHERE LOWER("position") = 'architect' AND
									employer_id IN(	SELECT employer_id 
													FROM agency.employer
													WHERE UPPER(employer_name) = 'DESIGN HUB')),
		NOW()::date,
		(SELECT application_status_id
		FROM agency.application_status
		WHERE LOWER(status) = 'verification')
RETURNING *;


--document
INSERT INTO agency."document" (candidate_id, document_name)
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'jsnow@gmail.com'),
		'CV'
UNION ALL 
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'adams.amy@gmail.com'),
		'CV'
RETURNING *;


--education
INSERT INTO agency.education (candidate_id, school_name, field, "degree", start_date, end_date)
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'jsnow@gmail.com'),
		'Cambridge',
		'Law',
		'master',
		'2015-10-01'::date,
		'2020-06-01'::date
WHERE NOT EXISTS (	SELECT * 
					FROM agency.education
					WHERE candidate_id = (	SELECT candidate_id
											FROM agency.candidate 
											WHERE LOWER(email) = 'jsnow@gmail.com')AND
							UPPER(school_name) = 'CAMBRIDGE' AND 
							UPPER(field) = 'LAW' AND 
							UPPER("degree") = 'MASTER')
UNION ALL
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'jsnow@gmail.com'),
		'Gdansk University of Technology',
		'Psychology',
		'master',
		'2010-10-01'::date,
		'2014-06-01'::date
WHERE NOT EXISTS (	SELECT * 
					FROM agency.education
					WHERE candidate_id = (	SELECT candidate_id
											FROM agency.candidate 
											WHERE LOWER(email) = 'jsnow@gmail.com')AND
							UPPER(school_name) = 'GDANSK UNIVERSITY OF TECHNOLOGY' AND 
							UPPER(field) = 'PSYCHOLOGY' AND 
							UPPER("degree") = 'MASTER')
RETURNING *;


--experience
INSERT INTO agency.experience (candidate_id, company, work_position, start_date, end_date)
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'adams.amy@gmail.com'),
		'FinTech',
		'Financial Controller',
		'2019-10-01'::date,
		'2020-03-01'::date
WHERE NOT EXISTS (	SELECT * 
					FROM agency.experience
					WHERE candidate_id = (	SELECT candidate_id
											FROM agency.candidate 
											WHERE LOWER(email) = 'adams.amy@gmail.com')AND
							UPPER(company) = 'FINTECH' AND 
							UPPER(work_position) = 'FINANCIAL CONTROLLER')
UNION ALL
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'jsnow@gmail.com'),
		'Count on US',
		'Lawyer',
		'2010-10-01'::date,
		'2014-06-01'::date
WHERE NOT EXISTS (	SELECT * 
					FROM agency.experience
					WHERE candidate_id = (	SELECT candidate_id
											FROM agency.candidate 
											WHERE LOWER(email) = 'jsnow@gmail.com')AND
							UPPER(company) = 'COUNT ON US' AND 
							UPPER(work_position) = 'LAWYER')
RETURNING *;


--skill
INSERT INTO agency.skill (skill_name)
SELECT 'Python'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.skill 
					WHERE UPPER(skill_name)='PYTHON')
UNION ALL
SELECT 'PowerBI'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.skill 
					WHERE UPPER(skill_name)='POWERBI')
UNION ALL
SELECT 'English'
WHERE NOT EXISTS (	SELECT * 
					FROM agency.skill 
					WHERE UPPER(skill_name)='ENGLISH')
RETURNING *;


--candidate_skill
INSERT INTO agency.candidate_skill (candidate_id, skill_id)
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'adams.amy@gmail.com'),
		(SELECT skill_id
		FROM agency.skill
		WHERE UPPER(skill_name) = 'ENGLISH')
WHERE NOT EXISTS (	SELECT * 
					FROM agency.candidate_skill
					WHERE candidate_id = (	SELECT candidate_id
											FROM agency.candidate 
											WHERE LOWER(email) = 'adams.amy@gmail.com') AND 
						skill_id = (SELECT skill_id
									FROM agency.skill
									WHERE UPPER(skill_name)='ENGLISH'))
UNION ALL 
SELECT 	(SELECT candidate_id
		FROM agency.candidate 
		WHERE LOWER(email) = 'jsnow@gmail.com'),
		(SELECT skill_id
		FROM agency.skill
		WHERE UPPER(skill_name) = 'PYTHON')
WHERE NOT EXISTS (	SELECT * 
					FROM agency.candidate_skill
					WHERE candidate_id = (	SELECT candidate_id
											FROM agency.candidate 
											WHERE LOWER(email) = 'jsnow@gmail.com') AND 
						skill_id = (SELECT skill_id
									FROM agency.skill
									WHERE UPPER(skill_name)='PYTHON'))
RETURNING *;


--job_skill
INSERT INTO agency.job_skill (job_offer_id, skill_id)
SELECT 	(SELECT job_offer_id
		FROM agency.job_offer 
		WHERE LOWER(position) = 'architect' AND
		employer_id = (SELECT employer_id
						FROM agency.employer
						WHERE UPPER(employer_name)= 'DESIGN HUB' )),
		(SELECT skill_id
		FROM agency.skill
		WHERE UPPER(skill_name) = 'ENGLISH')
WHERE NOT EXISTS (	SELECT * 
					FROM agency.job_skill
					WHERE job_offer_id = (	SELECT job_offer_id
											FROM agency.job_offer 
											WHERE LOWER(position) = 'architect' AND
													employer_id = (SELECT employer_id
																	FROM agency.employer
																	WHERE UPPER(employer_name)= 'DESIGN HUB' ))AND 					
						skill_id = (SELECT skill_id
									FROM agency.skill
									WHERE UPPER(skill_name)='ENGLISH'))
UNION ALL 
SELECT 	(SELECT job_offer_id
		FROM agency.job_offer 
		WHERE LOWER(position) = 'architect' AND
		employer_id = (SELECT employer_id
						FROM agency.employer
						WHERE UPPER(employer_name)= 'DESIGN HUB')),
		(SELECT skill_id
		FROM agency.skill
		WHERE UPPER(skill_name) = 'POWERBI')
WHERE NOT EXISTS (	SELECT * 
					FROM agency.job_skill
					WHERE job_offer_id = (	SELECT job_offer_id
											FROM agency.job_offer 
											WHERE LOWER(position) = 'architect' AND
													employer_id = (SELECT employer_id
																	FROM agency.employer
																	WHERE UPPER(employer_name)= 'DESIGN HUB' ))AND 					
						skill_id = (SELECT skill_id
									FROM agency.skill
									WHERE UPPER(skill_name)='POWERBI'))
RETURNING *;


--adding record_ts
/*To add another record in the table I used ALTER TABLE statement and added column with DEFAULT current_date.
 * After executing, in each table the value of current_date has been set to existing rows.*/

ALTER TABLE agency.employer
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.country
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.location
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.seniority_level
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.job_offer
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.recruiter
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.candidate
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.service
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.applied_service
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.application_status
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.application
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.document
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.education
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.experience
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.skill
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.candidate_skill
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

ALTER TABLE agency.job_skill
ADD COLUMN IF NOT EXISTS record_ts date NOT NULL DEFAULT current_date;

