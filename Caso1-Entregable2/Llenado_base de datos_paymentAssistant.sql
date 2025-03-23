-- Caso 1: Segundo entregable
-- Natalia Orozco Delgado 2024099161
-- Daniel Arce Campos 2024174489

use paymentdb;


-- Para llenar los uusarios primero hacemos las addresses 
INSERT INTO payment_currency (name, acronym, symbol)
VALUES ('Dólar', 'USD', '$'),
       ('Colón', 'CRC', '₡');

INSERT INTO payment_countries (name, language, currencyid) VALUES 
('United States', 'en', 1),  
('Costa Rica', 'es', 2),   
('Puerto Rico', 'es', 1), 
('Panamá', 'es', 1);  
       
INSERT INTO payment_states (name, countryid) VALUES 
('San José', 2),       
('Alajuela', 2),
('California', 1),
('Texas', 1),
('San Juan', 3),
('Ciudad de Panamá', 4);

INSERT INTO payment_cities (name, stateid) VALUES 
('San José', 1),
('Escazú', 1),
('San Ramón', 2),
('Grecia', 2),
('Los Angeles', 3),
('San Francisco', 3),
('Dallas', 4),
('Austin', 4),
('Guaynabo', 5),
('San Miguelito', 6);

INSERT INTO payment_addresses (line1, line2, zipcode, cityid, geoposition) VALUES 
('Avenida Central', 'Calle 5', '10101', 1, ST_GeomFromText('POINT(9.9281 -84.0907)')),
('Calle Los Laureles', 'Frente al Mall San Rafael', '10201', 2, ST_GeomFromText('POINT(9.9186 -84.1407)')),
('Calle Central', 'Frente al Parque Central', '20201', 3, ST_GeomFromText('POINT(10.0880 -84.4706)')),
('Avenida 2', 'Calle 8', '20301', 4, ST_GeomFromText('POINT(10.0689 -84.3146)')),
('123 Main St', 'Apt 4B', '90001', 5, ST_GeomFromText('POINT(34.0522 -118.2437)')),
('456 Elm St', NULL, '94101', 6, ST_GeomFromText('POINT(37.7749 -122.4194)')),
('789 Oak St', NULL, '75001', 7, ST_GeomFromText('POINT(32.7767 -96.7970)')),
('101 Pine St', 'Suite 200', '73301', 8, ST_GeomFromText('POINT(30.2672 -97.7431)')),
('Calle San Patricio', 'Esquina Calle Marginal', '00968', 9, ST_GeomFromText('POINT(18.3575 -66.1110)')),
('Avenida Principal', 'Frente al Supermercado', '0816', 10, ST_GeomFromText('POINT(9.0333 -79.5000)'));


-- Para hacer los usuarios y no hacer exceso de inserts hacemos un procedimiento 
DELIMITER //

CREATE PROCEDURE LlenarDeUsuarios()
BEGIN
    SET @i = 1;
    SET @total_addresses = 0;
    SET @random_address_id = 0;
    SET @random_email = '';
    SET @random_firstname = '';
    SET @random_lastname = '';
    SET @random_birthday = NULL;
    SET @random_password = NULL;

    SELECT COUNT(*) INTO @total_addresses FROM payment_addresses;

    WHILE @i <= 30 DO

        SET @random_email = CONCAT('usuario', @i, '@gmail.com');
        SET @random_firstname = CONCAT('Nombre', @i);
        SET @random_lastname = CONCAT('Apellido', @i);
        SET @random_birthday = DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365 * 30) DAY); 
        SET @random_password = SHA2(CONCAT('Contraseña', @i), 256); 

        INSERT INTO payment_users (email, firstname, lastname, birthday, password)
        VALUES (@random_email, @random_firstname, @random_lastname, @random_birthday, @random_password);

        SET @random_address_id = FLOOR(RAND() * @total_addresses) + 1;

        INSERT INTO payment_useraddress (userid, addressid, useraddressid)
        VALUES (LAST_INSERT_ID(), @random_address_id, @i);  -- acá usamos LAST_INSERT_ID() para tener el id del user que acabamos de meter arriba

        SET @i = @i + 1;
    END WHILE;
END//

DELIMITER ;

CALL LlenarDeUsuarios();

-- Para hacer el registro de pagos ocupamos las subscripciones
INSERT INTO payment_subscriptions (description, logourl) VALUES 
('Suscripción Básica', 'url.png'),  
('Suscripción Premium', 'url.png'),  
('Suscripción Empresarial', 'url.png');

INSERT INTO payment_schedules (name, recurrencytype, endtype, repetitions, enddate) VALUES 
('Plan Mensual', 'Monthly', 'Date', NULL, '2026-12-31 23:59:59'),  
('Plan Anual', 'Annually', 'Date', NULL, '2025-12-31 23:59:59'),  
('Plan Semanal', 'Weekly', 'Date', NULL, '2026-12-31 23:59:59'),  
('Plan Diario', 'Daily', 'Date', NULL, '2025-12-31 23:59:59');

INSERT INTO payment_planprices (amount, recurrencytype, posttime, endate, current, currencyid, subscriptionid) VALUES 
(10000, 1, NOW(), '2025-12-31 23:59:59', 1, 2, 1),  
(20000, 1, NOW(), '2025-12-31 23:59:59', 1, 2, 2),
(30000, 1, NOW(), '2025-12-31 23:59:59', 1, 2, 3),
(20, 1, NOW(), '2025-12-31 23:59:59', 1, 1, 1),
(40, 1, NOW(), '2025-12-31 23:59:59', 1, 1, 2),
(60, 1, NOW(), '2025-12-31 23:59:59', 1, 1, 3);


-- Procedimiento para añadirle planes a los usuarios
DELIMITER //

CREATE PROCEDURE InsertarPlanUsuarios()
BEGIN
    SET @i = 1;
    SET @random_days = 1;
    SET @total_users = 30;

    SELECT COUNT(*) INTO @total_users FROM payment_users;

    WHILE @i <= @total_users DO
        
        SET @random_days = FLOOR(1 + RAND() * 16);

        INSERT INTO payment_planperson (acquisition, enabled, scheduleid, planpricesid, userid, expirationdate) VALUES 
        (NOW(), 1, FLOOR(1 + RAND() * 4), FLOOR(1 + RAND() * 6), @i, DATE_ADD(CURDATE(), INTERVAL @random_days DAY));

        SET @i = @i + 1;
    END WHILE;
END //

DELIMITER ;

CALL InsertarPlanUsuarios();


-- Para tener registros de pagos ocupamos la siguiente información:
INSERT INTO payment_modules (moduleid, name) VALUES 
(1, 'Módulo de Pagos');

INSERT INTO payment_paymentmethods (methodid, name, APIURL, secretkey, `key` , logoiconurl, enabled) VALUES 
(1, 'Transferencia Bancaria', 'apiurl.com', SHA2('secret1', 256), SHA2('key', 256), 'url.png', 1);


-- Para llenar los métodos de pago de cada user usamos un procedimiento
DELIMITER //

CREATE PROCEDURE LlenarAvailableMethods()
BEGIN
    SET @i =1;

    WHILE @i <= 30 DO
        INSERT INTO payment_availablemethods (name, token, exptokendate, maskaccount, userid, methodid) VALUES 
        ('Transferencia Bancaria', SHA2(CONCAT('token', @i), 256), DATE_ADD(CURDATE(), INTERVAL 1 YEAR), CONCAT('**** **** **** ', FLOOR(1000 + RAND() * 9000)), @i, 1);

        SET @i = @i + 1;
    END WHILE;
    
END //

DELIMITER ;

CALL LlenarAvailableMethods();



-- Para llenar los pagos usamos un procedimiento con datos random

DELIMITER //

CREATE PROCEDURE LlenarPaymentPayments()
BEGIN
    SET @i = 1;
    SET @total_users = 30;
    SET @total_availablemethods = 1;
    SET @random_amount = 0;
    SET @random_actualamount = 0;
    SET @random_result = 1;
    SET @random_reference = '';
    SET @random_auth = '';
    SET @random_chargetoken = '';
    SET @random_description = '';
    SET @random_error = '';
    SET @random_checksum = NULL;
    SET @random_userid = 1;

    SELECT COUNT(*) INTO @total_users FROM payment_users;

    WHILE @i <= @total_users DO
        SET @random_amount = FLOOR(1000 + RAND() * 10000);
        SET @random_actualamount = @random_amount;
        SET @random_result = 1;
        SET @random_reference = CONCAT('REF', FLOOR(1000 + RAND() * 9000));  
        SET @random_auth = CONCAT('AUTH', FLOOR(1000 + RAND() * 9000)); 
        SET @random_chargetoken = SHA2(CONCAT('TOKEN', @i), 256); 
        SET @random_description = CONCAT('Pago de suscripción para usuario ', @i);
        SET @random_error = NULL; 
        SET @random_checksum = SHA2(CONCAT('CHECKSUM', @i), 256);
        SET @random_moduleid = 1;  
        SET @random_methodid = 1; 
        SET @random_availablemethodid = @i;
        SET @random_userid = @i;

        INSERT INTO payment_payment (paymentid, amount, actualamount, result, reference, auth, chargetoken, description, error, date, checksum, moduleid, methodid, availablemethodid, userid) VALUES 
        (@i, @random_amount, @random_actualamount, @random_result, @random_reference, @random_auth, @random_chargetoken, @random_description, @random_error, NOW(), @random_checksum, @random_moduleid, @random_methodid, @random_availablemethodid, @random_userid);

        SET @i = @i + 1;
    END WHILE;
END //

DELIMITER ;

CALL LlenarPaymentPayments();


-- Para el registro de logins ocupamos llenar los logs
INSERT INTO payment_logtypes (name, ref1description, ref2description, val1description, val2description, payment_logtypescol) VALUES 
('Login', 'ID user', 'ID sesión', 'Intentos', 'Resultado', 'login'),
('Logout', 'ID user', 'ID sesión', 'Duracion', 'Resultado', 'logout'),
('Error', 'Código de error', 'ID módulo', 'Mensaje de error', 'Severidad', 'error'),
('Transacción', 'Transaction ID', 'ID user', 'Monto', 'Estatus', 'transacción');
    
INSERT INTO payment_logsources (logsourcesid) VALUES 
(1),  -- app
(2);  -- Web
    
INSERT INTO payment_logseverity (name) VALUES 
('Información'),
('Advertencia'),
('Error');
    
    

-- Procedimiento para llenarlos con random    
DELIMITER //

CREATE PROCEDURE LlenarLogs()
BEGIN
    SET @i = 0;
    SET @user_count = 30;
    SET @random_user_id = 1;

    SELECT COUNT(*) INTO @user_count FROM payment_users;

    WHILE @i < 100 DO

        SET @random_user_id = FLOOR(1 + RAND() * @user_count);
        SELECT CONCAT(firstname, ' ', lastname) INTO @random_user_name
        FROM payment_users
        WHERE userid = @random_user_id;


        INSERT INTO payment_logs (description, posttime, computer, username, trace, referenceid1, referenceid2, value1, value2, checksum, logtypesid, 
            logsourcesid, logseverityid)
        VALUES (@random_user_name, NOW() - INTERVAL FLOOR(RAND() * 365) DAY, 'Computadora', @random_user_name, 'Trace', NULL, NULL, NULL, NULL, SHA2(CONCAT(@random_user_name, NOW()), 256), 1, 1, 1);

	
        SET @i = @i + 1;
    END WHILE;
END //

DELIMITER ;

CALL LlenarLogs();

-- Iniciamos con los registros de IA

DELIMITER //

CREATE PROCEDURE LlenarDatosAleatorios()
BEGIN
    SET @i = 0;
    SET @total_users = 30;
    SET @random_userid = 1;
    SET @random_keyword = '';
    SET @random_feedback = '';
    SET @random_timestamp = NULL;

    SELECT COUNT(*) INTO @total_users FROM payment_users;

    WHILE @i < 35 DO
	
        SELECT ELT(FLOOR(1 + RAND() * 5), 'transferir dinero', 'comprobante de pago', 'chequear balance de cuenta', 'ver transacciones', 'actualizar perfil') 
        INTO @random_keyword;

        SELECT ELT(FLOOR(1 + RAND() * 5), 'fallo en la interpretación', 'alucinación detectada', 'contexto incorrecto', 'timeout', 'input inválido') 
        INTO @random_feedback;

        SET @random_userid = FLOOR(1 + RAND() * @total_users);

        SET @random_timestamp = NOW() - INTERVAL FLOOR(RAND() * 30) DAY;

        INSERT INTO payment_detectedcommands (keywords, timestamp)
        VALUES (@random_keyword, @random_timestamp);

        INSERT INTO payment_humanAIinteractions (interactiontype, timestamp, input, output, feedback, userid, detectedcommandsid)
        VALUES ('Comando por voz', @random_timestamp, 1, 0, @random_feedback, @random_userid, LAST_INSERT_ID());

        SET @i = @i + 1;
    END WHILE;
END //

DELIMITER ;

CALL  LlenarDatosAleatorios();

-- Con esto ya tenemos los datos necesarios para realizas las consultas del caso.
