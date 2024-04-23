create database Forbes;
Use Forbes;

create table top_companies(
Ranking int primary key,
Organization_Name varchar(50),
Industry varchar(50),
Country varchar(25),
Year_Founded int);

select * from companies_revenue;

desc top_companies;
# used to check structure of the data 

create table companies_revenue(
Organization_Name varchar(50),
Revenue float,
Profit float);
desc companies_revenue;
# used to check structure of the data 

#Change the coloumn name to revenue_billions
ALTER TABLE COMPANIES_REVENUE RENAME COLUMN REVENUE TO Revenue_billions;
ALTER TABLE COMPANIES_REVENUE RENAME COLUMN Profit TO Profit_billions;
#change the column names to new column names

create table companies_Assests(
Ranking int,
Organization_Name varchar(50),
Industry varchar(50),
Country varchar(25),
Assets_billions float,
Market_value_billions float,
Total_employees int);

# added primary key to the table
ALTER TABLE companies_assests 
ADD primekey_column INT AUTO_INCREMENT PRIMARY KEY;

Desc companies_assests;

# add foreign key to the table company_assests
alter table companies_Assests add foreign key(ranking)
references top_companies(ranking) on delete restrict; 

#update revenue of the organization jpmorgan chase as per 2023  
Update companies_revenue set revenue_billions = 158.1 
where Organization_Name = 'JPMorgan Chase';

#Display all the organiztion names starting with JP
select * from companies_revenue where Organization_Name like 'JP%';

#Display companies which has revenues between 158 and 160
select* from companies_revenue
where Revenue_billions between 158 and 160;

#Display all the null records from revenue
select * from  companies_revenue 
where Revenue_billions is null;

/*display the respective ranking,organization name, year and country where 
the company is founded in the year 1960 and later or the country is India */
select ranking,Organization_Name,Year_Founded,
country from top_companies
where Year_Founded >= 1960 or country='india';

/*display the respective countries and assests values related to banking industy
with total employees more than 150000 */
select country,assets_billions from companies_assests
where Industry= 'Banking'and Total_employees <150000;

/* display country,total assests value of the countries more than 10000 billions,
total count of organizations present in each country. */
select country , sum(assets_billions)as total_assests_Bycountry,
count(Organization_Name) as numberoforg
from companies_assests group by country having sum(assets_billions) > 10000;

#*Display the top 20 organizations in terms of profit
select Organization_Name, Profit_billions from companies_revenue
order by Profit_billions desc limit 20;

#Display only the matching records for companies_revenue and companies_assests
select *from companies_revenue inner join companies_assests 
using(Organization_Name);
 
/*Display the matching records for 
 Organization_Name,Revenue_billions,Market_value_billions*/
select Organization_Name,Revenue_billions,Market_value_billions 
from companies_revenue inner join companies_assests 
using(Organization_Name);
 
/* Display Organization name, founded year,country and profit where all records
 from top_companies should be considered*/
 select ranking,organization_name,Year_Founded,Country,Profit_billions 
 from top_companies left join companies_revenue using(Organization_Name) 
 order by profit_billions;

#display organization_names with profits less than the avg profits.
select organization_name,Profit_billions
from companies_revenue where Profit_billions
 <(select avg(Profit_billions )from companies_revenue);

/*display the average of profits and total sum of profits made by
 IT Software & Services industry*/
select avg(Profit_billions),sum(Profit_billions), Industry from
(select* from companies_revenue inner join companies_assests
 using(organization_name) 
 where companies_assests.industry= 'IT Software & Services')
 as it_services;

/*Display details such as country ,year founded and indutry type of latest 
organization establlished write in upper case */
select upper(country) as Country,upper(organization_name) 
as Orgname,year_founded, upper(Industry) as industry 
from top_companies where year_founded
=(select max(year_founded) from top_companies);

#Give rounded values of revenues and market values 
select Organization_Name,round(Revenue_billions),round(Market_value_billions) 
from companies_revenue inner join companies_assests 
using(Organization_Name);

#Divide the profit into 4 equal parts in descending order
select Organization_Name, Profit_billions,
ntile(4) over (order by Profit_billions  desc)
as quartiles from companies_revenue;

#Display the total of market values,industry partion by countries
#partition rows of table into groups
select Country, Industry,sum(Market_value_billions) 
over (partition by Country) as
sumof_marketvalue from companies_assests;

#Display Total number of years the organizations has worked till 2022
DELIMITER //
CREATE FUNCTION total_years(years int) RETURNS int 
DETERMINISTIC
BEGIN
  RETURN 2022-(years);
END;
//
Select Organization_Name,Industry,total_years(year_founded) 
as 'totalyears' from top_companies;


/* Display the companies status where
 1.if company is founded after 1974 then diplay relatively new company
 2.if company is founded before 1974 then diplay relatively old company */
select Organization_Name,year_founded,
if(year_founded>1974,'Relatively new company','Relatively old company')
as status_of_company from top_companies;

/*Displat no. of employees as 
1. if > 100000 then higher 
2.if > 50000 then average
3. else low */
select Organization_Name,Industry,total_employees,
case when total_employees >100000 then 'high number of employees working'
when total_employees >50000 then 'Average number of employees working'
else 'low number of employees working'
end as status_employees from companies_assests;

#Display ogname,industry,country founded in 1980 as a virtual table
create index y_f on top_companies(year_founded); #imrroves speed of operation
create view companies_1980 as
select Organization_Name,Industry,country
from top_companies where year_founded=1980;
select* from companies_1980;

/* Create a trigger where name of organization and 25%of its revenue will get 
stored automatically from new records inserted into companies_revenue table */
create table 4th_of_revenue (
Organization_Name varchar(50),
revenue_billions float);

delimiter //  
create trigger update_rev before insert on companies_revenue
for each row
begin
insert into 4th_of_revenue 
values (new.Organization_Name,new.revenue_billions*0.25);
end; 
 //
 delimiter ;
 
 insert into companies_revenue values('Asian paints',8,0.87),
('Landmark Group',4.8,0.2) ;
 select * from 4th_of_revenue;

