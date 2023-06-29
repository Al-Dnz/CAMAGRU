CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	login VARCHAR(255),
	password TEXT,
	email TEXT,
	token VARCHAR(255), 
	subscription_code VARCHAR(255) DEFAULT NULL,
	reset_password_code VARCHAR(255) DEFAULT NULL,
	validated BOOLEAN DEFAULT FALSE,
	notified BOOLEAN DEFAULT TRUE
);

CREATE TABLE pictures (
	id SERIAL PRIMARY KEY,
	path VARCHAR(255) DEFAULT NULL,
	content TEXT DEFAULT NULL,
	user_id INT DEFAULT NULL,
	published_date TIMESTAMP NOT NULL DEFAULT now(),
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE comments (
	user_id INT,
	picture_id INT,
	content TEXT DEFAULT NULL,
	published_date TIMESTAMP NOT NULL DEFAULT now(),
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
	CONSTRAINT fk_picture FOREIGN KEY(picture_id) REFERENCES pictures(id) ON DELETE CASCADE
);

CREATE TABLE likes (
	user_id INT,
	picture_id INT,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
	CONSTRAINT fk_picture FOREIGN KEY(picture_id) REFERENCES pictures(id) ON DELETE CASCADE
);