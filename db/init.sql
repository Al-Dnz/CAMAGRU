CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	login VARCHAR(255),
	password TEXT,
	email TEXT,
	token VARCHAR(255), 
	subscription_code VARCHAR(255) DEFAULT NULL,
	validated BOOLEAN DEFAULT FALSE,
	notified BOOLEAN DEFAULT FALSE
);

CREATE TABLE pictures (
	id SERIAL PRIMARY KEY,
	path VARCHAR(255) DEFAULT NULL,
	content TEXT DEFAULT NULL,
	user_id INT DEFAULT NULL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE comments (
	user_id INT,
	picture_id INT,
	content TEXT DEFAULT NULL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_picture FOREIGN KEY(picture_id) REFERENCES pictures(id)
);

CREATE TABLE likes (
	user_id INT,
	picture_id INT,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id),
	CONSTRAINT fk_picture FOREIGN KEY(picture_id) REFERENCES pictures(id)
);

-- INSERT INTO "users"(login, password, email) VALUES ('polo', 'qwerty', 'pmartinezi@yopmail.com');
-- INSERT INTO "users"(login, password, email) VALUES ('manu', 'azerty', 'manutchao@yopmail.com');
-- INSERT INTO "pictures"(content, user_id, path) VALUES ('top rigolo', 1, 'www.shlagistos.com');
-- INSERT INTO "comments"(content, user_id, picture_id) VALUES ('excellent la photo !', 1, 1);



