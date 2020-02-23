create table account (
 id integer NOT NULL PRIMARY KEY,
 title text NOT NULL
);


create table accounting_entry (
 order_id integer NOT NULL,
 accounting_year integer NOT NULL,

 booking_date date NOT NULL,
 receipt_number text NOT NULL,
 description text NOT NULL,
 credit integer NOT NULL REFERENCES account(id),
 debit integer NOT NULL REFERENCES account(id),
 amount_whole integer NOT NULL,
 amount_change integer NOT NULL,

 PRIMARY KEY (order_id, accounting_year)
);


create table accounting_entry_template (
 description text NOT NULL PRIMARY KEY,
 credit integer NOT NULL REFERENCES account(id),
 debit integer NOT NULL REFERENCES account(id),
 amount_whole integer,
 amount_change integer
);
