-- 2A Queries related to the sales database
-- question 1
-- a
select empfname, empsalary
into #xemp 
from xemp
where deptname in ('management','marketing','purchasing') 
and (empfname like '%a%' or empfname like '%d')
and (bossno != 0)
order by empfname

-- b
update #xemp
set empsalary = empsalary * 1.05
where empsalary >= 25000

-- c
select *
from #xemp
order by empfname

-- d
select *
from #xemp
where empsalary >= 25000
order by empfname

-- e
drop table #xemp

-- question 2
-- a
select distinct itemname
from xdept inner join xsale 
on xdept.deptname = xsale.deptname 
where deptfloor = 2
and itemname in (select itemname 
                 from xitem
                 where itemcolor = 'brown')

-- b
select itemname
from xitem
where itemcolor = 'brown' 
and itemname in (select distinct itemname
                 from xsale
                 where deptname in (select deptname
                                    from xdept
                                    where deptfloor = 2))

-- c
select itemname 
from xitem
where itemcolor = 'brown'
and itemname in (select distinct itemname
                 from xsale
                 where exists (select *
                               from xdept
                               where xdept.deptname = xsale.deptname
                               and deptfloor = 2))

-- question 3
select distinct deptname
from xsale
where deptname not in (select deptname
                       from xsale 
                       where itemname = 'compass')

-- question 4
select distinct b.itemname, b.itemtype, b.itemcolor, f.empno, f.empfname, f.empsalary, f.deptname, f.bossno
from xsale as a, xitem as b, xdept as c, xdel as d, xspl as e, xemp as f
where a.itemname = b.itemname 
and a.deptname = c.deptname
and b.itemname = d.itemname 
and d.splno = e.splno
and c.empno = f.empno
and f.deptname = 'marketing'
and b.itemname = 'compass'

-- a
select avg(empsalary) as avg_salary,
count(distinct deptname) as id
into #avg_marketing_table
from xemp
where deptname = 'marketing'

-- b
select avg(empsalary) as avg_salary,
count(distinct deptname) as id
into #avg_purchasing_table
from xemp
where deptname = 'purchasing'

-- c & d
select abs(#avg_marketing_table.avg_salary-#avg_purchasing_table.avg_salary) 
as dif_salary
into #dif_salary_table
from #avg_marketing_table inner join #avg_purchasing_table
on #avg_marketing_table.id = #avg_purchasing_table.id

-- e
drop table #avg_marketing_table, #avg_purchasing_table, #dif_salary_table

-- question 6
-- a
select empfname, empsalary
from xemp
where empno = (select bossno
               from xemp
               where empno = (select bossno
                              from xemp
                              where empfname = 'nancy'))

-- b
select empno, empfname
from xemp
where bossno = (select empno
                from xemp
                where empfname = 'andrew')
order by empfname

-- c
select a.empfname, a.deptname, 
b.empfname as manager, 
b.deptname as manager_department
from xemp as a inner join xemp as b 
on a.bossno = b.empno
where a.deptname != b.deptname

-- d
select a.empno, a.empfname, 
(a.empsalary-b.empsalary) as difference_in_salary
from xemp as a inner join xemp as b 
on a.bossno = b.empno
where a.empsalary > b.empsalary

-- e
select a.empfname, a.empsalary, 
b.empfname as manager
from xemp as a inner join xemp as b 
on a.bossno = b.empno
where a.deptname = 'accounting' 
and a.empsalary > 20000

-- question 7
select splno, count(distinct itemname)
as total_unique_items_supplied
from xdel
group by splno
having count(distinct itemname) >= 5 
order by total_unique_items_supplied desc

-- question 8
select xsale.deptname, count(itemname) 
as amount_of_items_supplied
from xsale inner join xdept
on xsale.deptname = xdept.deptname 
where deptfloor in (1,2)
group by xsale.deptname
having count(deptfloor) >= 5

-- question 9
-- a
select a.bossno as empno, b.empfname, count(a.bossno)
as direct_employees
into #tmp1
from xemp as a inner join xemp as b 
on a.bossno = b.empno
where a.bossno != 0
group by a.bossno, b.empfname

-- b
select *
from #tmp1
where direct_employees = (select min(direct_employees)
                          from #tmp1)

drop table #tmp1

-- question 10
-- a
select empfname, empsalary
into #tmp2
from xemp
where empsalary > (select max(empsalary)
                   from xemp
                   where deptname = 'clothes')
order by empsalary

-- b
select *, rank() over (order by empsalary desc) 
as rank
into #tmp3
from #tmp2

-- c
select top(3) *
from #tmp3

-- d
drop table #tmp2, #tmp3

-- question 11
-- a
select deptname, avg(empsalary)
as averagesalary
from xemp
where deptname in (select distinct deptname
                   from xsale
                   where itemname in ('compass','elephant polo stick'))
group by deptname
having avg(empsalary) > 10000

-- b
select deptname, avg(empsalary)
as averagesalary
from xemp
group by deptname
having avg(empsalary) > 10000
intersect
select xsale.deptname, avg(empsalary) 
as averagesalary
from xsale inner join xemp 
on xsale.deptname = xemp.deptname
where itemname in ('compass','elephant polo stick')
group by xsale.deptname

-- question 12
-- a
select splname
from xspl
where splno not in (select splno
                    from xdel
                    where itemname = 'stetson');

-- b
select splname
from xspl
except
select splname
from xdel inner join xspl
on xspl.splno = xdel.splno
where itemname = ('stetson')

-- question 13
GO
create function dbo.GetFirstWord (@string varchar(1024))
returns varchar(1024)
as begin
    return case charindex(' ', @string, 1) -- charindex looks for the substring ' ' (empty space) within the string, starting from location 1 and returning the position of the substring if it exists.        
            when 0 -- if charindex returns 0 it means that our string consist out of 1 word.
            then @string -- subsequently we return '@string' as our result     
    else substring(@string, 1, charindex(' ', @string, 1) -1) -- use the charindex function to provide the length for the parameter in substring function
            end
end
GO

select *, dbo.getfirstword(itemname)
as itemname_firstword
from xitem

drop function getfirstword

-- question 14
-- a, b & c
select deptname, avg(empsalary)
as averagesalary
into #tmp4
from xemp
group by deptname

select *
into #result
from #tmp4
where averagesalary = (select max(averagesalary)
                       from #tmp4)
or averagesalary = (select min(averagesalary)
                     from #tmp4)

-- d
drop table #tmp4, #result

-- question 15
-- a
select itemname
from xdel
where deptname = 'clothes'
union 
select itemname
from xdel inner join xspl
on xdel.splno = xspl.splno
where splname = 'nepalese corp.'

-- b
select distinct itemname
from xdel
where deptname = 'clothes' 
or splno = (select splno
            from xspl
            where splname = 'nepalese corp.')

-- question 16
-- a
select itemname
from xdel inner join xspl
on xdel.splno = xspl.splno
where splname = 'nepalese corp.'
except
select itemname
from xdel
where deptname = 'clothes'

-- b
select distinct itemname
from xdel inner join xspl
on xdel.splno = xspl.splno
where splname = 'nepalese corp.'
and itemname not in (select itemname
                     from xdel
                     where deptname = 'clothes')

-- question 17
select distinct deptname
from xdel
where itemname in (select xdel.itemname
                   from xdel inner join xspl
                   on xdel.splno = xspl.splno
                   inner join xitem
                   on xdel.itemname = xitem.itemname
                   where itemtype in ('E','F')
                   and deptname = 'navigation'
                   and splname = 'nepalese corp.')

-- question 18
-- a
select saleno, saleqty, a.itemname as a_itemname, deptname, 
b.itemname as b_itemname, itemtype, itemcolor
into #cartesian_temp
from xsale as a, xitem as b

-- b
select *
into #unique_records
from #cartesian_temp
where a_itemname = b_itemname

-- c
delete from #cartesian_temp
where a_itemname = b_itemname

-- d
drop table #cartesian_temp, #unique_records

-- question 19
select *
into #xsale_copy
from xsale 

-- no changes made
select *
from xsale
except
select *
from #xsale_copy

-- changes made
update #xsale_copy
set itemname = 'compass'

select *
from xsale
except
select *
from #xsale_copy 

drop table #xsale_copy

-- 2B Queries related to tables of the Patstat database
-- question 20
-- a
select cluster_id, count(*)
as n_pubs
from patstat_golden_set
group by cluster_id 
order by n_pubs desc

-- b
select cluster_id, 
count(*) as n_pubs,
count(*) * 100.0 / sum(count(*)) over() as probability
from patstat_golden_set
group by cluster_id 
order by n_pubs desc

-- c
select cluster_id, 
count(*) as n_pubs,
count(*) * 100.0 / sum(count(*)) over() as probability
into #result
from patstat_golden_set
group by cluster_id 
order by n_pubs desc

-- d
select *, 
(n_pubs - (select avg(n_pubs) as average from #result)) / (select stdev(n_pubs) as average from #result) as normalized_n_pubs
from #result
order by n_pubs desc

-- e
drop table #result

-- question 21
GO
create function dbo.funcDeleteMultipleSpaces (@inputstring nvarchar(1024))
returns nvarchar(1024)
as begin
	while charindex('  ', @inputstring, 1) > 0 -- the loop keeps running till there are no multiple spaces left in the input
		set @inputstring = replace(@inputstring,'  ',' ') -- each time we find a multiple space we replace it with an one emptyspace 
	return @inputstring
end
GO

select dbo.funcDeleteMultipleSpaces(npl_biblio)
from patstat

-- question 22
GO
create function dbo.cleanIt (@StringInput nvarchar(1024), @InvalidCharacters nvarchar(1024))
returns nvarchar(1024)
as begin
	while @StringInput like @InvalidCharacters -- loop keeps running till there are no invalid characters left in the inputstring
		set @StringInput = stuff(@StringInput, patindex(@InvalidCharacters, @StringInput), 1, '') -- stuff(string, start, length, replacement), patindex returns the position of a specific character of a string.
	return @StringInput
end
GO

select dbo.cleanIt(npl_biblio, '%[^A-Z0-9 ]%') -- remove everything except the letters, numbers and emptyspaces.
from patstat

-- question 23
-- data pre-processing 
select dbo.funcDeleteMultipleSpaces(dbo.cleanIt(ltrim(rtrim(npl_biblio collate SQL_Latin1_General_Cp1251_CS_AS)), '%[^A-Z0-9 ]%')) as cleandata
into #tmp
from patstat


--Q23.3
-- retrieve xpnumber
GO
create function dbo.XPnumber (@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%XP0%', @string) -- patindex looks for the location of XPnumber in the string       
            when 0 -- if patindex returns 0 it means that it has no XP number
            then NULL    
    else substring(@string, Patindex('%XP0%', @string), 11) -- retrieve the xpnumber
            end
end
GO

-- inserting XP number into a new colun and using a temporary table containing 'cleandata' and the 'xp_number'
select cleandata, dbo.XPnumber(cleandata) as xp_number
into #group10_xpno
from #tmp

-- retrieve issn, we recognize that the ISSN has 8 numbers
GO
create function dbo.ISSN(@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%ISSN %', @string) -- patindex looks for the location of ISSN in the string       
            when 0 -- if patindex returns 0 it means that it has no ISSN
            then NULL    
    else substring(@string, Patindex('%ISSN %', @string) + 5, 8) -- retrieve the ISSN
            end
end
GO

-- inserting ISSN number into a new column and using a temporary table containing 'cleandata' and the 'ISSN'
select cleandata, dbo.ISSN(cleandata) as ISSN
into #group10_issn
from #tmp

-- retrieve isbn
GO
create function dbo.ISBN(@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%ISBN %', @string) -- patindex looks for the location of ISSN in the string       
            when 0 -- if patindex returns 0 it means that it has no ISSN
            then NULL    
    else substring(@string, Patindex('%ISBN %', @string) + 5, 13) -- retrieve the ISSN
            end
end
GO

-- inserting ISBN number into a new column and using a temporary table containing 'cleandata' and the 'ISBN'
select cleandata, dbo.ISBN(cleandata) as ISBN
into #group10_isbn
from #tmp

/* 
We want to retrieve the page numbers but there are multiple variations as to how the pagenumber is written. We will extract
only the page numbers which are starting with 'pages', 'page', and 'pp' as they are the most common and appear in most entries.
*/

-- retrieve page number using 'page'
GO
create function dbo.pageno(@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%page %', @string) -- patindex looks for the location of the page number ('page') in the string       
            when 0 -- if patindex returns 0 it means that it has no page number
            then NULL    
    else substring(@string, Patindex('%page %', @string) + 5, 6) -- retrieve the page number
            end
end
GO


-- creating a temporary intermediate table with alphanumeric page numbers from 'page'
select cleandata, dbo.pageno(cleandata) as page_number
into #group10_pno_intermediate
from #tmp

-- creating a temporary table extracting all the page numbers to only return numeric page numbers
select *
into #group10_pageno
from #group10_pno_intermediate
where IsNumeric(page_number) = 1

-- retrieving page number using 'pages'
GO
create function dbo.pagesno(@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%pages %', @string) -- patindex looks for the location of the page number ('pages') in the string       
            when 0 -- if patindex returns 0 it means that it has no page number
            then NULL    
    else substring(@string, Patindex('%pages %', @string) + 5, 9) -- retrieve the page number
            end
end
GO


-- creating a temporary intermediate table with alphanumeric page numbers using 'pages'
select cleandata, dbo.pagesno(cleandata) as page_number
into #group10_pages_numbers_intermediate
from #tmp

-- creating a temporary table filtering all the page numbers to only return numeric page numbers
insert into #group10_pageno
select *
from #group10_pages_numbers_intermediate
where IsNumeric(page_number) = 1


-- retrieving page number using 'pp'
GO
create function dbo.ppno(@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%pp %', @string) -- patindex looks for the location of the page number ('pp') in the string       
            when 0 -- if patindex returns 0 it means that it has no page number
            then NULL    
    else substring(@string, Patindex('%pp %', @string) + 5, 9) -- retrieve the page number
            end
end
GO


-- creating a temporary intermediary table with alphanumeric page numbers using 'pages'
select cleandata, dbo.ppno(cleandata) as page_number
into #group10_ppno_interm
from #tmp


-- creating a temporary table filtering all the page numbers to only return numeric page numbers
insert into #group10_pageno
select *
from #group10_ppno_interm
where IsNumeric(page_number) = 1


-- retrieving volume number
GO
create function dbo.volume(@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%vol %', @string) -- patindex looks for the location of ISSN in the string       
            when 0 -- if patindex returns 0 it means that it has no ISSN
            then NULL    
    else substring(@string, Patindex('%vol %', @string) + 5, 2) -- retrieve the ISSN
            end
end
GO

-- creating a intermediate temporary table extracting all the alpanumeric volume numbers
select cleandata, dbo.volume(cleandata) as volume_number
into #group10_volumeno_interm
from #tmp


-- creating a temporary table extracting all numeric volume numbers
select *
into #group10_volumeno
from #group10_volumeno_interm
where IsNumeric(volume_number) = 1


-- retrieving issue number
GO
create function dbo.issue(@string varchar(1024))
returns varchar(1024)
as begin
    return case Patindex('%no %', @string) -- patindex looks for the location of issue number in the string       
            when 0 -- if patindex returns 0 it means that it has no issue number
            then NULL    
    else substring(@string, Patindex('%no %', @string) + 5, 3) -- retrieve the issue number
            end
end
GO

-- create an intermediate temporary table extracting all the issue numbers containing all alphanumeric values
select cleandata, dbo.issue(cleandata) as issue_number
into #group10_issue_interm
from #tmp


-- create a temporary table extracting all issue numbers containing only numeric values
select *
into #group10_issueno
from #group10_issue_interm
where IsNumeric(issue_number) = 1

-- retrieving the publication year
GO
create function dbo.publn_year(@string nvarchar(1024))
returns nvarchar(1024)
as begin 
declare @index1 int, @index2 int
	set @index1 = patindex('%[1][9][0-9][0-9]%', @string)
	set @index2 = patindex('%[2][0][0-2][0-9]%', @string)
		if @index1 > 0
			set @string = substring(@string, @index1, 4)
		else if @index2 > 0
			set @string = substring(@string, @index2, 4)
		else
			set @string = NULL
	return @string
end;
GO

-- creating a temporary table extracting all publication years
select cleandata, dbo.publn_year(cleandata) as publn_year
into #group10_year
from #tmp
order by publn_year

-- Q23.4
/*
Now we have extracted the XP number, ISSN, ISBN, page number, volume number, issue number, and the publication year.
Now we need to combine all the separate temporary helper tables into one table 
*/
select *
into #question23
from #group10_year

-- adding column for xp_number
alter table #question23
add xp_number nvarchar(256)

-- joining the extracted xp_number on the final table by 'cleandata'
update #question23
set #question23.xp_number = #group10_xpno.xp_number
from #group10_xpno join #question23
on #question23.cleandata = #group10_xpno.cleandata

-- adding column for ISSN
alter table #question23
add ISSN nvarchar(256)

-- joining the extracted issn on the final table by 'cleandata'
update #question23
set #question23.issn = #group10_issn.issn
from #group10_issn join #question23
on #question23.cleandata = #group10_issn.cleandata

-- adding column for ISBN
alter table #question23
add ISBN nvarchar(256)

-- joining the extracted isbn temporary table on the final table by 'cleandata'
update #question23
set #question23.isbn = #group10_isbn.isbn
from #group10_isbn join #question23
on #question23.cleandata = #group10_isbn.cleandata

-- adding column for page number
alter table #question23
add page_number nvarchar(256)

-- joining the extracted page number temporary table on the final table by 'cleandata'
update #question23
set #question23.page_number = #group10_pageno.page_number
from #group10_pageno join #question23
on #question23.cleandata = #group10_pageno.cleandata

-- adding column for volume number
alter table #question23
add volume_number nvarchar(256)

-- joining the extracted volume numbers on the final table by 'cleandata'
update #question23
set #question23.volume_number = #group10_volumeno.volume_number
from #group10_volumeno join #question23
on #question23.cleandata = #group10_volumeno.cleandata

-- adding column for issue number
alter table #question23
add issue_number nvarchar(256)

-- joining the extracted issue numbers on the final table by 'cleandata'
update #question23
set #question23.issue_number = #group10_issueno.issue_number
from #group10_issueno join #question23
on #question23.cleandata = #group10_issueno.cleandata

--Q23.5
-- clustering
select distinct dense_rank() over (order by a.publn_year, a.issue_number, a.volume_number, a.page_number) as cluster_id, a.*
into #group10_patstat_clusters
from #question23 as a
join #question23 as b
on (a.publn_year = b.publn_year and
    a.issue_number = b.issue_number or
    a.volume_number = b.volume_number or
    a.page_number = b.page_number)

select *
from #group10_patstat_clusters

-- dropping all functions and tables
drop table #tmp, #group10_issn, #group10_isbn, #group10_patstat_clusters, #group10_pno_intermediate, #group10_pages_numbers_intermediate, #group10_ppno_interm, #group10_issue_interm, #group10_xpno
drop function funcDeleteMultipleSpaces, cleanIt, XPnumber, ISSN, ISBN, pageno, pagesno, ppno, volume, issue, publn_year

-- Part III
create table #depot
(
 depot_num int not null identity(1,1),
 depot_name nchar(50) not null,
 depot_address nchar(50) not null,
 primary key(depot_num)
);

create table #bus
(
 bus_reg_num int not null identity(300,1),
 depot_num int foreign key references #depot(depot_num),
 bus_model nchar(50) not null,
 color nchar(50) not null,
 primary key(bus_reg_num)
);

create table #driver
(
 driver_employ_num int not null identity(500,1),
 depot_num int foreign key references #depot(depot_num),
 driver_name nchar(50) not null,
 driver_salary money not null,
 passed_pcv_date datetime default getdate(),
 primary key(driver_employ_num)
);

create table #bus_type
(
 bus_type_id int not null identity(200,1),
 bus_reg_num int foreign key references #bus(bus_reg_num),
 driver_employ_num int foreign key references #driver(driver_employ_num),
 bus_kind nchar(50) not null,
 primary key(bus_type_id, bus_reg_num)
);

create table #bus_route
(
 route_num int not null identity(100,1),
 depot_num int foreign key references #depot(depot_num),
 bus_type_id int foreign key references #bus_type(bus_type_id),
 route_name nchar(50) not null,
 primary key(route_num)
);


create table #cleaner
(
 cleaner_employ_num int not null identity(400,1),
 bus_reg_num int foreign key references #bus(bus_reg_num),
 depot_num int foreign key references #depot(depot_num),
 cleaner_name nchar(50) not null,
 cleaner_salary money not null,
 primary key(cleaner_employ_num)
);


create table #driver_training
(
 driver_employ_num int foreign key references #driver(driver_employ_num),
 bus_type_id int foreign key references #bus_type(bus_type_id),
 passed_training_date date default getdate(),
 primary key(driver_employ_num)
);

create table #bus_restriction
(
	bus_type_id int foreign key references #bus_type(bus_type_id),
	route_num int foreign key references #bus_route(route_num),
	primary key(bus_type_id, route_num)
);

create table #driver_ability
(
	driver_employ_num int foreign key references #driver(driver_employ_num),
	route_num int foreign key references #bus_route(route_num),
	primary key(driver_employ_num, route_num)
);


-- DEPOT VALUES
insert into #depot
values('Sutton', 'Sutton Street'), ('Croydon', 'Croydon Street'), ('Islington', 'Islington Street')

select *
from #depot

-- ROUTE VALUES
insert into #bus_route
values(1, 200, 'Camden Town/Hendon'), (1, 201, 'Camden Town/Hendon'), (2, 202, 'Westminster/Abbey'), (3, 203, 'Heathrow/Centre')

select *
from #bus_route

-- BUS TYPE VALUES

insert into #bus_type
values(300, 500, 'double decker'), (301, 501, 'double decker'), (305, 502, 'Shuttle bus'), (306, 503, 'City bus')

select *
from #bus_type

-- BUS VALUES
insert into #bus
values(1, 'Routemaster', 'Dark blue'), (2, 'Volvo Olympian', 'Silver'), (3, 'Double decker', 'Black')

insert into #bus
values(3, 'Shuttle', 'Orange')

insert into #bus
values(1, 'Volvo speed 300XL', 'Bordeaux Red')

select *
from #bus


-- DRIVER VALUES

insert into #driver
values(1, 'Sam van Hassel', 2300, default)

insert into #driver
values(2, 'Nadya Hagen', 2300, default)

insert into #driver
values(3, 'Maksim Arinkin', 2300, default)

insert into #driver
values(1, 'Mehran Jafarzadeh', 2300, default)

select *
from #driver

-- CLEANER VALUES

insert into #cleaner
values(305, 1, 'Emiel Caron', 1500), (300, 1, 'Donald Trump', 120), (302, 3, 'Boris Johnson', 120)

select * 
from #cleaner

-- DRIVER TRAINING VALUES

insert into #driver_training
values(500, 200, '2018-04-01'), (501, 201, '2019-04-01'), (502, 202, '2020-04-01'), (503, 203, '2021-04-01')

select *
from #driver_training

-- Driver ability values

insert into #driver_ability
values(500, 10), (501, 101), (502, 102)

-- Bus restriction values

insert into #bus_restriction
values(200, 100), (201, 101), (502, 102)

-- BUSINESS QUESTION

/*
The company wants to know the cleaner name, driver name and the completion date of the training of drivers who drive bustype 202
*/

select cleaner_name, driver_name, passed_training_date
from #cleaner as a
join #bus_type as b
on a.bus_reg_num =  b.bus_reg_num
join #driver as c
on b.driver_employ_num = c.driver_employ_num
join #driver_training as d
on c.driver_employ_num = d.driver_employ_num
where d.bus_type_id = 202

-- Cleaner: Emiel Caron, Driver: Maksim Arinkin, Training completion date: April 1st 2020

-- DROP TABLES
drop table #depot, #bus, #bus_type, #cleaner, #driver, #driver_training, #bus_route, #driver_ability, #bus_restriction