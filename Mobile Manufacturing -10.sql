-- Question 1
List All the states in which we have customer who have bought cellphones from 2005 till date ?


--Answer 1

select Country,City,Date,TotalPrice,Quantity from DIM_LOCATION a
join FACT_TRANSACTIONS b on a.IDLocation = b.IDLocation 
join DIM_CUSTOMER c on b.idcustomer = c.idcustomer
where Date >= '2005'
order by date asc


--- Question 2

which state in the us buying more samsung cell phones ?
 --Answer 2

select  Top 1 manufacturer_Name, Country,State ,Count(State)Max_User from DIM_MANUFACTURER a
join DIM_MODEL b on a.IDManufacturer = b.idmanufacturer
join FACT_TRANSACTIONS c on b.idmodel = c.idmodel
join DIM_LOCATION d on c.idlocation = d.idlocation
where manufacturer_Name ='Samsung' and Country = 'US'
group by manufacturer_Name, Country, State
order by Count(State) desc

-- Question 3
Show the number transcation for each model per zip code per state?

--Answer 3

select Model_name,Zipcode,State,City,Count(*)Total from DIM_LOCATION a
join FACT_TRANSACTIONS b on a.idlocation = b.idlocation 
join DIM_MODEL c on b.idmodel = c.idmodel
group by Model_name,Zipcode,State,City
order by 5 desc

-- Question 4
Show the cheapest cellphones ?

--Answer 4

select *from DIM_MANUFACTURER a
join DIM_MODEL b on a.IDManufacturer = b.IDManufacturer
where Unit_price = (select MIN(Unit_price)from DIM_MODEL)

-- Question 5
Find out the average price for each model in the top 5 manufacturer  in terms of sales quantity and order by average price ?

--Answer 5

select * 
    from(
         select   Manufacturer_Name,Model_Name,Count(Quantity)QTY ,avg(Unit_price)AvgUnitPrice,avg(TotalPrice)AvgTotalPrice,
            Row_number() over (order by  Count(Quantity) desc)Rownum from DIM_MODEL a
			join DIM_MANUFACTURER b on a.IDManufacturer = b.IDManufacturer
			join FACT_TRANSACTIONS c on a.IDModel =c.IDModel
			group by Model_Name,Manufacturer_Name
		)F
	where Rownum <=5               
	order by AvgUnitPrice desc

--Question 6 
List the name of customer and the average amount spent in 2009 , where the average is higher than 500 ?
--Answer 6

select Customer_Name,Date,avg(TotalPrice)AMTspent from FACT_TRANSACTIONS a
join DIM_CUSTOMER b on a.IDCustomer = b.IDCustomer
where YEAR(Date) = '2009'
group by Customer_Name,Date
having avg(TotalPrice) > 500 

-- Question 7
List if there is any model that was in top 5 in terms of quantity , simultaneously in 2008 , 2009 and 2010 ?
--Answer 7

select a.Model_Name from (		  
		   select Top 5 Model_Name,SUM(Quantity) TotalQTY from FACT_TRANSACTIONS a
          join DIM_MODEL b on a.IDModel = b.IDModel
          where YEAR(Date) in ('2008')  
		  group by Model_Name
		  order by SUM(Quantity) desc)a

		  	   intersect	
select  b.Model_Name from (		  
		  select Top 5 Model_Name,SUM(Quantity) TotalQTY from FACT_TRANSACTIONS a
		  join DIM_MODEL b on a.IDModel = b.IDModel
          where YEAR(Date) in ('2009')
		  group by Model_Name
		  order by SUM(Quantity) desc ) b
     
	  intersect    
		 
select  c.Model_Name from (	
         select Top 5 Model_Name,SUM(Quantity) TotalQTY from FACT_TRANSACTIONS a
         join DIM_MODEL b on a.IDModel = b.IDModel
          where YEAR(Date) in ('2010')
		  group by Model_Name
		  order by SUM(Quantity) desc
		  )c

---- Question 8
-- Show the manufacturer with second top sales in the year 2009 and the manfacturer with 2 top sales in the year 2010 ?
--Answer 8

-- This is I have done with Union all but in this I have got record all in two column with same header. But othqr query i have used different way so that value not come in same column  it will come in different column.
/*select * from (
select Manufacturer_Name,Model_Name,Count(Quantity)TotalQTY,Count(TotalPrice)TotalPrice
,dense_rank() over (order by Count(Quantity) desc)DRank from FACT_TRANSACTIONS a
join DIM_MODEL b on a.IDModel = b.IDModel
join DIM_MANUFACTURER c on b.IDManufacturer = c.IDManufacturer
where year(Date) = '2010'
group by Manufacturer_Name,Model_Name) a
where DRank = 2

union all

select * from(
select Manufacturer_Name,Model_Name,Count(Quantity)TotalQTY,Count(TotalPrice)TotalPrice
,dense_rank() over (order by Count(Quantity) desc)DRank from FACT_TRANSACTIONS a
join DIM_MODEL b on a.IDModel = b.IDModel
join DIM_MANUFACTURER c on b.IDManufacturer = c.IDManufacturer
where year(Date) = '2009' 
group by Manufacturer_Name,Model_Name )a
where DRank = 2*/



-- Here I have used Subquery
select * from (
           select Manufacturer_Name,Model_Name,Count(Quantity)TotalQTY
           ,dense_rank() over (order by Count(Quantity) desc)DRank from FACT_TRANSACTIONS a
           join DIM_MODEL b on a.IDModel = b.IDModel
           join DIM_MANUFACTURER c on b.IDManufacturer = c.IDManufacturer
           where year(Date) = '2010' 
           group by Manufacturer_Name,Model_Name  )a,

       (select   Manufacturer_Name,Model_Name,Count(Quantity)TotalQTY
        ,dense_rank() over (order by Count(Quantity) desc) DRank from FACT_TRANSACTIONS a
        join DIM_MODEL b on a.IDModel = b.IDModel
        join DIM_MANUFACTURER c on b.IDManufacturer = c.IDManufacturer
        where year(Date) = '2009' 
        group by Manufacturer_Name,Model_Name)b

where a.DRank = 2 and b.DRank = 2

-- Question 9
-- Show the manfacturer that sold cellphone in 2010 but didn't in 2009 ?
--Answer 9

select Model_Name,Date from FACT_TRANSACTIONS a
join DIM_MODEL b on a.IDModel = b.IDModel
where  year(date) in ('2010', '2009')

except

select Model_Name,Date from FACT_TRANSACTIONS a
join DIM_MODEL b on a.IDModel = b.IDModel
where  year(date) = '2009'


-- Find top 100 customer and their average spend , average quantity by each year .Also find the percentage of change in their spend ?
--Answer 10


select Top 100 Customer_Name, DATEPART (year,Date) year, AVG(TotalPrice) AvgSpend,AVG(Quantity) AvgQTY,
((AVG(TotalPrice) -LAG ( Avg (TotalPrice) ) over (PARTITION by Customer_Name order by datepart (year,Date) ASC))/
AVG (TotalPrice)) * 100 Percentage_Change_In_spend
from FACT_TRANSACTIONS a
join DIM_CUSTOMER b on a.IDCustomer = b.IDCustomer
group by Datepart (year,Date),b.Customer_Name
order by b.Customer_Name,year asc




