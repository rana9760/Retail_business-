--- DATA PREPARATION AND UNDERSTANDING---

--Anwer 1
select * 
    from (
       select COUNT(*)TotalRow from CUSTOMER 
union all
       select COUNT(*)TotalProduct from PROD_CAT_INFO
union all
       select COUNT(*)TotalTransaction from TRANSACTIONS
	   )abc



--Answer 2
select COUNT(TRANSACTION_ID) Total_No_Of_Transaction from TRANSACTIONS 
      where QTY <0   

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


-- Answer 4

Select * from (
         select year(convert(date , TRAN_DATE,103))years,month(convert(date , TRAN_DATE,103))month,
         day(convert(date , TRAN_DATE,103))day
         from TRANSACTIONS)TS,
                          (select ABS(DATEDIFF(DAY,MAX(convert(date ,TRAN_DATE,103)) , MIN(convert(date , TRAN_DATE,103))))Time_Range
          from TRANSACTIONS)TD

-- Answer 5

   select PROD_CAT  from  PROD_CAT_INFO
   where PROD_SUBCAT = 'DIY'


---- ######## DATA ANALYSIS ########## --

--Answer 1

select TOP 1 STORE_TYPE,count(STORE_TYPE)MAX_USE from TRANSACTIONS
group by STORE_TYPE
order by 2 desc

--Answer 2

select TOP 2 gender,count(gender)Total_Customer from CUSTOMER
group by gender
order by 2 desc

--Answer 3

select Top 1  CITY_CODE,COUNT(CUSTOMER_ID)Max_Customer from CUSTOMER
group by CITY_CODE
order by 2 desc

--Answer 4

SELECT PROD_CAT,COUNT(PROD_SUBCAT)Total_SUBCAT FROM PROD_CAT_INFO 
where PROD_CAT='books'
GROUP BY PROD_CAT

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


--Answer 6

 select  PROD_CAT,SUM(TOTAL_AMT)Total_revenue from PROD_CAT_INFO a
      join TRANSACTIONS b on a.PROD_CAT_CODE=b.PROD_CAT_CODE and a.PROD_SUB_CAT_CODE=b.PROD_SUBCAT_CODE
      Where  PROD_CAT in ('Electronics' ,'Books')
      group by PROD_CAT


--Answer 7

select CUSTOMER_ID,count( TRANSACTION_ID) No_of_transcation from CUSTOMER a
join TRANSACTIONS b on a.CUSTOMER_ID = b.CUST_ID
where QTY >0
group by CUSTOMER_ID
having count( TRANSACTION_ID) >10

--Answer 8

select STORE_TYPE,SUM(TOTAL_AMT)Combined_revenue from PROD_CAT_INFO a
inner join TRANSACTIONS b on a.PROD_CAT_CODE=b.PROD_CAT_CODE and a.PROD_SUB_CAT_CODE = b.PROD_SUBCAT_CODE
Where  PROD_CAT in ('Electronics' ,'Books') 
GRoup by STORE_TYPE
having STORE_TYPE ='Flagship store'

--ANSWER 9


select PROD_SUBCAT,SUM((TOTAl_AMT ))Total_revenue from CUSTOMER a --where gender ='M'
join TRANSACTIONS b on a.CUSTOMER_ID = b.CUST_ID
join PROD_CAT_INFO c on b.PROD_CAT_CODE = c.PROD_CAT_CODE and b.PROD_SUBCAT_CODE = c.PROD_SUB_CAT_CODE
where gender = 'M' and PROD_CAT = 'Electronics'
group by PROD_SUBCAT 

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




--Answer 11


select SUM(Total_AMT) Total_Revenue from TRANSACTIONS a
 join CUSTOMER b on a.CUST_ID = b.CUSTOMER_ID
 where (DATEDIFF(year,(convert(date,DOB,103)),GETDATE()) between 25 and 35)
 and (DATEDIFF (DAY,convert(date,tran_date,103), (Select Max(Convert (date,tran_date,103)) from TRANSACTIONS) ) <= 30)


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



--ANSWER 13 --

select Top 1 STORE_TYPE,SUM(TOTAL_AMT)Total_Sales_AMT,SUM(QTY)Total_QTY  from TRANSACTIONS
group by STORE_TYPE
order by SUM(TOTAL_AMT) desc

--ANSWER 14 --

select  PROD_CAT ,AVG(TOTAL_AMT)Avg_Revenue from PROD_CAT_INFO a
join TRANSACTIONS b on a.PROD_CAT_CODE = b.PROD_CAT_CODE
GROUP BY PROD_CAT
having AVG(TOTAL_AMT) > (select AVG(TOTAL_AMT) from TRANSACTIONS)
order by AVG(TOTAL_AMT) desc


--ANSWER 15 --

select top 5 PROD_CAT,PROD_SUBCAT,count(TOTAL_AMT)Total_revenue,round(AVG(TOTAL_AMT),0 )Total_avg,Sum(Qty)Quantity_Sold from PROD_CAT_INFO a
join TRANSACTIONS b on a.PROD_CAT_CODE = b.PROD_CAT_CODE and a.PROD_SUB_CAT_CODE =b.PROD_SUBCAT_CODE
where qty >0
group by PROD_CAT,PROD_SUBCAT
order by 5 desc



