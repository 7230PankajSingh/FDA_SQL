create database FDA_Data;
use FDA_data;
-- Data Updation Test
SELECT * FROM appdoctype_lookup LIMIT 20;
select * from regactiondate;
select * from Appdoc;
select * from product;
select * from Application;

-- Task 1: Identifying Approval Trends
-- 1. Determine the number of drugs approved each year and provide insights into the yearly trends.
select year(ActionDate) As "Drugs Approved Year",
Count(*) As "No. of Drugs Approved"
from regactiondate where ActionType = "AP"
group by year(ActionDate) order by year(ActionDate) desc;

-- Alter by Join
Select year(regactiondate.ActionDate) As 'Drugs_Approved_Year',
Count(product.drugname) as Approved_Drugs_Count from regactiondate Join product
on regactiondate.ApplNo=product.ApplNo
where regactiondate.ActionType = "AP"
group by year(regactiondate.ActionDate) order by year(regactiondate.ActionDate) desc;

-- 2(i) Identify the top three years that got the highest approvals, in descending and ascending order, respectively.
select year(ActionDate) As "Drugs Approved Year",
Count(*) As "No. of Drugs Approved"
from regactiondate where ActionType = "AP"
group by year(ActionDate) order by Count(*) desc limit 3;

-- 2 (ii) Identify the top three years that got the lowest approvals, in descending and ascending order, respectively
select year(ActionDate) As "Drugs Approved Year",
Count(*) As "No. of Drugs Approved"
from regactiondate where ActionType = "AP"
group by year(ActionDate) order by Count(*) asc limit 4;

-- 3. Explore approval trends over the years based on sponsors. 
Select year(regactiondate.ActionDate) As 'Drugs_Approved_Year',
application.SponsorApplicant,
Count(product.drugname) as Approved_Drugs_Count 
from regactiondate Join product on regactiondate.ApplNo=product.ApplNo
Join Application on product.ApplNo=Application.ApplNo 
where regactiondate.ActionType = "AP"
group by year(regactiondate.ActionDate), application.SponsorApplicant
order by year(regactiondate.ActionDate) Asc, Count(product.drugname) desc;

-- 4. Rank sponsors based on the total number of approvals they received each year between 1939 and 1960.
Select application.SponsorApplicant, Count(application.ApplNo) As "Total No. Of Approval",
Rank () over (partition by Year(regactiondate.ActionDate) order by Count(application.ApplNo) desc) As "Sponsor Rank wrt Approval"
from application join regactiondate on application.ApplNo = regactiondate.ApplNo 
where regactiondate.ActionType = "AP" and Year(regactiondate.ActionDate) between 1938 and 1960
group by application.SponsorApplicant, Year(regactiondate.ActionDate) order by Year(regactiondate.ActionDate);


-- Task 2: Segmentation Analysis Based on Drug MarketingStatus
-- 1. Group products based on MarketingStatus. Provide meaningful insights into the segmentation patterns.
Select drugname, ProductMktStatus from Product 
group by ProductMktStatus, drugname;

Select ProductMktStatus, Count(ApplNo) As Product_Count
from Product group by ProductMktStatus
order by Product_Count desc;

-- 2. Calculate the total number of applications for each MarketingStatus year-wise after the year 2010. 
Select Year(regactiondate.ActionDate) As Year, product.ProductMktStatus,
Count(Product.ApplNo) As Total_application_No from product
Join regactiondate on product.ApplNo = regactiondate.ApplNo where Year(regactiondate.ActionDate)>2010
group by product.ProductMktStatus, Year(regactiondate.ActionDate)
order by Year(regactiondate.ActionDate), Count(Product.ApplNo) desc;

-- 3. Identify the top MarketingStatus with the maximum number of applications and analyze its trend over time.

-- 3.1 Identify the top MarketingStatus with the maximum number of applications
Select ProductMktStatus, Count(ApplNo) As "No. of Applications"
from product group by ProductMktStatus order by Count(ApplNo) desc limit 1;
-- "1" denote Marketed So, We have to find the Years_Wise- Trends of Product Marketed

-- 3.2 analyze its trend over time. 
Select Year(regactiondate.ActionDate) As Year, product.ProductMktStatus,
Count(Product.ApplNo) As Total_application_No from product
Join regactiondate on product.ApplNo = regactiondate.ApplNo
where product.ProductMktStatus = "1" 
group by product.ProductMktStatus, Year(regactiondate.ActionDate)
order by Year(regactiondate.ActionDate) desc;

-- Task 3: Analyzing Products
-- 1. Categorize Products by dosage form and analyze their distribution.
Select Form, Count(ProductNo) As "No. of Products"
from product group by Form order by Count(ProductNo) desc;

-- 2. Calculate the total number of approvals for each dosage form and identify the most successful forms.
Select product.form, Count(Application.ActionType) As "Total No. of Approvals"
from product join Application on product.ApplNo = Application.ApplNo
where Application.ActionType = "AP" group by product.form
order by Count(Application.ActionType) desc limit 5;

-- Alter Prefered one
Select product.form, Count(regactiondate.ActionType) As "Total No. of Approvals"
from product join regactiondate on product.ApplNo = regactiondate.ApplNo
where regactiondate.ActionType = "AP" group by product.form
order by Count(regactiondate.ActionType) desc limit 5;

-- 3. Investigate yearly trends related to successful forms. 
Select Year(regactiondate.ActionDate) As Year, Count(product.form) As "Most Sucessful Dosage Form"
from product Join regactiondate on product.ApplNo = regactiondate.ApplNo
where product.form = "TABLET;ORAL" 
group by Year(regactiondate.ActionDate)
order by Year(regactiondate.ActionDate) asc;

-- Task 4: Exploring Therapeutic Classes and Approval Trends
-- 1. Analyze drug approvals based on the therapeutic evaluation code (TE_Code).
Select product.TECode, Count(regactiondate.ActionType) As "Total No. of Approvals"
from product join regactiondate on product.ApplNo = regactiondate.ApplNo
where regactiondate.ActionType = "AP" group by product.TECode
order by Count(regactiondate.ActionType) desc;

-- 2. Determine the therapeutic evaluation code (TE_Code) with the highest number of Approvals in each year.
Select Yeardata.Year, Yeardata.TECode, Yeardata.Total_No_of_Approvals
from (
select Year(regactiondate.ActionDate) As Year, product.TECode,
Count(regactiondate.ActionType) As Total_No_of_Approvals,
Rank () over (partition by Year(regactiondate.ActionDate) order by Count(regactiondate.ActionType) desc) As ActionTypeRank
from product join regactiondate on product.ApplNo = regactiondate.ApplNo
group by Year(regactiondate.ActionDate), product.TECode)
As Yeardata
WHERE YearData.ActionTypeRank = 1
ORDER BY YearData.Year desc, YearData.Total_No_of_Approvals DESC;















