-- 4.1 listar todos los usuarios de la plataforma que esten activos con su nombre completo, email, país de procedencia, y el total de cuánto han pagado en subscripciones desde el 2024 hasta el día de hoy, dicho monto debe ser en colones 
SELECT -- (20+ registros)
    CONCAT(payment_users.firstname , ' ', payment_users.lastname) AS nombre_completo,
    payment_users.email,
    payment_countries.name AS pais,
    SUM(payment_payment.amount) AS total_pagado_crc
FROM payment_users
    INNER JOIN payment_useraddress ON payment_users.userid = payment_useraddress.userid
    INNER JOIN payment_addresses ON payment_useraddress.addressid = payment_addresses.addressid
    INNER JOIN payment_cities ON payment_addresses.cityid = payment_cities.cityid
    INNER JOIN payment_states ON payment_cities.stateid = payment_states.stateid
    INNER JOIN payment_countries ON payment_states.countryid = payment_countries.countryid
    INNER JOIN payment_planperson ON payment_users.userid = payment_planperson.userid
    INNER JOIN payment_payment ON payment_users.userid = payment_payment.userid
WHERE 
    payment_planperson.enabled = 1 
    AND payment_payment.date >= '2024-01-01'
GROUP BY 
    payment_users.userid, payment_users.firstname, payment_users.lastname, payment_users.email, payment_countries.name 
ORDER BY 
    total_pagado_crc DESC;
    
    
    
-- 4.2 listar todas las personas con su nombre completo e email, los cuales le queden menos de 15 días para tener que volver a pagar una nueva subscripción 
SELECT -- (13+ registros)
    CONCAT(payment_users.firstname, ' ', payment_users.lastname) AS nombre_completo,
    payment_users.email,
    DATEDIFF(payment_planperson.expirationdate, CURDATE()) AS dias_restantes
FROM payment_users
INNER JOIN payment_planperson ON payment_users.userid = payment_planperson.userid
WHERE 
    payment_planperson.enabled = 1 
    AND DATEDIFF(payment_planperson.expirationdate, CURDATE()) < 15 
ORDER BY 
    dias_restantes ASC;
    
    
-- 4.3 un ranking del top 15 de usuarios que más uso le dan a la aplicación y el top 15 que menos uso le dan a la aplicación (15 y 15 registros)
SELECT -- (15 registros)
    payment_users.userid, 
    CONCAT(payment_users.firstname, ' ', payment_users.lastname) AS fullname, 
    COUNT(payment_logs.logsid) AS login_count
FROM payment_logs 
INNER JOIN payment_users ON payment_logs.username = CONCAT(payment_users.firstname, ' ', payment_users.lastname)
WHERE 
    payment_logs.logtypesid = (SELECT logtypesid FROM payment_logtypes WHERE name = 'Login')
GROUP BY 
    payment_users.userid, payment_users.firstname, payment_users.lastname
ORDER BY 
    login_count DESC
LIMIT 15;

SELECT  -- (15 registros)
    payment_users.userid, 
    CONCAT(payment_users.firstname, ' ', payment_users.lastname) AS fullname, 
    COUNT(payment_logs.logsid) AS login_count
FROM 
    payment_logs 
INNER JOIN payment_users ON payment_logs.username = CONCAT(payment_users.firstname, ' ', payment_users.lastname)
WHERE 
    payment_logs.logtypesid = (SELECT logtypesid FROM payment_logtypes WHERE name = 'Login')
GROUP BY 
    payment_users.userid, payment_users.firstname, payment_users.lastname
ORDER BY 
    login_count ASC
LIMIT 15;  



-- 4.4 determinar cuáles son los análisis donde más está fallando la AI, encontrar los casos, situaciones, interpretaciones, halucinaciones o errores donde el usuario está teniendo más problemas en hacer que la AI determine correctamente lo que se desea hacer, rankeando cada problema de mayor a menor cantidad de ocurrencias entre un rango de fechas 
SELECT -- (30+ registros)
    payment_humanAIinteractions.feedback AS tipo_error, 
    COUNT(*) AS ocurrencias
FROM payment_humanAIinteractions 
WHERE 
    payment_humanAIinteractions.timestamp BETWEEN NOW() - INTERVAL 30 DAY AND NOW() 
GROUP BY 
    payment_humanAIinteractions.feedback 
ORDER BY 
    ocurrencias DESC;