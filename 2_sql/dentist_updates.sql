/*1. Change the address of the doctor named Jane Sweettooth, to a different city and street of your choice.*/
update employee inner join doctor on doctor.VAT = employee.VAT
set street = 'Alameda D. Afonso Henriques', city = 'Lisboa' where name = 'Jane Sweettooth';

/*2. Change the salary of all doctors that had more than 100 appointments in 2019. The new salaries should correspond to an increase in
5% from the old values.*/
update employee set salary =1.05*salary
where employee.VAT in( /*select all doctors that had more than 100 appointments in 2019*/
	select d.VAT
	from doctor as d inner join appointment as a on d.VAT=a.VAT_doctor
	where year(a.date_timestamp) = '2019'
	group by a.VAT_doctor 
	having(count(distinct date_timestamp)>100)
	);
	

/*3. Delete the doctor named Jane Sweettooth from the database, removing also all the appointments and all the consultations (including
the associated procedures, diagnosis and prescriptions) in which she
was involved. Notice that if there are procedures/diagnosis that were
only performed/assigned by this doctor, you should remove them also
from the database.*/

/*consultation and appointment, as well as procedure_in_consultation, consultation_diagnostic and prescription
 with this doctor are automatically deleted because of the "on delete cascade" command used in "create table" in all these tables*/
 /*So, we only have to manually delete procedure_ and diagnostic code that are only used by the doctor that is going to be deleted*/
 
/*delete all procedures performed by Jane Sweettooth such that the procedure was NOT performed by anyone who was NOT Jane Sweettooth*/
delete p
from procedure_ p
	join procedure_in_consultation as pic
	on p.name = pic.name
	join doctor as d
	on pic.VAT_doctor = d.VAT
	join employee
	on d.VAT = employee.VAT
where employee.name = 'Jane Sweettooth' and 
not exists(select * from (select * from procedure_) as p_ natural join procedure_in_consultation
where p_.name = p.name and procedure_in_consultation.VAT_doctor <> d.VAT);

/*delete all diagnostic codes assigned to Jane Sweettooth such that the diagnostic code was NOT assigned to anyone who was NOT Jane Sweettooth*/
delete dc
from diagnostic_code dc
	join consultation_diagnostic as cd
	on dc.ID = cd.ID
	join doctor as d
	on cd.VAT_doctor = d.VAT
	join employee
	on d.VAT = employee.VAT
where employee.name = 'Jane Sweettooth' and 
not exists(select * from (select * from diagnostic_code) as cd_ natural join consultation_diagnostic
where cd.ID = cd_.ID and consultation_diagnostic.VAT_doctor <> d.VAT);

/*Finally, delete Jane Sweettooth from the database*/
DELETE employee
from employee
where name = 'Jane Sweettooth';


/*4. Find the diagnosis code corresponding to gingivitis. Create also a new
diagnosis code corresponding to periodontitis. Change the diagnosis
from gingivitis to periodontitis for all clients where, for the same
consultation/diagnosis, a dental charting procedure shows a value
above 4 in terms of the average gap between the teeth and the gums.*/

/*diagnostic code corresponding to gingivitis*/
select ID from diagnostic_code where description = 'Gengivitis';

/*Creation of a new diagnosis code corresponding to periodontitis*/
insert into diagnostic_code values('231050D', 'Peridontitis');


update consultation_diagnostic cd set ID = (select ID from diagnostic_code where description = 'Peridontitis')
where cd.ID = (select ID from diagnostic_code where description = 'Gengivitis')
and exists(
	select pc.VAT from
	procedure_charting as pc
	where cd.VAT_doctor = pc.VAT and cd.date_timestamp = pc.date_timestamp
	group by pc.VAT, pc.date_timestamp
	having avg(measure) > 4);





