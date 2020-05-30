drop view if exists facts_consults;
drop view if exists dim_location_client;
drop view if exists dim_client;
drop view if exists dim_date;

--View 1
create view dim_date as
(select date_timestamp, day(date_timestamp) as day, month(date_timestamp) as month, year(date_timestamp) as year
from consultation);

select * from dim_date;

--View 2
create view dim_client as
(select VAT, gender, floor(datediff(now(), birth_date)/365) as age
from client);

select * from dim_client;

--View 3
create view dim_location_client as
(select zip, city
from client);

select * from dim_location_client;

--View 4
create view facts_consults as
(
select client.VAT, c.date_timestamp, client.zip, count(pic.name) as num_procedures, count(p.name) as num_medications, count(cd.ID) as num_diagnostic_codes
from consultation as c left join procedure_in_consultation as pic on c.date_timestamp = pic.date_timestamp and c.VAT_doctor = pic.VAT_doctor
left join prescription as p on c.date_timestamp = p.date_timestamp and c.VAT_doctor = p.VAT_doctor 
left join consultation_diagnostic as cd on c.date_timestamp = cd.date_timestamp and c.VAT_doctor = cd.VAT_doctor
join appointment as a on c.date_timestamp = a.date_timestamp and c.VAT_doctor = a.VAT_doctor
join client on client.VAT = a.VAT_client
group by c.VAT_doctor, c.date_timestamp
);

select * from facts_consults;