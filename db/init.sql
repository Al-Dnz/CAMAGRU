CREATE TABLE "user" (
	id SERIAL PRIMARY KEY,
	first_name VARCHAR(255),
	last_name VARCHAR(255),
	email TEXT
);
INSERT INTO "user"(first_name, last_name, email) VALUES ('polo', 'martinezi', 'pmartinezi@yopmail.com');
INSERT INTO "user"(first_name, last_name, email) VALUES ('jaky', 'etmichel', 'jakyetmichel@yopmail.com');
INSERT INTO "user"(first_name, last_name, email) VALUES ('manu', 'tchao', 'manutchao@yopmail.com');