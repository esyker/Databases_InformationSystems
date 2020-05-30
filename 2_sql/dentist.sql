drop table if exists procedure_radiology;
drop table if exists procedure_charting;
drop table if exists teeth;
drop table if exists procedure_in_consultation;
drop table if exists procedure_;
drop table if exists prescription;
drop table if exists medication;
drop table if exists consultation_diagnostic;
drop table if exists diagnostic_code_relation;
drop table if exists diagnostic_code;
drop table if exists consultation_assistant;
drop table if exists consultation;
drop table if exists appointment;
drop table if exists supervision_report;
drop table if exists trainee_doctor;
drop table if exists permanent_doctor;
drop table if exists phone_number_client;
drop table if exists client;
drop table if exists nurse;
drop table if exists doctor;
drop table if exists doctor;
drop table if exists receptionist;
drop table if exists phone_number_employee;
drop table if exists employee;

create table employee(
	VAT  varchar(20) not null,
	name  varchar(255) not null,
	birth_date date,
	street  varchar(255),
	city  varchar(255),
	zip varchar(8),
	IBAN char(25) not null,
	salary numeric(20,2),
	unique(IBAN),
	check(salary >= 0),
	primary key(VAT)
);
--IC: All employees are either receptionists, nurses or doctors

create table phone_number_employee(
	VAT varchar(20) not null,
	phone varchar(20),
	primary key(VAT, phone),
	foreign key(VAT)
		references employee(VAT)
		on delete cascade
		on update cascade
);

create table receptionist(
	VAT varchar(20) not null,
	primary key(VAT),
	foreign key(VAT) 
		references employee(VAT)
		on delete cascade
		on update cascade
	
);

create table doctor(
	VAT varchar(20) not null,
	specialization varchar(255),
	biography varchar(8000),
	email varchar(255) not null,
	unique(email),
	primary key(VAT),
	foreign key(VAT) 
		references employee(VAT)
		on delete cascade
		on update cascade
);
--IC: All doctors are either trainees or permanent


create table nurse(
	VAT varchar(20) not null,
	primary key(VAT),
	foreign key(VAT)
		references employee(VAT)
		on delete cascade
		on update cascade
	
);

create table client(
	VAT varchar(20) not null,
	name varchar(255) not null,
	birth_date date not null,
	street varchar(255),
	city varchar(255),
	zip varchar(8),
	gender varchar(20),
	age integer not null,
	primary key(VAT),
	check(age>0),
	check(gender in ('Male', 'Female'))
);
--IC: Age is derived from the birth date

create table phone_number_client(
	VAT varchar(20) not null,
	phone varchar(20),
	primary key(VAT, phone),
	foreign key(VAT)
		references client(VAT)
		on delete cascade
		on update cascade
);

create table permanent_doctor(
	VAT varchar(20) not null,
	years integer,
	primary key(VAT),
	foreign key(VAT)
		references doctor(VAT)
		on delete cascade
		on update cascade
);


create table trainee_doctor(
	VAT varchar(20) not null,
	supervisor varchar(20) not null,
	primary key(VAT),
	foreign key(VAT)
		references doctor(VAT)
		on delete cascade
		on update cascade,
	foreign key(supervisor)
		references permanent_doctor(VAT)
		on delete cascade
		on update cascade
);

create table supervision_report(
	VAT varchar(20) not null,
	date_timestamp datetime not null,
	description varchar(8000),
	evaluation integer not null,
	check(evaluation >= 1 and evaluation <= 5),
	primary key(VAT, date_timestamp),
	foreign key(VAT)
		references trainee_doctor(VAT)
		on delete cascade
		on update cascade
) ENGINE=MyISAM;

create table appointment(
	VAT_doctor varchar(20) not null,
	date_timestamp datetime not null,
	description varchar(8000),
	VAT_client varchar(20) not null,
	primary key(VAT_doctor, date_timestamp),
	foreign key(VAT_doctor)
		references doctor(VAT)
		on delete cascade
		on update cascade,
	foreign key(VAT_client)
		references client(VAT)
		on delete cascade
		on update cascade
);

create table consultation(
	VAT_doctor varchar(20) not null,
	date_timestamp datetime not null,
	SOAP_S varchar(8000),
	SOAP_O varchar(8000),
	SOAP_A varchar(8000),
	SOAP_P varchar(8000),
	primary key(VAT_doctor, date_timestamp),
	foreign key(VAT_doctor, date_timestamp)
		references appointment(VAT_doctor, date_timestamp)
		on delete cascade
		on update cascade
);
--IC: Consultations are always assigned to at least one assistant nurse

create table consultation_assistant(
	VAT_doctor varchar(20) not null,
	date_timestamp datetime not null,
	VAT_nurse varchar(20) not null,
	primary key(VAT_doctor, date_timestamp, VAT_nurse),
	foreign key(VAT_doctor, date_timestamp)
		references consultation(VAT_doctor, date_timestamp)
		on delete cascade
		on update cascade,
	foreign key(VAT_nurse)
		references nurse(VAT)
		on delete cascade
		on update cascade
);

create table diagnostic_code(
	ID varchar(20) not null,
	description varchar(255),
	primary key(ID)

);

create table diagnostic_code_relation(
	ID1 varchar(20) not null,
	ID2 varchar(20) not null,
	type varchar(255),
	primary key(ID1, ID2),
	foreign key(ID1)
		references diagnostic_code(ID)
		on delete cascade
		on update cascade,
	foreign key(ID2)
		references diagnostic_code(ID)
		on delete cascade
		on update cascade
);

create table consultation_diagnostic(
	VAT_doctor varchar(20) not null,
	date_timestamp datetime not null,
	ID varchar(20) not null,
	primary key(VAT_doctor, date_timestamp, ID),
	foreign key(VAT_doctor, date_timestamp)
		references consultation(VAT_doctor, date_timestamp)
		on delete cascade
		on update cascade,
	foreign key(ID)
		references diagnostic_code(ID)
		on delete cascade
		on update cascade
);

create table medication(
	name varchar(255) not null,
	lab varchar(255) not null,
	primary key(name, lab)

);

create table prescription(
	name varchar(255) not null,
	lab varchar(255) not null,
	VAT_doctor varchar(20) not null,
	date_timestamp datetime not null,
	ID varchar(20) not null,
	dosage varchar(20),
	description varchar(255),
	primary key(name, lab, VAT_doctor, date_timestamp, ID),
	foreign key(VAT_doctor, date_timestamp, ID)
		references consultation_diagnostic(VAT_doctor, date_timestamp, ID)
		on delete cascade
		on update cascade,
	foreign key(name, lab)
		references medication(name, lab)
		on delete cascade
		on update cascade

);

create table procedure_(
	name varchar(255) not null,
	type varchar(255),
	primary key(name)

);

create table procedure_in_consultation(
	name varchar(255) not null,
	VAT_doctor varchar(20) not null,
	date_timestamp datetime not null,
	description varchar(255),
	primary key(name, VAT_doctor, date_timestamp),
	foreign key(name)
		references procedure_(name)
		on delete cascade
		on update cascade,
	foreign key(VAT_doctor, date_timestamp)
		references consultation(VAT_doctor, date_timestamp)
		on delete cascade
		on update cascade
);

create table procedure_radiology(
	name varchar(255) not null,
	file varchar(255) not null,
	VAT_doctor varchar(20) not null,
	date_timestamp datetime not null,
	primary key(name, file, VAT_doctor, date_timestamp),
	foreign key(name, VAT_doctor, date_timestamp)
		references procedure_in_consultation(name, VAT_doctor, date_timestamp)
		on delete cascade
		on update cascade
);

create table teeth(
	quadrant integer not null,
	number_ integer not null,
	name char(255),
	primary key(quadrant, number_)
);

create table procedure_charting(
	name varchar(255) not null,
	VAT varchar(20) not null,
	date_timestamp datetime not null,
	quadrant integer not null,
	number_ integer not null,
	description char(255),
	measure float(24) not null,
	primary key(name, VAT, date_timestamp, quadrant, number_),
	foreign key(name, VAT, date_timestamp)
		references procedure_in_consultation(name, VAT_doctor, date_timestamp)
		on delete cascade
		on update cascade,
	foreign key(quadrant, number_)
		references teeth(quadrant, number_)
		on delete cascade
		on update cascade
);



insert into employee values ('111111111', 'Jane Sweettooth', '1980-10-01', 'Wessex Street', 'Centregoldlon', '8283-128', 'PT5091039402930192019464817', 8000.00);
insert into employee values ('222222222', 'Wilbur Wonka', '1964-01-17', 'Devon Street', 'Dergrandfney', '3829-192', 'PT5002830291029302910293029', 9000.00);
insert into employee values ('333333333', 'Sally Fernandez', '1987-03-29', 'Hanson Street', 'Saint Marys City', '1023-134', 'PT5015465135549871563214563', 5000.00);
insert into employee values ('444444444', 'Joseph Mcdonald', '1982-11-19', 'Whitley Street', 'Orem', '3483-461', 'PT5065478213654785236145963', 4500.00);
insert into employee values ('555555555', 'Samuel Stevenson', '1975-12-12', 'Charlotte Street', 'Compton', '1345-422', 'PT5023014520369874520145698', 3000.00);
insert into employee values ('666666666', 'Otis Burns', '1985-05-11', 'Eden Street', 'Ashtabula', '1345-134', 'PT5012023655410023654789632', 3000.00);
insert into employee values ('777777777', 'Roxanne Davidson', '1990-02-28', 'Tweed Street', 'Americus', '5432-523', 'PT5074532102301489602365041', 1500.00);

insert into phone_number_employee values ('111111111','968192849');
insert into phone_number_employee values ('111111111','927123781');
insert into phone_number_employee values ('222222222','961029301');
insert into phone_number_employee values ('333333333','912039139');
insert into phone_number_employee values ('444444444','936541256');
insert into phone_number_employee values ('555555555','968846514');
insert into phone_number_employee values ('666666666','915455145');
insert into phone_number_employee values ('777777777','965521545');

insert into receptionist values ('777777777');

insert into doctor values ('111111111', 'Pediatric dentistry', 'xxxxxxxxxxxxxxx' , 'jane.sweettooth@hotmail.com');
insert into doctor values ('222222222', 'Endodontics', 'xxxxxxxxxxxxxxx' , 'wilbur.wonka@yahoo.com');
insert into doctor values ('333333333', 'Oral and maxillofacial surgery', 'xxxxxxxxxxxxxx' ,'sallyfernandez87@gmail.com');
insert into doctor values ('444444444', 'Anesthesiology', 'xxxxxxxxxxxxxx', 'thejoemcdonald@gmail.com');

insert into nurse values('555555555');
insert into nurse values('666666666');

insert into client values('888888888','George Michael', '1963-06-25','Brooklyn Street','Winslow','9123-123','Male', 56);
insert into client values('999999999','David Bowie', '1947-01-08','Broomhill Street','Hastings','2245-442','Male', 72);
insert into client values('101010101','Paul McCartney', '1942-06-18','Lower Street','McAllen','5346-134','Male', 77);
insert into client values('110110110','Bryan Adams', '1959-11-05','Edmund Street','Rolla','3542-133','Male', 60);
insert into client values('121212121','Celine Dion', '1968-03-30','Third Street','Joplin','3455-245','Female', 51);
insert into client values('131313131','Marvin Gaye', '1939-04-02','St Peters Street','Fillmore','5743-532','Male', 80);
insert into client values('141414141','Bonnie Tyler', '1951-06-08','Avondale Street','Bloomington','3456-245','Female', 68);
insert into client values('151515151','Stevie Wonder', '1950-05-13','Old Mill Street','Lynchburg','4562-623','Male', 69);
insert into client values('161616161','John Lennon', '1940-10-09','Homefield Street','Northampton','4653-645','Male', 79);
insert into client values('171717171','Freddie Mercury', '1946-09-05','Rosewood Street','Towson','3243-453','Male', 73);
insert into client values('181818181','Elton John', '1947-03-25','Smith Street','Tallahassee','1246-654','Male', 72);
insert into client values('191919191','Mick Jagger', '1943-05-26','Warren Street','San Marino','5674-765','Male', 76);
insert into client values('202020202','Morgan Bush', '2001-05-26','Moorside Street','Northampton','3442-765','Male', 18);
insert into client values('212121212','Abraham Walters', '2001-05-26','Teal Street','Monett','3432-123','Male', 18);
insert into client values('220220220','Sara Wolf', '2001-05-26','Bouverie Street','Baton Rouge','4328-134','Female', 18);
insert into client values('232323232','Felicity Morgan', '2005-05-26','Newport Street','Thaxted','5234-765','Female', 14);
insert into client values('242424242','Sabrina Adams', '2004-05-26','Ashleigh Street','Beckenham','1344-765','Female', 15);
insert into client values('252525252','Bruce Reese', '2003-05-26','Addison Street','Westfield','4328-531','Male', 16);
insert into client values('262626262','Harriet Daniels', '2002-05-26','Ingles Street','Needles','4134-765','Female', 17);
insert into client values('272727272','May Torres', '2002-05-26','Moseley Street','Norris','5325-765','Female', 17);
insert into client values('282828282','Shane Reyes', '2010-05-26','Belward Street','Uxbridge','4134-123','Male', 9);
insert into client values('292929292','Evangeline Chapman', '2015-05-26','Moorside Street','Silssaltquay','1343-132','Female', 4);

insert into phone_number_client values ('888888888','964549625');
insert into phone_number_client values ('888888888','918739182');
insert into phone_number_client values ('999999999','918294719');
insert into phone_number_client values ('101010101','930192843');
insert into phone_number_client values ('110110110','961381324');
insert into phone_number_client values ('110110110','961238100');
insert into phone_number_client values ('121212121','962341569');
insert into phone_number_client values ('131313131','915432599');
insert into phone_number_client values ('141414141','935432156');
insert into phone_number_client values ('151515151','914565431');
insert into phone_number_client values ('161616161','961249828');
insert into phone_number_client values ('171717171','931345657');
insert into phone_number_client values ('181818181','911324551');
insert into phone_number_client values ('181818181','981239791');
insert into phone_number_client values ('191919191','921435344');
insert into phone_number_client values ('212121212','901238192');
insert into phone_number_client values ('220220220','971237814');
insert into phone_number_client values ('232323232','941273882');
insert into phone_number_client values ('262626262','931828315');
insert into phone_number_client values ('272727272','961238128');
insert into phone_number_client values ('282828282','928123812');

insert into permanent_doctor values('111111111', 12);
insert into permanent_doctor values('222222222', 20);

insert into trainee_doctor values('333333333','222222222');
insert into trainee_doctor values('444444444','111111111');

insert into supervision_report values('333333333', '2017-01-01 18:00:00', 'xxxxxxxxx', 2);
insert into supervision_report values('333333333', '2018-01-01 18:00:00', 'xxxxxxxxxx', 3);
insert into supervision_report values('333333333', '2019-01-01 18:00:00', 'xxxxxx insufficient xxxxx', 4);
insert into supervision_report values('444444444', '2017-02-02 18:00:00', 'xxxxxxxxx', 4);
insert into supervision_report values('444444444', '2018-02-02 18:00:00', 'xxxxx insufficient xxxxx', 3);
insert into supervision_report values('444444444', '2019-02-1-02 18:00:00', 'xxxxxxxxxxx', 2);

insert into appointment values('333333333', '2019-01-01 10:00:00', 'xxxxxxx', '888888888');
insert into appointment values('222222222', '2019-01-02 10:00:00', 'xxxxxxx', '888888888');
insert into appointment values('111111111', '2019-01-01 10:00:00', 'xxxxxxx', '999999999');
insert into appointment values('444444444', '2019-01-02 10:00:00', 'xxxxxxx', '999999999');
insert into appointment values('333333333', '2019-01-01 14:00:00', 'xxxxxxx', '101010101');
insert into appointment values('333333333', '2019-01-02 10:00:00', 'xxxxxxx', '101010101');
insert into appointment values('111111111', '2019-01-01 13:00:00', 'xxxxxxx', '110110110');
insert into appointment values('111111111', '2019-01-01 17:00:00', 'xxxxxxx', '110110110');
insert into appointment values('444444444', '2019-01-01 13:00:00', 'xxxxxxx', '121212121');
insert into appointment values('111111111', '2019-01-02 09:00:00', 'xxxxxxx', '121212121');
insert into appointment values('444444444', '2019-01-02 11:00:00', 'xxxxxxx', '131313131');
insert into appointment values('111111111', '2019-01-02 12:00:00', 'xxxxxxx', '131313131');
insert into appointment values('222222222', '2019-01-01 13:00:00', 'xxxxxxx', '141414141');
insert into appointment values('111111111', '2019-01-02 16:00:00', 'xxxxxxx', '141414141');
insert into appointment values('222222222', '2019-01-01 15:00:00', 'xxxxxxx', '151515151');
insert into appointment values('333333333', '2019-01-02 14:00:00', 'xxxxxxx', '151515151');
insert into appointment values('111111111', '2019-01-03 10:00:00', 'xxxxxxx', '161616161');
insert into appointment values('444444444', '2019-01-02 12:00:00', 'xxxxxxx', '161616161');
insert into appointment values('111111111', '2019-01-03 13:00:00', 'xxxxxxx', '171717171');
insert into appointment values('111111111', '2019-01-03 17:00:00', 'xxxxxxx', '171717171');
insert into appointment values('333333333', '2019-01-03 10:00:00', 'xxxxxxx', '181818181');
insert into appointment values('222222222', '2019-01-02 11:00:00', 'xxxxxxx', '181818181');
insert into appointment values('444444444', '2019-01-02 17:00:00', 'xxxxxxx', '191919191');
insert into appointment values('222222222', '2019-01-02 13:00:00', 'xxxxxxx', '191919191');
insert into appointment values('111111111', '2018-02-01 10:00:00', 'xxxxxxx', '202020202');
insert into appointment values('333333333', '2019-02-02 10:00:00', 'xxxxxxx', '202020202');
insert into appointment values('222222222', '2019-02-01 10:00:00', 'xxxxxxx', '202020202');
insert into appointment values('444444444', '2019-02-02 10:00:00', 'xxxxxxx', '212121212');
insert into appointment values('222222222', '2019-02-01 14:00:00', 'xxxxxxx', '212121212');
insert into appointment values('222222222', '2019-02-01 13:00:00', 'xxxxxxx', '212121212');
insert into appointment values('333333333', '2019-02-01 17:00:00', 'xxxxxxx', '232323232');
insert into appointment values('111111111', '2019-02-01 13:00:00', 'xxxxxxx', '232323232');
insert into appointment values('444444444', '2019-02-02 09:00:00', 'xxxxxxx', '242424242');
insert into appointment values('111111111', '2019-02-12 13:00:00', 'xxxxxxx', '242424242');
insert into appointment values('333333333', '2019-02-02 16:00:00', 'xxxxxxx', '252525252');
insert into appointment values('444444444', '2018-02-01 15:00:00', 'xxxxxxx', '252525252');
insert into appointment values('111111111', '2019-02-02 14:00:00', 'xxxxxxx', '262626262');
insert into appointment values('333333333', '2019-02-03 10:00:00', 'xxxxxxx', '262626262');
insert into appointment values('444444444', '2019-02-03 13:00:00', 'xxxxxxx', '272727272');
insert into appointment values('111111111', '2019-02-03 17:00:00', 'xxxxxxx', '272727272');
insert into appointment values('222222222', '2018-02-02 11:00:00', 'xxxxxxx', '282828282');
insert into appointment values('444444444', '2019-02-02 17:00:00', 'xxxxxxx', '292929292');
insert into appointment values('111111111', '2019-02-02 13:00:00', 'xxxxxxx', '292929292');


insert into consultation values('333333333', '2019-01-01 10:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('222222222', '2019-01-02 10:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-01-01 10:00:00', 'xxxxxxx','xxxx gingivitis xxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2019-01-02 10:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('333333333', '2019-01-01 14:00:00', 'xxxxxxx','xxx gingivitis xxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-01-01 13:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2019-01-01 13:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-01-02 09:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2019-01-02 11:00:00', 'xxxxxxx','xx gingivitis xxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-01-02 12:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-01-02 16:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('222222222', '2019-01-01 15:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('333333333', '2019-01-02 14:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-01-03 10:00:00', 'xxxxxxx','xxx gingivitis xxxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2019-01-02 12:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-01-03 17:00:00', 'xxxxxxx','xxxx periodontitis xxx','xxxxxxx','xxxxxxx');
insert into consultation values('333333333', '2019-01-03 10:00:00', 'xxxxxxx','xxxx gingivitis xxx','xxxxxxx','xxxxxxx');
insert into consultation values('222222222', '2019-01-02 11:00:00', 'xxxxxxx','xxxx gingivitis xxx','xxxxxxx','xxxxxxx');
insert into consultation values('222222222', '2019-01-02 13:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2018-02-01 10:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('333333333', '2019-02-02 10:00:00', 'xxxxxxx','xx periodontitis xxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('222222222', '2019-02-01 10:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2019-02-02 10:00:00', 'xxxxxxx','xxx gingivitis  periodontitis xxx','xxxxxxx','xxxxxxx');
insert into consultation values('222222222', '2019-02-01 14:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('222222222', '2019-02-01 13:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('333333333', '2019-02-01 17:00:00', 'xxxxxxx','xxxxxx periodontitis x','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-02-01 13:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2019-02-02 09:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-02-12 13:00:00', 'xxxxxxx','xxx gingivitis xxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2018-02-01 15:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('444444444', '2019-02-03 13:00:00', 'xxxxxxx','xxxxx gingivitis xx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-02-03 17:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');
insert into consultation values('111111111', '2019-02-02 13:00:00', 'xxxxxxx','xxxxxxx','xxxxxxx','xxxxxxx');

insert into consultation_assistant values('333333333', '2019-01-01 10:00:00', '555555555');
insert into consultation_assistant values('333333333', '2019-01-01 10:00:00', '666666666');
insert into consultation_assistant values('222222222', '2019-01-02 10:00:00', '666666666');
insert into consultation_assistant values('111111111', '2019-01-01 10:00:00', '555555555');
insert into consultation_assistant values('444444444', '2019-01-02 10:00:00', '666666666');
insert into consultation_assistant values('333333333', '2019-01-01 14:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-01-01 13:00:00', '666666666');
insert into consultation_assistant values('444444444', '2019-01-01 13:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-01-02 09:00:00', '666666666');
insert into consultation_assistant values('444444444', '2019-01-02 11:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-01-02 12:00:00', '666666666');
insert into consultation_assistant values('111111111', '2019-01-02 16:00:00', '555555555');
insert into consultation_assistant values('222222222', '2019-01-01 15:00:00', '666666666');
insert into consultation_assistant values('333333333', '2019-01-02 14:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-01-03 10:00:00', '666666666');
insert into consultation_assistant values('444444444', '2019-01-02 12:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-01-03 17:00:00', '666666666');
insert into consultation_assistant values('333333333', '2019-01-03 10:00:00', '555555555');
insert into consultation_assistant values('222222222', '2019-01-02 11:00:00', '666666666');
insert into consultation_assistant values('222222222', '2019-01-02 13:00:00', '555555555');
insert into consultation_assistant values('111111111', '2018-02-01 10:00:00', '666666666');
insert into consultation_assistant values('333333333', '2019-02-02 10:00:00', '666666666');
insert into consultation_assistant values('222222222', '2019-02-01 10:00:00', '555555555');
insert into consultation_assistant values('444444444', '2019-02-02 10:00:00', '666666666');
insert into consultation_assistant values('222222222', '2019-02-01 14:00:00', '555555555');
insert into consultation_assistant values('222222222', '2019-02-01 13:00:00', '555555555');
insert into consultation_assistant values('333333333', '2019-02-01 17:00:00', '666666666');
insert into consultation_assistant values('333333333', '2019-02-01 17:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-02-01 13:00:00', '555555555');
insert into consultation_assistant values('444444444', '2019-02-02 09:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-02-12 13:00:00', '666666666');
insert into consultation_assistant values('444444444', '2018-02-01 15:00:00', '555555555');
insert into consultation_assistant values('444444444', '2019-02-03 13:00:00', '666666666');
insert into consultation_assistant values('444444444', '2019-02-03 13:00:00', '555555555');
insert into consultation_assistant values('111111111', '2019-02-03 17:00:00', '666666666');
insert into consultation_assistant values('111111111', '2019-02-02 13:00:00', '666666666');



insert into diagnostic_code values('118065D', 'Dental Cavities');
insert into diagnostic_code values('101050D', 'Bacterial Oral Infection');
insert into diagnostic_code values('111975D', 'Disorder of Hard Tissues of Tooth');
insert into diagnostic_code values('140880D', 'Infectious Disease');
insert into diagnostic_code values('135048D', 'Sensitive Dentin');
insert into diagnostic_code values('138192D', 'Gengivitis');

insert into diagnostic_code_relation values('140880D', '101050D', 'Is a');
insert into diagnostic_code_relation values('118065D', '101050D', 'Is a');
insert into diagnostic_code_relation values('118065D', '111975D', 'Is a');
insert into diagnostic_code_relation values('135048D', '111975D', 'Is a');

insert into consultation_diagnostic values('333333333', '2019-01-01 10:00:00', '140880D');
insert into consultation_diagnostic values('222222222', '2019-01-02 10:00:00', '101050D');
insert into consultation_diagnostic values('444444444', '2019-01-02 10:00:00', '140880D');
insert into consultation_diagnostic values('111111111', '2019-01-01 13:00:00', '140880D');
insert into consultation_diagnostic values('444444444', '2019-01-01 13:00:00', '118065D');
insert into consultation_diagnostic values('111111111', '2019-01-02 09:00:00', '118065D');
insert into consultation_diagnostic values('111111111', '2019-01-02 12:00:00', '111975D');
insert into consultation_diagnostic values('333333333', '2019-01-02 14:00:00', '135048D');
insert into consultation_diagnostic values('111111111', '2019-01-03 17:00:00', '135048D');
insert into consultation_diagnostic values('333333333', '2019-01-03 10:00:00', '135048D');
insert into consultation_diagnostic values('222222222', '2019-01-02 13:00:00', '135048D');
insert into consultation_diagnostic values('222222222', '2019-02-01 14:00:00', '138192D');
insert into consultation_diagnostic values('333333333', '2019-02-01 17:00:00', '138192D');
insert into consultation_diagnostic values('111111111', '2019-02-12 13:00:00', '138192D');

insert into medication values('Tylenol','McNeil');
insert into medication values('Ibuprofen','Boots Group');
insert into medication values('Orajel','Norwich Warner Pharmaceuticals');

insert into prescription values('Ibuprofen','Boots Group', '444444444', '2019-01-02 10:00:00', '140880D', '100mg', 'Every night');
insert into prescription values('Ibuprofen','Boots Group', '111111111', '2019-01-01 13:00:00', '140880D', '100mg', 'At breakfast');
insert into prescription values('Ibuprofen','Boots Group', '444444444', '2019-01-01 13:00:00', '118065D', '50mg', 'Every night');
insert into prescription values('Tylenol','McNeil', '111111111', '2019-01-02 09:00:00', '118065D', '100mg', 'After dinner');
insert into prescription values('Tylenol','McNeil', '333333333', '2019-01-03 10:00:00', '135048D', '100mg', 'At breakfast');
insert into prescription values('Orajel','Norwich Warner Pharmaceuticals', '333333333', '2019-01-02 14:00:00', '135048D', '100mg', 'At breakfast');
insert into prescription values('Orajel','Norwich Warner Pharmaceuticals', '111111111', '2019-01-03 17:00:00', '135048D', '50mg', 'Every night');
insert into prescription values('Orajel','Norwich Warner Pharmaceuticals', '222222222', '2019-01-02 13:00:00', '135048D', '100mg', 'Every night');
insert into prescription values('Orajel','Norwich Warner Pharmaceuticals', '111111111','2019-02-12 13:00:00', '138192D', '100mg', 'Every night');

insert into procedure_ values('Extraction', 'Surgery');
insert into procedure_ values('Braces', 'Repair');
insert into procedure_ values('Gum Surgery', 'Surgery');
insert into procedure_ values('Teeth Whitening', 'Repair');

insert into procedure_in_consultation values('Extraction', '333333333', '2019-01-01 10:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Teeth Whitening', '333333333', '2019-01-01 10:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Braces', '111111111', '2019-01-01 13:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Extraction', '444444444', '2019-01-01 13:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Teeth Whitening', '444444444', '2019-01-02 10:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Extraction', '111111111', '2019-01-02 12:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Teeth Whitening', '222222222', '2019-01-02 13:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Teeth Whitening', '222222222', '2019-02-01 14:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Teeth Whitening', '333333333', '2019-02-01 17:00:00', 'xxxxxxx');
insert into procedure_in_consultation values('Teeth Whitening', '111111111', '2019-02-12 13:00:00', 'xxxxxxx');

insert into procedure_radiology values('Braces', 'images1.png', '111111111', '2019-01-01 13:00:00');
insert into procedure_radiology values('Extraction', 'images2.png', '333333333', '2019-01-01 10:00:00');

insert into teeth values(1,1,'Molar');
insert into teeth values(1,2,'Pre-Molar');
insert into teeth values(2,1,'Incisor');
insert into teeth values(2,2,'Molar');

insert into procedure_charting values('Extraction', '333333333', '2019-01-01 10:00:00', 1,1, 'xxxxxxx', 10.0);
insert into procedure_charting values('Extraction', '333333333', '2019-01-01 10:00:00', 1,2, 'xxxxxxx', 5.0);
insert into procedure_charting values('Extraction', '333333333', '2019-01-01 10:00:00', 2,1, 'xxxxxxx', 10.0);
insert into procedure_charting values('Extraction', '333333333', '2019-01-01 10:00:00', 2,2, 'xxxxxxx', 5.0);
insert into procedure_charting values('Braces', '111111111', '2019-01-01 13:00:00', 1,1,'xxxxxxx', 10.0);
insert into procedure_charting values('Braces', '111111111', '2019-01-01 13:00:00', 1,2,'xxxxxxx', 10.0);
insert into procedure_charting values('Braces', '111111111', '2019-01-01 13:00:00', 2,1,'xxxxxxx', 10.0);
insert into procedure_charting values('Teeth Whitening', '222222222', '2019-02-01 14:00:00', 1,1, 'xxxxxxx', 5.0);
insert into procedure_charting values('Teeth Whitening', '222222222', '2019-02-01 14:00:00', 1,2, 'xxxxxxx', 5.0);
insert into procedure_charting values('Teeth Whitening', '222222222', '2019-02-01 14:00:00', 2,1, 'xxxxxxx', 10.0);
insert into procedure_charting values('Teeth Whitening', '222222222', '2019-02-01 14:00:00', 2,2, 'xxxxxxx', 10.0);
insert into procedure_charting values('Teeth Whitening', '333333333', '2019-02-01 17:00:00', 1,1, 'xxxxxxx', 2.0);
insert into procedure_charting values('Teeth Whitening', '333333333', '2019-02-01 17:00:00', 2,1, 'xxxxxxx', 1.0);
insert into procedure_charting values('Teeth Whitening', '111111111', '2019-02-12 13:00:00', 1,1, 'xxxxxxx', 10.0);
insert into procedure_charting values('Teeth Whitening', '111111111', '2019-02-12 13:00:00', 1,2, 'xxxxxxx', 4.0);
insert into procedure_charting values('Teeth Whitening', '111111111', '2019-02-12 13:00:00', 2,1, 'xxxxxxx', 5.0);
