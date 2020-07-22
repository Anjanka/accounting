ALTER TABLE account
    ADD COLUMN category text,
    ADD COLUMN account_type text;

UPDATE account
    SET category = '';

update account
   SET account_type = '';

ALTER TABLE account
    ALTER COLUMN category SET NOT NULL,
    ALTER COLUMN account_type SET NOT NULL;