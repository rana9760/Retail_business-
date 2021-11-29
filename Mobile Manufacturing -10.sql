
--Answer 1

select Country,City,Date,TotalPrice,Quantity from DIM_LOCATION a
join FACT_TRANSACTIONS b on a.IDLocation = b.IDLocation 
join DIM_CUSTOMER c on b.idcustomer = c.idcustomer
where Date >= '2005'
order by date asc



 --Answer 2

select  Top 1 manufacturer_Name, Country,State ,Count(State)Max_User from DIM_MANUFACTURER a
join DIM_MODEL b on a.IDManufacturer = b.idmanufacturer
join FACT_TRANSACTIONS c on b.idmodel = c.idmodel
join DIM_LOCATION d on c.idlocation = d.idlocation
where manufacturer_Name ='Samsung' and Country = 'US'
group by manufacturer_Name, Country, State
order by Count(State) desc


--Answer 3

select Model_name,Zipcode,State,City,Count(*)Total from DIM_LOCATION a
join FACT_TRANSACTIONS b on a.idlocation = b.idlocation 
join DIM_MODEL c on b.idmodel = c.idmodel
group by Model_name,Zipcode,State,City
order by 5 desc

--Answer 4

select *from DIM_MANUFACTURER a
join DIM_MODEL b on a.IDManufacturer = b.IDManufacturer
where Unit_price = (select MIN(Unit_price)from DIM_MODEL)


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


--Answer 6

select Customer_Name,Date,avg(TotalPrice)AMTspent from FACT_TRANSACTIONS a
join DIM_CUSTOMER b on a.IDCustomer = b.IDCustomer
where YEAR(Date) = '2009'
group by Customer_Name,Date
having avg(TotalPrice) > 500 


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


--Answer 9

select Model_Name,Date from FACT_TRANSACTIONS a
join DIM_MODEL b on a.IDModel = b.IDModel
where  year(date) in ('2010', '2009')

except

select Model_Name,Date from FACT_TRANSACTIONS a
join DIM_MODEL b on a.IDModel = b.IDModel
where  year(date) = '2009'


--Answer 10


select Top 100 Customer_Name, DATEPART (year,Date) year, AVG(TotalPrice) AvgSpend,AVG(Quantity) AvgQTY,
((AVG(TotalPrice) -LAG ( Avg (TotalPrice) ) over (PARTITION by Customer_Name order by datepart (year,Date) ASC))/
AVG (TotalPrice)) * 100 Percentage_Change_In_spend
from FACT_TRANSACTIONS a
join DIM_CUSTOMER b on a.IDCustomer = b.IDCustomer
group by Datepart (year,Date),b.Customer_Name
order by b.Customer_Name,year asc




