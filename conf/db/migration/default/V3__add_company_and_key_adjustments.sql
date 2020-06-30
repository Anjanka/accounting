create table company (
 id integer NOT NULL PRIMARY KEY,
 name text NOT NULL,
 address text NOT NULL,
 taxNumber text NOT NULL,
 revenueOffice text NOT NULL
);

insert into company values (1, 'test_company', '','','');

alter table accounting_entry
    drop constraint accounting_entry_debit_fkey,
    drop constraint accounting_entry_credit_fkey;

alter table accounting_entry_template
    drop constraint accounting_entry_template_debit_fkey,
    drop constraint accounting_entry_template_credit_fkey;

alter table account
    add column company_id integer;

update account
set company_id = 1;

alter table account
    alter column company_id set not null;

alter table account
    add constraint account_company_fkey foreign key (company_id) references company(id) on delete cascade;

alter table account
    drop constraint account_pkey;

alter table account add primary key (company_id, id);

alter table accounting_entry
    add column company_id integer;

update accounting_entry
set company_id = 1;

alter table accounting_entry
    alter column company_id set not null;

alter table accounting_entry
    add constraint accounting_entry_debit_fkey foreign key (debit, company_id) references account(id, company_id) deferrable initially deferred,
    add constraint accounting_entry_credit_fkey foreign key (credit, company_id) references account(id, company_id) deferrable initially deferred,
    add constraint accounting_entry_company_fkey foreign key (company_id) references company(id) on delete cascade;

alter table accounting_entry
    drop constraint accounting_entry_pkey;

alter table accounting_entry add primary key (company_id, id, accounting_year);

alter table accounting_entry_template
    alter column amount_whole set not null,
    alter column amount_change set not null;

alter table accounting_entry_template
    add column company_id integer;

update accounting_entry_template
set company_id = 1;

alter table accounting_entry_template
    alter column company_id set not null;

alter table accounting_entry_template
    add constraint accounting_entry_template_debit_fkey foreign key (debit, company_id) references account(id, company_id) deferrable initially deferred,
    add constraint accounting_entry_template_credit_fkey foreign key (credit, company_id) references account(id, company_id) deferrable initially deferred,
    add constraint accounting_entry_template_company_fkey foreign key (company_id) references company(id) on delete cascade;

alter table accounting_entry_template
    drop constraint accounting_entry_template_pkey;

alter table accounting_entry_template add primary key (company_id, description);
