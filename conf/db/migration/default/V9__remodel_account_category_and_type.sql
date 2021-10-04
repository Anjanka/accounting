ALTER TABLE account
DROP COLUMN category,
DROP COLUMN account_type;

ALTER TABLE account
    ADD COLUMN category INT,
    ADD COLUMN account_type INT;

UPDATE account
    SET category = 0 ;

UPDATE account
   SET account_type = 0 ;

ALTER TABLE account
    ALTER COLUMN category SET NOT NULL,
    ALTER COLUMN account_type SET NOT NULL;