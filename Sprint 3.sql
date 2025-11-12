-- ******************************************************** Nivell 1 *************************************************************

-- ****************************** Exercici 1 ******************************


USE transactions;

CREATE TABLE IF NOT EXISTS credit_card (
	id VARCHAR(10) NOT NULL PRIMARY KEY,
    iban VARCHAR(34) UNIQUE,
    pan VARCHAR(25) UNIQUE,
    pin VARCHAR(4),
    cvv VARCHAR(4),
    expiring_date VARCHAR(10)
);


ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_credit_card
FOREIGN KEY (credit_card_id)
REFERENCES credit_card(id)
ON DELETE RESTRICT
ON UPDATE RESTRICT;




-- ****************************** Exercici 2 ******************************


UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id = 'CcU-2938';

SELECT *
FROM credit_card
WHERE id = 'CcU-2938';
 
 
 
 -- ****************************** Exercici 3 ******************************



INSERT INTO credit_card (id, iban, pan, pin, cvv, expiring_date) VALUES ('CcU-9999', NULL , NULL , NULL, NULL, NULL);
SELECT *
FROM credit_card
WHERE id = 'CcU-9999';

INSERT INTO company (id, company_name, phone, email, country, website) VALUES ('b-9999', NULL , NULL , NULL, NULL, NULL);
SELECT *
FROM company
WHERE id = 'b-9999';

INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, timestamp, amount, declined) VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', '9999', '829.999', '-117.999', NULL , '111.11', '0');
SELECT *
FROM transaction
WHERE company_id = 'b-9999';




 -- ****************************** Exercici 4 ******************************


ALTER TABLE credit_card
DROP COLUMN pan;

SELECT *
FROM credit_card;



-- ******************************************************** Nivell 2 *************************************************************

-- ****************************** Exercici 1 ******************************

SELECT *
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';

DELETE
FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';



-- ****************************** Exercici 2 ******************************

-- Serà necessària que creïs una vista anomenada VistaMarketing que contingui la següent informació: 
-- Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
-- Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.


CREATE VIEW VistaMarketing AS
SELECT c.id AS id_companya, c.company_name AS companya, c.phone AS telefon, c.country AS pais, ROUND(AVG(t.amount),2) AS media_vendes
FROM company AS c
JOIN transaction AS t 
ON c.id = t.company_id
WHERE t.declined = 0
GROUP BY id_companya, companya, telefon, pais
ORDER BY media_vendes DESC;
  
SELECT * 
FROM VistaMarketing;



-- ****************************** Exercici 3 ******************************


SELECT * 
FROM VistaMarketing
WHERE pais = 'Germany';





-- ******************************************************** Nivell 3 *************************************************************


-- ****************************** Exercici 1 ******************************

-- modificacions a la taula "credit_card" 

USE transactions;
ALTER TABLE credit_card
CHANGE COLUMN id id VARCHAR(20);

ALTER TABLE credit_card
CHANGE COLUMN iban iban VARCHAR(50);

ALTER TABLE credit_card
CHANGE COLUMN cvv cvv INT;

ALTER TABLE credit_card
CHANGE COLUMN expiring_date expiring_date VARCHAR(20);

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE NULL;

UPDATE credit_card
SET fecha_actual = STR_TO_DATE(expiring_date, '%m/%d/%y');


-- modificacions a la taula "company" 

ALTER TABLE company
DROP COLUMN website;


-- importacio de la taula "user" i de les seves dates + modificacio de l'estructura de la taula

CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100),
	phone VARCHAR(150),
	email VARCHAR(150),
	birth_date VARCHAR(100),
	country VARCHAR(150),
	city VARCHAR(150),
	postal_code VARCHAR(100),
	address VARCHAR(255)    
);

 

ALTER TABLE user
CHANGE COLUMN id id INT;

ALTER TABLE user 
RENAME COLUMN email TO personal_email;

ALTER TABLE user 
RENAME TO data_user;


-- modificacions de la taula "transaction"

ALTER TABLE transaction
CHANGE COLUMN credit_card_id credit_card_id VARCHAR(20);

INSERT INTO data_user (id) VALUES ('9999');

ALTER TABLE transaction
ADD CONSTRAINT fk_transaction_data_user
FOREIGN KEY (user_id) 
REFERENCES data_user(id)
ON DELETE RESTRICT
ON UPDATE RESTRICT;



-- ****************************** Exercici 2 ******************************


CREATE VIEW InformeTecnico AS
SELECT t.id AS "ID de la transacció", d.name AS "Nom de l'usuari/ària", d.surname AS "Cognom de l'usuari/ària", d.country AS "Pais de l'usuari/ària", cc.id AS "ID targeta crèdit", cc.iban AS "IBAN de la targeta de crèdit usada", cc.expiring_date AS "Data de caducitat de la targeta de crèdit usada", c.id AS "ID companya", c.company_name AS "Nom de la companyia de la transacció realitzada", c.country AS "Pais de la companya", t.timestamp AS "Temps de la transacció", t.amount AS "Suma de la transacció", t.declined AS "Transacció rebutjada" 
FROM transaction AS t
JOIN company AS c
ON c.id = t.company_id
JOIN data_user AS d
ON d.id = t.user_id
JOIN credit_card AS cc
ON cc.id = t.credit_card_id
ORDER BY "ID de la transacció" DESC;


SELECT *
FROM InformeTecnico;