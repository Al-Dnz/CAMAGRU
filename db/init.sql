CREATE TABLE "user" (
	id SERIAL PRIMARY KEY,
	login VARCHAR(255),
	password TEXT,
	email TEXT,
	subscription_code VARCHAR(255) DEFAULT NULL,
	validated BOOLEAN DEFAULT FALSE
);

INSERT INTO "user"(login, password, email) VALUES ('polo', 'qwerty', 'pmartinezi@yopmail.com');
INSERT INTO "user"(login, password, email) VALUES ('manu', 'azerty', 'manutchao@yopmail.com');
