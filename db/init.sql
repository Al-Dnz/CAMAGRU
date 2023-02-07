CREATE TABLE "user" (
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(255),
	last_name VARCHAR(255),
	email TEXT
	age INT,
);

CREATE TABLE "picture" (
	id SERIAL PRIMARY KEY,
	url VARCHAR(255),
);

INSERT INTO "user"(age, first_name, last_name, email) VALUES (32, 'polo', 'martinezi', 'pmartinezi@yopmail.com');