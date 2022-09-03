--- DATA PREPARATION AND UNDERSTANDING---

-- 1.	What is the total number of rows in each of the 3 tables in the database?
--Anwer 1
select * 
    from (
       select COUNT(*)TotalRow from CUSTOMER 
union all
       select COUNT(*)TotalProduct from PROD_CAT_INFO
union all
       select COUNT(*)TotalTransaction from TRANSACTIONS
	   )abc


--2.	What is the total number of transactions that have a return??
--Answer 2
select COUNT(TRANSACTION_ID) Total_No_Of_Transaction from TRANSACTIONS 
      where QTY <0   

--3.	As you would have noticed, the dates provided across the datasets are not in a correct format. 
--         As first steps, pls convert the date variables into valid date formats before proceeding ahead.? 
---Answer 3

select dob,convert(date , DOB,103)New_date ,tran_date, convert(date , TRAN_DATE,103)new_date
		from CUSTOMER a join TRANSACTIONS b on a.CUSTOMER_ID = b.CUST_ID

 ----- OR -----
/*select * 
from (
       select convert(date , DOB,103)New_date from CUSTOMER 
        union all
	    select convert(date , TRAN_DATE,103)new_date from TRANSACTIONS 
		)a */

-- 4.	What is the time range of the transaction data available for analysis? Show the output in number of days, months and years simultaneously in different columns?
-- Answer 4

Select * from (
         select year(convert(date , TRAN_DATE,103))years,month(convert(date , TRAN_DATE,103))month,
         day(convert(date , TRAN_DATE,103))day
         from TRANSACTIONS)TS,
                          (select ABS(DATEDIFF(DAY,MAX(convert(date ,TRAN_DATE,103)) , MIN(convert(date , TRAN_DATE,103))))Time_Range
          from TRANSACTIONS)TD

-- 5.	Which product category does the sub-category “DIY” belong to?
-- Answer 5

   select PROD_CAT  from  PROD_CAT_INFO
   where PROD_SUBCAT = 'DIY'


---- ######## DATA ANALYSIS ########## --

-- 1.	Which channel is most frequently used for transactions?
--Answer 1

select TOP 1 STORE_TYPE,count(STORE_TYPE)MAX_USE from TRANSACTIONS
group by STORE_TYPE
order by 2 desc

-- 2.	What is the count of Male and Female customers in the database?
--Answer 2

select TOP 2 gender,count(gender)Total_Customer from CUSTOMER
group by gender
order by 2 desc

--3.	From which city do we have the maximum number of customers and how many?
--Answer 3

select Top 1  CITY_CODE,COUNT(CUSTOMER_ID)Max_Customer from CUSTOMER
group by CITY_CODE
order by 2 desc

-- 4.	How many sub-categories are there under the Books category?
--Answer 4

SELECT PROD_CAT,COUNT(PROD_SUBCAT)Total_SUBCAT FROM PROD_CAT_INFO 
where PROD_CAT='books'
GROUP BY PROD_CAT

-- 5.	What is the maximum quantity of products ever ordered?
--Answer 5

Select Top 1 PROD_CAT_CODE,Sum(QTY)Max_Qty_Product from TRANSACTIONS
where QTY >0
group by PROD_CAT_CODE
order by Sum(QTY) desc

---- OR-------

Select  PROD_CAT_CODE,Max(QTY)Max_Qty_Orderd from TRANSACTIONS
where QTY >0
group by PROD_CAT_CODE
order by Max(QTY) desc

-- 6.	What is the net total revenue generated in categories Electronics and Books?
--Answer 6

 select  PROD_CAT,SUM(TOTAL_AMT)Total_revenue from PROD_CAT_INFO a
      join TRANSACTIONS b on a.PROD_CAT_CODE=b.PROD_CAT_CODE and a.PROD_SUB_CAT_CODE=b.PROD_SUBCAT_CODE
      Where  PROD_CAT in ('Electronics' ,'Books')
      group by PROD_CAT

--7.	How many customers have >10 transactions with us, excluding returns?
--Answer 7

select CUSTOMER_ID,count( TRANSACTION_ID) No_of_transcation from CUSTOMER a
join TRANSACTIONS b on a.CUSTOMER_ID = b.CUST_ID
where QTY >0
group by CUSTOMER_ID
having count( TRANSACTION_ID) >10

--8.	What is the combined revenue earned from the “Electronics” & “Clothing” categories, from “Flagship stores”?
--Answer 8

select STORE_TYPE,SUM(TOTAL_AMT)Combined_revenue from PROD_CAT_INFO a
inner join TRANSACTIONS b on a.PROD_CAT_CODE=b.PROD_CAT_CODE and a.PROD_SUB_CAT_CODE = b.PROD_SUBCAT_CODE
Where  PROD_CAT in ('Electronics' ,'Books') 
GRoup by STORE_TYPE
having STORE_TYPE ='Flagship store'

-- 9.	What is the total revenue generated from “Male” customers in “Electronics” category? Output should display total revenue by prod sub-cat.
--ANSWER 9

select PROD_SUBCAT,SUM((TOTAl_AMT ))Total_revenue from CUSTOMER a --where gender ='M'
join TRANSACTIONS b on a.CUSTOMER_ID = b.CUST_ID
join PROD_CAT_INFO c on b.PROD_CAT_CODE = c.PROD_CAT_CODE and b.PROD_SUBCAT_CODE = c.PROD_SUB_CAT_CODE
where gender = 'M' and PROD_CAT = 'Electronics'
group by PROD_SUBCAT 

--10.	What is percentage of sales and returns by product sub category; display only top 5 sub categories in terms of sales?
--Answe 10

select     * from (
      select  PROD_SUBCAT_CODE, ((sum(TOTAL_AMT)/(select SUM(TOTAL_AMT) from TRANSACTIONS))*100) perSales from TRANSACTIONS
	  group by PROD_SUBCAT_CODE 
	  order by ((sum(TOTAL_AMT)/(select SUM(TOTAL_AMT) from TRANSACTIONS))*100) desc ) a
      ,
      ( select PROD_SUBCAT_CODE, ((sum(QTY)/(select SUM(QTY) from TRANSACTIONS))*100)perTotal_Return from TRANSACTIONS
       where qty<0 
	   group by PROD_SUBCAT_CODE) b,
	   
	   (select *,dense_rank()  over (partition by PROD_SUBCAT_CODE order by perSales desc)DRnk from TRANSACTIONS)c
	   
`
	   
 
  select Top 5 PROD_SUBCAT_CODE, ((sum(TOTAL_AMT)/(select SUM(TOTAL_AMT) from TRANSACTIONS))*100) perSales 
   , ((sum(QTY)/(select SUM(QTY) from TRANSACTIONS))*100)perTotal_Return from TRANSACTIONS
	    group by PROD_SUBCAT_CODE 
	    order by ((sum(TOTAL_AMT)/(select SUM(TOTAL_AMT) from TRANSACTIONS))*100) desc 
		




/*select PROD_SUBCAT_CODE,qty from TRANSACTIONS
       where qty<0

select   * from(
      select PROD_SUBCAT_CODE,((sum(QTY)/(select SUM(QTY) from TRANSACTIONS))*100)per from TRANSACTIONS
	  group by PROD_SUBCAT_CODE)a
      ,
      (select  SUM(PROD_SUBCAT_CODE)Total_Return from TRANSACTIONS
       where qty<0)b
	   order by per desc	
	
	select PROD_SUBCAT_CODE,SUM(QTY)--,((( SUM(QTY))/(select SUM(QTY) from TRANSACTIONS))*100)per)
	   from TRANSACTIONS
       group by PROD_SUBCAT_CODE
	   
	   having qty <0
       order by 2 desc
   
   Count(PROD_SUBCAT_CODE)Total_Return FROM TRANSACTIONS
   where qty<0
   group by PROD_SUBCAT_CODE,QTY 

--select ref_no, profit,round((profit/(select avg(profit) from TBL_ORDER))*100,0) PerProfit,*/



-- 11.	For all customers aged between 25 to 35 years find what is the net total revenue generated by these consumers in last 30 days of transactions
 --                          from max transaction date available in the data?
--Answer 11

select SUM(Total_AMT) Total_Revenue from TRANSACTIONS a
 join CUSTOMER b on a.CUST_ID = b.CUSTOMER_ID
 where (DATEDIFF(year,(convert(date,DOB,103)),GETDATE()) between 25 and 35)
 and (DATEDIFF (DAY,convert(date,tran_date,103), (Select Max(Convert (date,tran_date,103)) from TRANSACTIONS) ) <= 30)

-- 12.	Which product category has seen the max value of returns in the last 3 months of transactions?
--Answer 12

with abc as
    (select convert(date , TRAN_DATE,103)new_date,* from TRANSACTIONS)
  
,xyz as (select * from PROD_CAT_INFO)

	select Top 1 PROD_CAT,Sum(qty)Max_Return from abc a  
	join xyz b on a.PROD_CAT_CODE = b.PROD_CAT_CODE and a.PROD_SUBCAT_CODE = b.PROD_SUB_CAT_CODE 
	where new_date >= dateadd (day,-90,'2014-02-28')
	and qty <0 
	group by PROD_CAT
	order by 2 asc


-- 13.	Which store-type sells the maximum products; by value of sales amount and by quantity sold?
--ANSWER 13 --

select Top 1 STORE_TYPE,SUM(TOTAL_AMT)Total_Sales_AMT,SUM(QTY)Total_QTY  from TRANSACTIONS
group by STORE_TYPE
order by SUM(TOTAL_AMT) desc

-- 14.	What are the categories for which average revenue is above the overall average.
--ANSWER 14 --

select  PROD_CAT ,AVG(TOTAL_AMT)Avg_Revenue from PROD_CAT_INFO a
join TRANSACTIONS b on a.PROD_CAT_CODE = b.PROD_CAT_CODE
GROUP BY PROD_CAT
having AVG(TOTAL_AMT) > (select AVG(TOTAL_AMT) from TRANSACTIONS)
order by AVG(TOTAL_AMT) desc


-- 15.	Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold
--ANSWER 15 --

select top 5 PROD_CAT,PROD_SUBCAT,count(TOTAL_AMT)Total_revenue,round(AVG(TOTAL_AMT),0 )Total_avg,Sum(Qty)Quantity_Sold from PROD_CAT_INFO a
join TRANSACTIONS b on a.PROD_CAT_CODE = b.PROD_CAT_CODE and a.PROD_SUB_CAT_CODE =b.PROD_SUBCAT_CODE
where qty >0
group by PROD_CAT,PROD_SUBCAT
order by 5 desc



