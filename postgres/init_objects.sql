create role tr_ibd_esfm nologin;
ALTER ROLE tr_ibd_esfm SET statement_timeout = 10000;

create role tr_ibd_ocn nologin;
ALTER ROLE tr_ibd_ocn SET statement_timeout = 3000;

CREATE TABLE films (
    code        char(5) CONSTRAINT firstkey PRIMARY KEY,
    title       varchar(40) NOT NULL,
    did         integer NOT NULL,
    date_prod   date,
    kind        varchar(10),
    len         interval hour to minute
);

CREATE TABLE distributors (
     did    integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
     name   varchar(40) NOT NULL CHECK (name <> '')
);

insert into films (code, title, did, date_prod, kind, len) values ('tnj', 'Tom and Jerry', 1, '1981-01-01', 'mult', '1 hours 20 minutes');
	
insert into films (code, title, did, date_prod, kind, len) values ('sup', 'Superman', 1, '1991-01-01', 'film', '2 hours 10 minutes');

insert into distributors (did, name) values (1, 'Paramount');
	
insert into distributors (did, name) values (2, '20 Century Fox');

create view films_vw as select * from films;

grant select on films_vw to tr_ibd_esfm;

create view distributors_vw as select * from distributors;

grant select on distributors_vw to tr_ibd_ocn;

CREATE OR REPLACE FUNCTION delay_fn()
RETURNS VOID AS $$
BEGIN
	PERFORM pg_sleep(5);
END;
$$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_timeout_fn()
RETURNS VOID AS $$
BEGIN
	SET statement_timeout = 3000;
END;
$$
LANGUAGE plpgsql;

grant execute on function delay_fn() to tr_ibd_ocn;
grant execute on function delay_fn() to tr_ibd_esfm;

create schema postgrest;
grant usage on schema postgrest to tr_ibd_owner;

create or replace function postgrest.pre_config()
returns void as $$
  select
      set_config('pgrst.db_schemas', 'public', true)
    , set_config('pgrst.jwt_secret', 'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz', true)
    , set_config('pgrst.db_pre_request', 'set_timeout_fn', true)
    , set_config('pgrst.db_anon_role', 'tr_ibd_owner', true)
    , set_config('pgrst.server_timing_enabled', 'true', true);
$$ language sql;
