-- #############################
-- CREATE Animals
-- Base code used from Exploration - - Implementing CUD operations in your app
-- URL: https://canvas.oregonstate.edu/courses/2017561/pages/exploration-implementing-cud-operations-in-your-app?module_item_id=25645149
-- #############################
DROP PROCEDURE IF EXISTS sp_CreateAnimal;

DELIMITER //
CREATE PROCEDURE sp_CreateAnimal(
    IN p_name VARCHAR(255), 
    IN p_type VARCHAR(255), 
    IN p_dateOfBirth date,
    OUT p_id INT)
BEGIN
    INSERT INTO Animals (name, type, dateOfBirth) 
    VALUES (p_name, p_type, p_dateOfBirth);

    -- Store the ID of the last inserted row
    SELECT LAST_INSERT_ID() into p_id;
    -- Display the ID of the last inserted animal.
    SELECT LAST_INSERT_ID() AS 'new_id';

    -- Example of how to get the ID of the newly created animal:
        -- CALL sp_CreateAnimal('Bessy', 'Cow', '2024-06-09', @new_id);
        -- SELECT @new_id AS 'New Person ID';
END //
DELIMITER ;