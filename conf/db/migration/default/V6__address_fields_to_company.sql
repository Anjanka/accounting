ALTER TABLE company
    ADD COLUMN postal_code text,
    ADD COLUMN city text,
    ADD COLUMN country text;

UPDATE company
    SET postal_code = '';

UPDATE company
    SET city = '';

UPDATE company
    SET country = '';

ALTER TABLE company
    ALTER COLUMN postal_code SET NOT NULL,
    ALTER COLUMN city SET NOT NULL,
    ALTER COLUMN country SET NOT NULL;


