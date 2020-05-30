--INDEXES FOR QUERY 1
--We don't need to create indexes on columns that aren't primary keys but are used in inner joins since, in this case,
--they are foreign keys, so there is already an index used to compare the values to the column, and creating another
--index would be only a waste of memory space  
--
-- We use a BTree index instead of a Hash index, since we want to retrieve many values 
-- and sort them by order.
--BTree is more efficient when ones wants to retrieve a large set of ordered values, instead a single value, since it isn't required
--to retrieve those values from many buckets and them ordering them
-- The used index is NonClustered since the clustered index is already used for the primary key 
-- The index is created on  column that needs to be sorted. This makes it much easier for the query to retrieve the names sorted from the binary tree,
-- using binary search
create index index1_1 on employee (name);

--query that uses this index:
select client.VAT, client.name, phone
from consultation, appointment, client natural left join phone_number_client, doctor, employee
where appointment.VAT_doctor = consultation.VAT_doctor and appointment.date_timestamp = consultation.date_timestamp 
and appointment.VAT_client = client.VAT 
	and consultation.VAT_doctor = doctor.VAT and doctor.VAT = employee.VAT and employee.name='Jane Sweettooth'
order by client.name asc;

--INDEXES FOR QUERY 2
--We don't need to create indexes on columns that aren't primary keys but are used in inner joins since, in this case,
--they are foreign keys, so there is already an index used to compare the values to the column, and creating another
--index would be only a waste of memory space  
--
-- a BTree index is created on the column evaluation of supervision_report, instead of a hash index,
-- since we want to retrieve many values using the less than or equal operator
--Since the Btree index orders the values, it is more suited for this case
--the index is NonClustered because the primary_key of supervision_report already uses the clustered_index 
create index index2_1 on supervision_report(evaluation);

--A fulltext index is created on the description column of supervision_report since we want to find the
--frequency of ocorrunce of a word in the text 
create fulltext index index2_2 on supervision_report(description);

--query that uses this index:
--We need to change the query to use the FullText Index, since the like operator
--won't use the full text index, but will instead use a buffer
--Therefore, we need to use the MATCH(colum_name) AGAINST('query') operator
select t.name as trainee_name, t.VAT as trainee_VAT, p.name as supervisor_name, evaluation, description
from employee t, trainee_doctor, supervision_report, employee p
where t.VAT = trainee_doctor.VAT and supervision_report.VAT = trainee_doctor.VAT and  trainee_doctor.supervisor = p.VAT 
and (evaluation < 3 or match(supervision_report.description) against('insufficient'))
order by evaluation desc;
