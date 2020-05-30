/*1*/
drop trigger if exists update_clients_age;

delimiter $$
create trigger update_clients_age after insert on appointment
for each row
begin
	update client set age=floor(datediff(now(),client.birth_date)/365)
	where client.VAT= new.VAT_client;
end$$
delimiter ;

/*Test
insert into appointment values('333333333', '2019-01-07 15:00:00', 'xxxxxxx', '101010101');   
*/

/*2*/
drop trigger if exists ensure_nurse_i;

delimiter $$
create trigger ensure_nurse_i before insert on nurse
for each row
begin
	if new.VAT in (select VAT from doctor)
	then 
	signal sqlstate '45000' set MESSAGE_TEXT = 'Already exists a doctor with the same VAT!';
	end if;
end$$
delimiter ;

drop trigger if exists ensure_nurse_u;

delimiter $$
create trigger ensure_nurse_u before update on nurse
for each row
begin
	if new.VAT in (select VAT from doctor)
	then 
	signal sqlstate '45000' set MESSAGE_TEXT = 'Already exists a doctor with the same VAT!';
	end if;
end$$
delimiter ;

/*Test 
insert into nurse values (111111111); 
update nurse set VAT=111111111 where VAT=555555555;*/ 

drop trigger if exists ensure_receptionist_i;

delimiter $$
create trigger ensure_receptionist_i before insert on receptionist
for each row
begin
	if new.VAT in (select VAT from doctor)
	then 
	signal sqlstate '45000' set MESSAGE_TEXT = 'Already exists a doctor with the same VAT!';
	end if;
end$$
delimiter ;

drop trigger if exists ensure_receptionist_u;

delimiter $$
create trigger ensure_receptionist_u before update on receptionist
for each row
begin
	if new.VAT in (select VAT from doctor)
	then 
	signal sqlstate '45000' set MESSAGE_TEXT = 'Already exists a doctor with the same VAT!';
	end if;
end$$
delimiter ;

/*Test 
insert into receptionist values (111111111); 
update receptionist set VAT=111111111;*/ 

drop trigger if exists ensure_doctor_i;

delimiter $$
create trigger ensure_doctor_i before insert on doctor
for each row
begin
	if new.VAT in (select VAT from receptionist) or new.VAT in (select VAT from nurse)
	then 
	signal sqlstate '45000' set MESSAGE_TEXT = 'Already exists a nurse or a receptionist with the same VAT!';
	end if;
end$$
delimiter ;

drop trigger if exists ensure_doctor_u;

delimiter $$
create trigger ensure_doctor_u before update on doctor
for each row
begin
	if new.VAT in (select VAT from receptionist) or new.VAT in (select VAT from nurse)
	then 
	signal sqlstate '45000' set MESSAGE_TEXT = 'Already exists a nurse or a receptionist with the same VAT!';
	end if;
end$$
delimiter ;

/*Test 
insert into doctor values (555555555,'pediatria','medico entrou para aqui em 1996','medico@gmail.com');
insert into doctor values (777777777,'pediatria','medico entrou para aqui em 1996','medico@gmail.com');  
update doctor set VAT=555555555;
update doctor set VAT=777777777;
*/ 

drop trigger if exists ensure_permanent_doctor_i;

delimiter $$
create trigger ensure_permanent_doctor_i before insert on permanent_doctor
for each row
begin
	if new.VAT in (select VAT from trainee_doctor) 
	then 
	signal sqlstate '44000' set MESSAGE_TEXT = 'Already exists a Trainee Doctor with the same VAT!';
	end if;
end$$
delimiter ;

drop trigger if exists ensure_permanent_doctor_u;

delimiter $$
create trigger ensure_permanent_doctor_u before update on permanent_doctor
for each row
begin
	if new.VAT in (select VAT from trainee_doctor) 
	then 
	signal sqlstate '44000' set MESSAGE_TEXT = 'Already exists a Trainee Doctor with the same VAT!';
	end if;
end$$
delimiter ;

/*Test 
insert into permanent_doctor values (444444444,13);
update permanent_doctor set VAT=444444444;
*/ 

drop trigger if exists ensure_trainee_doctor_i;

delimiter $$
create trigger ensure_trainee_doctor_i before insert on trainee_doctor
for each row
begin
	if new.VAT in (select VAT from permanent_doctor)
	then 
	signal sqlstate '44001' set MESSAGE_TEXT = 'Already exists a Permanent Doctor with the same VAT!';	
	elseif new.supervisor in (select VAT from trainee_doctor)
	then 
	signal sqlstate '44001' set MESSAGE_TEXT = 'A supervisor can\'t be a trainee!';
	end if;
end$$
delimiter ;

drop trigger if exists ensure_trainee_doctor_u;

delimiter $$
create trigger ensure_trainee_doctor_u before update on trainee_doctor
for each row
begin
	if new.VAT in (select VAT from permanent_doctor)
	then 
	signal sqlstate '44001' set MESSAGE_TEXT = 'Already exists a Permanent Doctor with the same VAT!';	
	elseif new.supervisor in (select VAT from trainee_doctor)
	then 
	signal sqlstate '44001' set MESSAGE_TEXT = 'A supervisor can\'t be a trainee!';
	end if;
end$$
delimiter ;

/*Test 
insert into trainee_doctor values (111111111,222222222);
insert into trainee_doctor values (555555555,333333333);
update trainee_doctor set VAT=111111111;
update trainee_doctor set supervisor=333333333;
*/ 

/* 3*/

drop trigger if exists ensure_phone_number_client_i;

delimiter $$
create trigger ensure_phone_number_client_i before insert on phone_number_client
for each row
begin
	if new.phone in (select phone from phone_number_employee natural join doctor)
	then 
	signal sqlstate '44003' set MESSAGE_TEXT = 'Already exists a doctor with the same phone number!';
	elseif new.phone in (select phone from phone_number_client)
	then
	signal sqlstate '44003' set MESSAGE_TEXT = 'Already exists a client with the same phone number!';
	end if;
end$$
delimiter ;

drop trigger if exists ensure_phone_number_client_u;

delimiter $$
create trigger ensure_phone_number_client_u before update on phone_number_client
for each row
begin
	if new.phone in (select phone from phone_number_employee natural join doctor)
	then 
	signal sqlstate '44003' set MESSAGE_TEXT = 'Already exists a doctor with the same phone number!';
	elseif new.phone in (select phone from phone_number_client)
	then
	signal sqlstate '44003' set MESSAGE_TEXT = 'Already exists a client with the same phone number!';
	end if;
end$$
delimiter ;

/*Test 
insert into phone_number_client values (888888888,927123781);
insert into phone_number_client values (888888888,930192843);
update phone_number_client set phone=927123781;
update phone_number_client set phone=930192843;
*/ 

drop trigger if exists ensure_phone_number_doctor_i;

delimiter $$
create trigger ensure_phone_number_doctor_i before insert on phone_number_employee
for each row
begin
	if new.VAT in (select VAT from doctor) then
	  if new.phone in (select phone from phone_number_client) then
	  signal sqlstate '44004' set MESSAGE_TEXT = 'Already exists a client with the same phone number!';
	  elseif new.VAT in (select VAT from phone_number_employee natural join doctor) then
	  signal sqlstate '44004' set MESSAGE_TEXT = 'Already exists another doctor with the same phone number!';
	  end if;
	end if;
end$$
delimiter ;

drop trigger if exists ensure_phone_number_doctor_u;

delimiter $$
create trigger ensure_phone_number_doctor_u before update on phone_number_employee
for each row
begin
	if new.VAT in (select VAT from doctor) then
	  if new.phone in (select phone from phone_number_client) then
	  signal sqlstate '44004' set MESSAGE_TEXT = 'Already exists a client with the same phone number!';
	  elseif new.VAT in (select VAT from phone_number_employee natural join doctor) then
	  signal sqlstate '44004' set MESSAGE_TEXT = 'Already exists another doctor with the same phone number!';
	  end if;
	end if;
end$$
delimiter ;

/*Test 
insert into phone_number_employee values (111111111,927123781);
insert into phone_number_employee values (111111111,930192843);
update phone_number_employee set phone=927123781;
update phone_number_employee set phone=930192843;
*/ 

/*4*/
drop function if exists no_shows;

delimiter $$
create function no_shows(gender char(20),age_lower int,age_upper int,appointment_year int)
returns integer
return  (select count(*) from appointment natural left join consultation 
inner join client on appointment.VAT_client=client.VAT 
where client.gender=gender and client.age between age_lower and age_upper
and extract(year from appointment.date_timestamp)=appointment_year
and consultation.VAT_doctor is null)
$$
delimiter ;

/*Test
select no_shows('male',0,100,2019);
*/


/*5*/
drop procedure if exists doctors_salary;

delimiter $$
create procedure doctors_salary ( in practice_years int )
begin

update employee set salary =1.1*salary where employee.VAT in(
select VAT from permanent_doctor inner join 
consultation on permanent_doctor.VAT = consultation.VAT_doctor
where permanent_doctor.years > practice_years
and year(date(consultation.date_timestamp)) = year(now())
group by permanent_doctor.VAT
having count(date_timestamp)>100);

update employee set salary =1.05*salary where employee.VAT in(
select VAT from permanent_doctor inner join 
consultation on permanent_doctor.VAT = consultation.VAT_doctor
where permanent_doctor.years > practice_years
and year(date(consultation.date_timestamp)) = year(now())
group by permanent_doctor.VAT
having count(date_timestamp)<=100);

end $$
delimiter ;

/*Test
call doctors_salary(1);
*/