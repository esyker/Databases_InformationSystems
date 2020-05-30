
/*Query 1 - List the VAT, name, and phone number(s) for all clients that had
consultations with the doctor named Jane Sweettooth. The list should
be presented according to the alphabetical order for the names.*/
select client.VAT, client.name, phone
from consultation, appointment, client natural left join phone_number_client, doctor, employee
where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and appointment.VAT_client = client.VAT 
	and consultation.VAT_doctor = doctor.VAT and doctor.VAT = employee.VAT and employee.name='Jane Sweettooth'
order by client.name asc;

/*Query 2 - List the name of all trainee doctors with reports associated to an
evaluation score below the value of three, or with a description that
contains the term insufficient. The name should be presented together with the VAT of the trainee, the name for the doctor that
made the evaluation, the evaluation score, and the textual description for the evaluation report. Results should be sorted according to
the evaluation score, in descending order.*/
select t.name as trainee_name, t.VAT as trainee_VAT, p.name as supervisor_name, evaluation, description
from employee t, trainee_doctor, supervision_report, employee p
where t.VAT = trainee_doctor.VAT and supervision_report.VAT = trainee_doctor.VAT and  trainee_doctor.supervisor = p.VAT and (evaluation < 3 or description like '%insufficient%')
order by evaluation desc;

/*Query 3 - List the name, city, and VAT for all clients where the most recent
consultation has the objective part of the SOAP note mentioning the
terms gingivitis or periodontitis*/
select name, city, VAT
from(
/*select most recent consultation of each client*/
select * from consultation natural join appointment as c
group by VAT_client, date_timestamp
having( date_timestamp >=all(select date_timestamp from appointment natural join consultation where c.VAT_client = appointment.VAT_client))
) as most_recent_consultation, client
where most_recent_consultation.VAT_client = client.VAT and (SOAP_O like '%gingivitis%' or SOAP_O like '%periodontitis%');

	
/*Query 4 - List the name, VAT and address (i.e., street, city and zip) of all
clients of the clinic that have had appointments but that never had
a consultation (i.e., clients that never showed to an appointment).*/
select name, VAT, street, city, zip
from client c
where exists( /*client has at least one appointment*/
	select * from appointment
	where c.VAT = appointment.VAT_client
)
and not exists( /*client doesn't have any consultations*/
	select * from consultation natural join appointment
	where c.VAT = appointment.VAT_client
);


/*Query 5 - For each possible diagnosis, presenting the code together with the
description, list the number of distinct medication names that have
been prescribed to treat that condition. Sort the results according
to the number of distinct medication names, in ascending order.*/
select diagnostic_code.ID, diagnostic_code.description, count(distinct prescription.name)
from prescription, diagnostic_code
where prescription.ID = diagnostic_code.ID
group by diagnostic_code.ID
order by count(distinct prescription.name) asc;

/*Query 6 - Present the average number of nurses/assistants, procedures, diagnostic codes, and prescriptions involved in consultations from the
year 2019, respectively for clients belonging to two age groups: less
or equal to 18 years old, and more than 18 years old*/
(select '>18' as age, avg(table_nurse.count) as avg_nurses, avg(table_procedure.count) as avg_procedures, avg(table_diagnostic.count) as avg_diagnostic_codes, avg(table_prescription.count) as avg_prescriptions
from( /*column containing the number of nurses for each consultation, for clients with >18 years and in the year 2019*/
	select count(consultation_assistant.VAT_nurse) as count
	from consultation natural left outer join consultation_assistant, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age > 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_nurse,
	( /*column containing the number of procedures for each consultation, for clients with >18 years and in the year 2019*/
	select count(procedure_in_consultation.name) as count
	from consultation natural left outer join procedure_in_consultation, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age > 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_procedure,
	( /*column containing the number of diagnostics for each consultation, for clients with >18 years and in the year 2019*/
	select count(consultation_diagnostic.ID) as count
	from consultation natural left outer join consultation_diagnostic, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age > 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_diagnostic,
	( /*column containing the prescription of diagnostics for each consultation, for clients with >18 years and in the year 2019*/
	select count(prescription.name) as count
	from consultation natural left outer join prescription, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age > 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_prescription
)
union
(select '<=18' as age, avg(table_nurse.count), avg(table_procedure.count), avg(table_diagnostic.count), avg(table_prescription.count)
from( /*column containing the number of nurses for each consultation, for clients with <=18 years and in the year 2019*/
	select count(consultation_assistant.VAT_nurse) as count
	from consultation natural left outer join consultation_assistant, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age <= 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_nurse,
	( /*column containing the number of procedures for each consultation, for clients with <=18 years and in the year 2019*/
	select count(procedure_in_consultation.name) as count
	from consultation natural left outer join procedure_in_consultation, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age <= 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_procedure,
	( /*column containing the number of diagnostics for each consultation, for clients with <=18 years and in the year 2019*/
	select count(consultation_diagnostic.ID) as count
	from consultation natural left outer join consultation_diagnostic, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age <= 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_diagnostic,
	( /*column containing the prescription of diagnostics for each consultation, for clients with <=18 years and in the year 2019*/
	select count(prescription.name) as count
	from consultation natural left outer join prescription, appointment, client
	where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp and 
	client.VAT = appointment.VAT_client and year(appointment.date_timestamp) = '2019' and client.age <= 18
	group by consultation.VAT_doctor, consultation.date_timestamp
	) as table_prescription
);
	
	
/*Query 7 - For each diagnostic code, present the name of the most common medication used to treat that condition (i.e., the medication name that
more often appears associated to prescriptions for that diagnosis).*/
select ID, name
from prescription p
group by ID, name
having (count(*) >= all(select count(*) from prescription where ID = p.ID group by name));

/*Query 8 - List, alphabetically, the names and labs for the medications that, in
the year 2019, have been used to treat “dental cavities”, but have
not been used to treat any “infectious disease”. You can use the
aforementioned names for searching diagnostic codes in the dataset,
without considering relations (e.g., part-of relations) between diagnostic codes.*/
select name, lab
from prescription p, diagnostic_code
where diagnostic_code.ID = p.ID and diagnostic_code.description = 'Dental Cavities' and year(p.date_timestamp) = '2019' 
and not exists(
	select * from prescription, diagnostic_code where prescription.name = p.name 
	and prescription.lab = p.lab and prescription.ID = diagnostic_code.ID 
	and diagnostic_code.description = 'Infectious Disease' and year(prescription.date_timestamp) = '2019')
order by name asc;

/*Query 9 - List the names and addresses of clients that have never missed an
appointment in 2019 (i.e., the clients that, in the year 2019, have
always appeared in all the consultations scheduled for them).*/
select name, street, city, zip
from client
where VAT not in ( /*select all clients that have missed at least one appointment in 2019*/
	select VAT_client
	from appointment natural left outer join consultation
	where consultation.VAT_doctor is null and year(appointment.date_timestamp) = '2019'
	);
	