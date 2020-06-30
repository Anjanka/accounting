ALTER TABLE accounting_entry_template
    DROP CONSTRAINT accounting_entry_template_pkey;

ALTER TABLE accounting_entry_template
    ADD COLUMN id SERIAL PRIMARY KEY;

ALTER TABLE accounting_entry_template
    ADD CONSTRAINT company_id_description_unique UNIQUE (company_id, description);
