---CREATE TABLE AND INSERT SAMPLE VALUES
---------------------------------------------------------------------------
create table phone_regex (
	name varchar(50),
	phone_number varchar(16)
)

insert into phone_regex (name,phone_number)
values 
('Abdi','+6297491758'),
('Andi','+629 7490 995'),
('Aldi','0829-7490-286'),
('Ardi','0862.9749.0865'),
('Afdi','6297491264'),
('Addi','086 2974918883'),
('Asdi','629 74903975')

-------------------------------------------------------------------

create table address_regex (
	name varchar(50),
	address varchar(100)
)

insert into address_regex (name,address)
values 
('Abdi','Jl. Merdeka No @45 *Bandung*'),
('Andi','#Jl. Merdeka# #No45# @Bandung'),
('Aldi','**Jl. Merdeka [No45] $Bandung*'),
('Ardi','(Jl. Merdeka No @45 (Bandung)'),
('Afdi','[Jl. Merdeka No 45 [Bandung*'),
('Addi','$Jl. Merdeka No @45 *#$@'),
('Asdi','##Jl. Merdeka No @45 &$@#Bandung*')

----------Check Data---------------------------------------------------------
select pr."name",pr.phone_number, ar.address 
from phone_regex pr
left join address_regex ar on pr.name = ar."name" 

---------------------------------------------------------------------------

---Cleaning The Data (phone number and Address)--------------

---Using cte replace unformated value----

with cleansing_data as (
	select
		pr.name,
		pr.phone_number,
		regexp_replace(pr.phone_number,'[^0-9]','','g') as phone_number_cleaned,
		ar.address,
		regexp_replace(ar.address, '[^a-zA-Z0-9\s]','','g')  as address_cleaned
	from phone_regex pr 
	left join address_regex ar on pr.name = ar.name 

)

select * from cleansing_data

------------Change Phone Number Format(replace 62 to 0)---------------------

with cleansing_data as (
	select
		pr.name,
		pr.phone_number,
		regexp_replace(pr.phone_number,'[^0-9]','','g') as phone_number_cleaned,
		ar.address,
		regexp_replace(ar.address, '[^a-zA-Z0-9\s]','','g')  as address_cleaned
	from phone_regex pr 
	left join address_regex ar on pr.name = ar.name 

),
phone_number_format as (
	select 
	name, 
	phone_number_cleaned, 
	case when left(phone_number_cleaned,2) = '62' then 0 || substr(phone_number_cleaned,3)
	else phone_number_cleaned
	end as phone_number_formated,
	address_cleaned
	from cleansing_data
)

select * from phone_number_format

----------Masking phone number-------

----Safe as View Table---

create view data_customer_with_masking as 
	with cleansing_data as (
		select
		pr.name,
		pr.phone_number,
		regexp_replace(pr.phone_number,'[^0-9]','','g') as phone_number_cleaned,
		ar.address,
		regexp_replace(ar.address, '[^a-zA-Z0-9\s]','','g')  as address_cleaned
	from phone_regex pr 
	left join address_regex ar on pr.name = ar.name 

	),
	phone_number_format as (
	select 
	name, 
	phone_number_cleaned, 
	case when left(phone_number_cleaned,2) = '62' then 0 || substr(phone_number_cleaned,3)
	else phone_number_cleaned
	end as phone_number_formated,
	address_cleaned
	from cleansing_data
	)

	select 
	name,
	concat(left(phone_number_formated,3),'******',right(phone_number_formated,4)) as phone_number_fix,
	address_cleaned
	from phone_number_format

	------------------------------------------------------------------------------------------------