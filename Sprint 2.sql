-- ********************************************* Nivell 1 - Exercici 2 ****************************************** --

-- Utilitzant JOIN realitzaràs les següents consultes:

-- Llistat dels països que estan generant vendes

USE transactions;

SELECT DISTINCT c.country AS paisos, ROUND(SUM(t.amount),2) AS total_vendes
FROM company AS c
JOIN transaction AS t 
ON c.id = t.company_id
WHERE declined = 0
GROUP BY c.country
ORDER BY total_vendes DESC;


-- Des de quants països es generen les vendes

SELECT COUNT(DISTINCT c.country) AS compte_paisos_generant_vendes
FROM company AS c
JOIN transaction AS t 
ON c.id = t.company_id
WHERE declined = 0;


-- Identifica la companyia amb la mitjana més gran de vendes -- 

SELECT c.company_name AS companya, ROUND(AVG(t.amount),2) AS media_vendes
FROM company AS c
JOIN transaction AS t 
ON c.id = t.company_id
WHERE declined = 0
GROUP BY companya
ORDER BY media_vendes DESC
LIMIT 1;


-- ********************************************* Nivell 1 - Exercici 3 ******************************************

-- Utilitzant només subconsultes (sense utilitzar JOIN):


-- Mostra totes les transaccions realitzades per empreses d'Alemanya

SELECT  t.id AS id_transaccio, t.credit_card_id AS id_targeta_credit, t.company_id AS id_companya, t.user_id AS id_usuari, t.lat AS latitud, t.longitude AS longitud, t.timestamp AS temps_transaccio, t.amount AS suma, t.declined AS declinat
FROM transaction AS t
WHERE EXISTS (
	SELECT c.id
    FROM company AS c
    WHERE t.company_id = c.id 
    AND c.country = "Germany");


-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions

SELECT c.id, c.company_name AS companya
FROM company AS c
WHERE EXISTS (
	SELECT t.amount
	FROM transaction AS t
	WHERE c.id = t.company_id 
    AND declined = 0 
    AND t.amount > (
		SELECT AVG(t.amount)
		FROM transaction AS t
        )
);


-- Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses

SELECT c.id, c.company_name AS companya
FROM company AS c
WHERE NOT EXISTS (
	SELECT t.company_id
	FROM transaction AS t
	WHERE c.id = t.company_id);



-- ********************************************* Nivell 2 - Exercici 1 ******************************************

-- Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
-- Mostra la data de cada transacció juntament amb el total de les vendes:

SELECT DATE_FORMAT(t.timestamp, '%d-%m-%Y') AS data, ROUND(SUM(t.amount),2) AS suma_total_data
FROM transaction AS t
WHERE declined = 0
GROUP BY data
ORDER BY suma_total_data DESC
LIMIT 5;


-- ********************************************* Nivell 2 - Exercici 2 ******************************************

-- Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà:

SELECT c.country AS pais, ROUND(AVG(t.amount),2) AS media_vendes
FROM transaction AS t
JOIN company AS c 
ON t.company_id = c.id
WHERE t.declined = 0
GROUP BY pais
ORDER BY media_vendes DESC;


-- ********************************************* Nivell 2 - Exercici 3 ******************************************

-- En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". 
-- Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
-- Mostra el llistat aplicant JOIN i subconsultes.

SELECT t.company_id AS id_companya, c.company_name AS companya, c.country AS pais, t.id AS id_transaccio, t.credit_card_id AS id_targeta_credit, t.user_id AS id_usuari, t.lat AS latitud, t.longitude AS longitud, t.timestamp AS temps_transaccio, t.amount AS suma, t.declined AS declinat
FROM transaction AS t
JOIN company AS c 
ON t.company_id = c.id
WHERE t.declined = 0 
AND c.company_name <> "Non Institute"
AND c.country = (
	SELECT DISTINCT c.country
    FROM company AS c
    WHERE c.company_name = "Non Institute")
ORDER BY company_name ASC;


-- Mostra el llistat aplicant solament subconsultes.

SELECT t.company_id AS id_companya, t.id AS id_transaccio, t.credit_card_id AS id_targeta_credit, t.user_id AS id_usuari, t.lat AS latitud, t.longitude AS longitud, t.timestamp AS temps_transaccio, t.amount AS suma, t.declined AS declinat
FROM transaction AS t
WHERE t.declined = 0 
AND EXISTS (
	SELECT c.id
    FROM company AS c
    WHERE t.company_id = c.id 
    AND c.company_name <> "Non Institute"
    AND c.country = (
		SELECT DISTINCT c.country
		FROM company AS c
		WHERE c.company_name = "Non Institute"
        )
);


-- ********************************************* Nivell 3 - Exercici 1 ******************************************

-- Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar transaccions amb un valor comprès entre 350 i 400 euros 
-- i en alguna d'aquestes dates: 29 d'abril del 2015, 20 de juliol del 2018 i 13 de març del 2024.
-- Ordena els resultats de major a menor quantitat.

SELECT c.company_name AS companya, c.phone AS telefon, c.country AS pais, DATE_FORMAT(t.timestamp, '%d-%m-%Y') AS data_transaccio, t.amount AS suma_transaccio
FROM transaction AS t
JOIN company AS c 
ON t.company_id = c.id
WHERE t.amount BETWEEN 350 AND 400 
AND t.declined = 0 
AND t.timestamp IN (
	SELECT t.timestamp
    FROM transaction AS t
    WHERE DATE(t.timestamp) IN ("2015-04-29", "2018-07-20", "2024-03-13") 
    )
ORDER BY suma_transaccio DESC;


-- ********************************************* Nivell 3 - Exercici 2 ******************************************

-- Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, 
-- per la qual cosa et demanen la informació sobre la quantitat de transaccions que realitzen les empreses, 
-- però el departament de recursos humans és exigent i vol un llistat de les empreses on especifiquis si tenen més de 400 transaccions o menys.

SELECT c.company_name, COUNT(t.id) AS total_transaccions, IF(COUNT(t.id)>400, "Si", "No") AS "Mes_de_400_transaccions"
FROM company AS c
JOIN transaction AS t 
ON c.id = t.company_id
GROUP BY c.company_name
ORDER BY total_transaccions DESC;