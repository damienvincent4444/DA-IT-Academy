CREATE SCHEMA IF NOT EXISTS company_sprint4;
USE company_sprint4;
SHOW GLOBAL VARIABLES LIKE 'local_infile';

SET GLOBAL local_infile=1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';



CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    surname VARCHAR(100),
    phone VARCHAR(50),
    email VARCHAR(255),
    birth_date VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS credit_cards (
    id VARCHAR(50) PRIMARY KEY,
    user_id INT NOT NULL,
    iban VARCHAR(34) NOT NULL,
    pan VARCHAR(30) NOT NULL,
    pin SMALLINT UNSIGNED NOT NULL,
    cvv SMALLINT UNSIGNED NOT NULL,
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS companies (
    company_id VARCHAR(10) PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    email VARCHAR(255),
    country VARCHAR(50),
    website VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS transactions (
    id VARCHAR(50) PRIMARY KEY,
    card_id VARCHAR(50) NOT NULL,
    business_id VARCHAR(20) NOT NULL,
    timestamp DATETIME NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    declined TINYINT(1),
    product_ids VARCHAR(255),
    user_id INT NOT NULL,
    lat DOUBLE,
    longitude DOUBLE
);

LOAD DATA LOCAL INFILE 'C:/Users/damie/Downloads/american_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/damie/Downloads/european_users.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/damie/Downloads/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/damie/Downloads/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'C:/Users/damie/Downloads/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SET GLOBAL local_infile=0;
SHOW GLOBAL VARIABLES LIKE 'local_infile';


ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (card_id)
REFERENCES credit_cards(id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_business
FOREIGN KEY (business_id)
REFERENCES companies(company_id);

ALTER TABLE transactions
ADD CONSTRAINT fk_transaction_user
FOREIGN KEY (user_id)
REFERENCES users(id);




-- ************************************************ Nivell 1 - Exercici 1 ************************************************

SELECT u.id AS "ID client", u.name AS "Nom", u.surname AS "Cognom", u.country AS "Pais", (
		SELECT COUNT(t.id)
        FROM transactions t 
        WHERE t.user_id = u.id) AS "Nombre de transaccions"
FROM users u
WHERE u.id IN (
		SELECT t.user_id
        FROM transactions t
        GROUP BY t.user_id
        HAVING COUNT(t.id) > 80
);



-- ************************************************ Nivell 1 - Exercici 2 ************************************************

SELECT c.company_id AS "ID Companya", cc.iban AS "IBAN", ROUND(AVG(t.amount), 2) AS "Mitjana d'amount per IBAN"
FROM transactions t
JOIN companies c
ON t.business_id = c.company_id
JOIN credit_cards cc
ON t.card_id = cc.id 
WHERE c.company_name = 'Donec Ltd'
GROUP BY c.company_id, cc.iban
ORDER BY AVG(t.amount) DESC;



-- ************************************************ Nivell 2 - Exercici 1 ************************************************

CREATE TABLE cc_status AS WITH OrderedTransactions AS (
		SELECT t.card_id, t.declined, t.timestamp, ROW_NUMBER() OVER (
				PARTITION BY t.card_id 
				ORDER BY t.timestamp DESC) AS transactions_order
		FROM transactions t
),

LastThree AS (
		SELECT ot.card_id, SUM(ot.declined) AS declined_in_last_three
		FROM OrderedTransactions ot
		WHERE ot.transactions_order <= 3
		GROUP BY ot.card_id
)

SELECT lt.card_id AS ID_targeta,
		CASE
			WHEN lt.declined_in_last_three = 3 THEN "Inactiva"
			ELSE "Activa"
		END AS `Estat targeta`
FROM LastThree lt;



SELECT COUNT(*) AS "Total targetes actives"
FROM cc_status
WHERE `Estat targeta` = 'Activa';



-- ************************************************ Nivell 3 - Exercici 1 ************************************************


SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile=1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';


CREATE TABLE IF NOT EXISTS products (
    id INT PRIMARY KEY,
    product_name VARCHAR(255),
    price DECIMAL(10, 2),
    colour VARCHAR(50),
    weight DECIMAL(5, 2),
    warehouse_id VARCHAR(10)
);

LOAD DATA LOCAL INFILE 'C:/Users/damie/Downloads/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id, product_name, @price_string, colour, weight, warehouse_id)
SET price = REPLACE(@price_string, '$', '');


SET GLOBAL local_infile=0;
SHOW GLOBAL VARIABLES LIKE 'local_infile';





CREATE TABLE IF NOT EXISTS transaction_product (
    transaction_id VARCHAR(50) NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);


INSERT INTO transaction_product (transaction_id, product_id)
SELECT t.id AS transaction_id, CAST(jt.product_id AS UNSIGNED) AS product_id
FROM transactions t,
JSON_TABLE(
	CONCAT('[', REPLACE(t.product_ids, ' ', ''), ']' ),
	'$[*]' COLUMNS (product_id VARCHAR(10) PATH '$') ) AS jt
WHERE t.product_ids IS NOT NULL 
AND t.product_ids <> '';


SELECT p.id AS "ID producte", p.product_name AS "Nom producte", COUNT(tp.transaction_id) AS "Nombre total vendes"
FROM transaction_product tp
JOIN products p 
ON tp.product_id = p.id
JOIN transactions t
ON tp.transaction_id = t.id
WHERE t.declined = 0
GROUP BY p.id, p.product_name
ORDER BY COUNT(tp.transaction_id) DESC;