-- (Query 1) Leads Gender
-- Columns: gender, leads(#)

SELECT 
	CASE 
		WHEN ibge.gender = 'male' THEN 'Men'
		WHEN ibge.gender = 'female' THEN 'Women'
		END AS "Gender",
	COUNT(*) AS "leads"
FROM sales.customers AS cus
LEFT JOIN temp_tables.ibge_genders AS ibge
	ON LOWER(cus.first_name) = lower(ibge.first_name)
GROUP BY ibge.gender

-- (Query 2) Leads Professional Status
-- Columns: professional status, leads (%)
SELECT 
	professional_status,
	(COUNT(*)::FLOAT)/(SELECT COUNT(*) FROM sales.customers) AS "leads (%)"
FROM sales.customers
GROUP BY professional_status
ORDER BY "leads (%)" 
	


-- (Query 3) Leads Age Group
-- Columns: age group, leads (%)
CREATE FUNCTION DATEDIFF(unidade varchar, data_inicial date, data_final date)
RETURNS INTEGER
LANGUAGE SQL
AS
$$
	SELECT
		CASE
			WHEN unidade in ('d', 'day', 'days') THEN (data_final - data_inicial)
			WHEN unidade in ('w', 'week', 'weeks') THEN (data_final - data_inicial)/7
			WHEN unidade in ('m', 'month', 'months') THEN (data_final - data_inicial)/30
			WHEN unidade in ('y', 'year', 'years') THEN (data_final - data_inicial)/365
			END AS diferenca
$$


SELECT 
	CASE
		WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 20 THEN '0-20'
		WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 40 THEN '20-40'
		WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 60 THEN '40-80'
		WHEN DATEDIFF('years', birth_date, CURRENT_DATE) < 80 THEN '60-80'
		ELSE '80+' END "age group",
		COUNT(*)::FLOAT/(SELECT COUNT(*) FROM sales.customers) AS "leads (%)"
FROM sales.customers
GROUP BY "age group"
ORDER BY "age group" DESC


-- (Query 4) Leads Income Group
-- Columns: income group, leads (%), order

SELECT 
	CASE
		WHEN  income < 5000 THEN '0-5000'
		WHEN  income < 10000 THEN '5000-10000'
		WHEN  income < 15000 THEN '10000-15000'
		WHEN  income < 20000 THEN '15000-20000'
		ELSE '20000+' END "income group",
		COUNT(*)::FLOAT/(SELECT COUNT(*) FROM sales.customers) AS "leads (%)",
	CASE
		WHEN  income < 5000 THEN 1
		WHEN  income < 10000 THEN 2
		WHEN  income < 15000 THEN 3
		WHEN  income < 20000 THEN 4
		ELSE 5 END "order"		
FROM sales.customers
GROUP BY "income group", "order"
ORDER BY "order"

-- (Query 5) Vehicles Visited Classification 
-- Columns: vehicle classification, vehicles visited (#)
-- Business rule: New vehicles are up to 3 years old and semi-new vehicles over 3 years old

WITH
	vehicle_classification AS(
		SELECT
			fun.visit_page_date,
			pro.model_year,
			EXTRACT('year' FROM visit_page_date) - pro.model_year::INT AS vehicle_age,
			CASE
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 3 THEN 'New'
				ELSE 'Semi-New'
				END AS "vehicle classification"
		FROM sales.funnel AS fun
		LEFT JOIN sales.products AS pro
			ON fun.product_id = pro.product_id
	)
SELECT
	"vehicle classification",
	COUNT(*) "vehicles visited"
FROM vehicle_classification
GROUP BY "vehicle classification" 


-- (Query 6) Vehicles Visited Age
-- Columns: Vehicle Age, Vehicle Visited (%), Order

WITH
	vehicle_age_group AS(
		SELECT
			fun.visit_page_date,
			pro.model_year,
			EXTRACT('year' FROM visit_page_date) - pro.model_year::INT AS vehicle_age,
			CASE
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 2 THEN 'up to 2 years'
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 4 THEN 'from 2 to 4 years'
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 6 THEN 'from 4 to 6 years'
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 8 THEN 'from 6 to 8 years'
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 10 THEN 'from 8 to 10 years'
				ELSE 'more than 10 years'
				END AS "vehicle age",
			CASE
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 2 THEN 1
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 4 THEN 2
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 6 THEN 3
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 8 THEN 4
				WHEN (EXTRACT('year' FROM visit_page_date) - pro.model_year::INT) <= 10 THEN 5
				ELSE 6
				END AS "order"
		FROM sales.funnel AS fun
		LEFT JOIN sales.products AS pro
			ON fun.product_id = pro.product_id
	)
SELECT
	"vehicle age",
	COUNT(*)::FLOAT/(SELECT COUNT(*) FROM sales.funnel) "vehicles visited (%)",
	"order"
FROM vehicle_age_group
GROUP BY "vehicle age", "order"
ORDER BY "order"



-- (Query 7) Most Visited Vehicles per Brand
-- Columns: brand, model, visits (#)

SELECT 
	pro.brand,
	pro.model,
	COUNT(*) AS "visits"
FROM sales.funnel AS fun
LEFT JOIN sales.products AS pro
	ON fun.product_id = pro.product_id
GROUP BY pro.brand, pro.model
ORDER BY pro.brand, pro.model, "visits"











