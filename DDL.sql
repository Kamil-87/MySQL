DROP DATABASE IF EXISTS kinopoisk;
CREATE DATABASE kinopoisk;
USE kinopoisk;

-- films

DROP TABLE IF EXISTS `language`;
CREATE TABLE `language` (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
	name char(20) NOT NULL,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS films;
CREATE TABLE films (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	title VARCHAR(255) NOT NULL,
	description TEXT,
	release_year YEAR DEFAULT NULL,
	language_id TINYINT UNSIGNED NOT NULL,
	original_language_id TINYINT UNSIGNED DEFAULT NULL,
	`length` INT UNSIGNED DEFAULT NULL,
	rating ENUM('1','2','3','4','5') DEFAULT '3',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (id),
	FOREIGN KEY (language_id) REFERENCES `language` (id),
	FOREIGN KEY (original_language_id) REFERENCES `language` (id)
);


DROP TABLE IF EXISTS category;
CREATE TABLE category (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	PRIMARY KEY(id)
);


DROP TABLE IF EXISTS film_category;
CREATE TABLE film_category (
	film_id INT UNSIGNED NOT NULL,
	category_id TINYINT UNSIGNED NOT NULL,
	PRIMARY KEY (film_id,category_id),
	KEY fk_film_category_category (category_id),
	CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category(id),
	CONSTRAINT fk_film_category_films FOREIGN KEY (film_id) REFERENCES films(id)
);


DROP TABLE IF EXISTS genres;
CREATE TABLE genres (
	id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(25) NOT NULL,
	PRIMARY KEY(id)
);

DROP TABLE IF EXISTS film_genres;
CREATE TABLE film_genres (
	film_id INT UNSIGNED NOT NULL,
	genre_id TINYINT UNSIGNED NOT NULL,
	PRIMARY KEY (film_id,genre_id),
	KEY fk_film_genres_genres (genre_id),
	CONSTRAINT fk_film_genres_genres FOREIGN KEY (genre_id) REFERENCES genres(id),
	CONSTRAINT fk_film_genres_films FOREIGN KEY (film_id) REFERENCES films	(id)
);

DROP TABLE IF EXISTS hometowns;
CREATE TABLE hometowns (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	hometown VARCHAR(50) NOT NULL,
	PRIMARY KEY (id)
);


DROP TABLE IF EXISTS photos;
CREATE TABLE photos (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(255) DEFAULT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (id)
);

DROP TABLE IF EXISTS persons;
CREATE TABLE persons (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT ,
	photo_id INT UNSIGNED NOT NULL,
	firstname VARCHAR(50) DEFAULT NULL,
	lastname VARCHAR(50) DEFAULT NULL,
	gender CHAR(1) DEFAULT NULL,
	birthday DATE DEFAULT NULL,
	hometown_id INT UNSIGNED NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY(id),
	KEY persons_firstname_lastname_idx (firstname,lastname),
	FOREIGN KEY (photo_id) REFERENCES photos (id),
	FOREIGN KEY (`hometown_id`) REFERENCES `hometowns` (`id`)
);



DROP TABLE IF EXISTS films_persons;
CREATE TABLE films_persons (
	film_id INT UNSIGNED NOT NULL,
	person_id INT UNSIGNED NOT NULL,
	actor BIT DEFAULT 0,
	`director_film` BIT DEFAULT 0,
	producer BIT DEFAULT 0,
	cameraman BIT DEFAULT 0,
	KEY idx_fk_film_id (film_id),
	CONSTRAINT fk_film_person_person FOREIGN KEY (person_id) REFERENCES persons (id),
	CONSTRAINT fk_film_person_film FOREIGN KEY (film_id) REFERENCES films (id)
);


-- users


DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	firstname VARCHAR(50) DEFAULT NULL,
	lastname VARCHAR(50) DEFAULT NULL,
	email VARCHAR(120) DEFAULT NULL,
	password_hash VARCHAR(100) DEFAULT NULL,
	phone BIGINT UNSIGNED DEFAULT NULL,
	gender CHAR(1) DEFAULT NULL,
	birthday DATE DEFAULT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	hometown_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (id),
	UNIQUE KEY email (email),
	UNIQUE KEY phone (phone),
	KEY users_firstname_lastname_idx (firstname,lastname),
	FOREIGN KEY (`hometown_id`) REFERENCES `hometowns` (`id`)
);


DROP TABLE IF EXISTS rating_of_films_user;
CREATE TABLE rating_of_films_user (
	user_id BIGINT UNSIGNED NOT NULL,
	film_id INT UNSIGNED NOT NULL,
	rating ENUM('1','2','3','4','5') DEFAULT '3',
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (user_id, film_id),
	KEY idx_fk_rating_of_films_user_users (user_id),
	CONSTRAINT fk_rating_of_films_user_users FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_rating_of_films_user_films FOREIGN KEY (film_id) REFERENCES films (id) ON DELETE RESTRICT ON UPDATE CASCADE
);


DROP TABLE IF EXISTS selected_user_films;
CREATE TABLE selected_user_films (
	user_id BIGINT UNSIGNED NOT NULL,
	film_id INT UNSIGNED NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (user_id,film_id),
	KEY idx_fk_selected_user_films_users (user_id),
	CONSTRAINT fk_selected_user_films_users FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE RESTRICT ON UPDATE CASCADE,
	CONSTRAINT fk_selected_user_films_films FOREIGN KEY (film_id) REFERENCES films (id) ON DELETE RESTRICT ON UPDATE CASCADE
);


-- кинотеатры


DROP TABLE IF EXISTS cinema;
CREATE TABLE cinema (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	address VARCHAR(50) NOT NULL,
	hometown_id INT UNSIGNED NOT NULL,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (id),
	KEY `idx_fk_hometown_id` (`hometown_id`),
	CONSTRAINT `fk_address_hometown` FOREIGN KEY (`hometown_id`) REFERENCES `hometowns` (`id`)
);


DROP TABLE IF EXISTS cinema_hall;
CREATE TABLE cinema_hall (
	id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
	name VARCHAR(50) NOT NULL,
	number_of_seats SMALLINT UNSIGNED NOT NULL COMMENT 'вместимость зала',
	cinema_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (id),
	KEY idx_fk_cinema_id (cinema_id),
	CONSTRAINT fk_cinema_id FOREIGN KEY (cinema_id) REFERENCES cinema (id)
);


DROP TABLE IF EXISTS session_at_cinema;
CREATE TABLE session_at_cinema (
	film_start_date TIMESTAMP NOT NULL COMMENT 'время начала сеанса',
	ticket_price DECIMAL(5,2) NOT NULL DEFAULT 0.00,
	free_number_of_seats SMALLINT UNSIGNED NOT NULL COMMENT 'количество свободных мест',
	cinema_hall_id SMALLINT UNSIGNED NOT NULL,
	film_id INT UNSIGNED NOT NULL,
	PRIMARY KEY (cinema_hall_id, film_id, film_start_date),
	KEY idx_fk_session_id (film_id),
	CONSTRAINT fk_session_at_cinema_cinema_hall FOREIGN KEY (cinema_hall_id) REFERENCES cinema_hall (id),
	CONSTRAINT fk_session_at_cinema_film FOREIGN KEY (film_id) REFERENCES films (id)
) COMMENT 'сеанс фильма';

