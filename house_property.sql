-- showing all records from the table
SELECT *
FROM house_property

-- add a new column with data type as date
alter table house_property add column date DATE

--insert value into new column from datesold
UPDATE house_property
set date = datesold::date

--checking the min and max of datesold
SELECT MIN(datesold) AS min_datesold,
	   MAX(datesold) AS max_datesold
FROM house_property

-- checking the total number of all records in the table
SELECT COUNT(*)
FROM house_property

-- which date has the most frequent sales ?
SELECT datesold,
       COUNT(datesold) AS number_of_sales,
	   SUM(price) AS price_sum
FROM house_property
GROUP BY 1
ORDER BY number_of_sales DESC

-- which postcode has the highest average price per sales ?
SELECT postcode,
	   ROUND(AVG(price),2) AS average_price,
	   COUNT(postcode) AS sales_count
FROM house_property
GROUP BY postcode
ORDER BY average_price DESC

-- which year has the lowest number of sales ?
SELECT EXTRACT(YEAR FROM date) AS years,
       COUNT(1) as num_of_sales,
	   SUM(price) AS price_sum
FROM house_property
GROUP BY years
ORDER BY num_of_sales

--which top five postcodes by price in each year ?
SELECT * FROM
(
SELECT  years,
	    postcode,
        price_sum,
		ROW_NUMBER() OVER(PARTITION BY years ORDER BY price_sum DESC) AS ranking
FROM(
      SELECT EXTRACT(YEAR FROM date) AS years,
              postcode,
              SUM(price) AS price_sum
       FROM house_property
       GROUP BY years, postcode) as a) as b
WHERE ranking <= 5
ORDER BY years, ranking

-- how many sales of houses and units are there for each year ?
SELECT EXTRACT(YEAR FROM date) AS years,
SUM(CASE WHEN "propertyType" = 'house' THEN 1 ELSE 0 END) AS house_sales_count,
SUM(CASE WHEN "propertyType" = 'unit' THEN 1 ELSE 0 END) AS unit_sales_count
FROM house_property
GROUP BY years
ORDER BY years

-- what is the average price difference between house and unit
SELECT EXTRACT(YEAR FROM date) AS years,
ROUND(AVG(price) FILTER(WHERE "propertyType"='house'),2) AS house_price_avg,
ROUND(AVG(price) FILTER(WHERE "propertyType"='unit'), 2) AS unit_price_avg
FROM house_property
GROUP BY years
ORDER BY years

--what is the average price difference between house and unit in terms of bedrooms
SELECT EXTRACT(YEAR FROM date) AS years,
AVG(CASE WHEN "propertyType"='house' THEN price/NULLIF(bedrooms,0) ELSE null END) AS house_price_bedroom_avg,
AVG(CASE WHEN "propertyType"='unit' THEN price/NULLIF(bedrooms,0) ELSE null END) AS unit_price_bedroom_avg
FROM house_property
GROUP BY years
ORDER BY years

--what is the total price difference between house and unit in terms of bedrooms
SELECT EXTRACT(YEAR FROM date) as years,
round(SUM(price/NULLIF(bedrooms,0)) FILTER(WHERE "propertyType"='house'),2) AS house_price,
round(SUM(price/NULLIF(bedrooms,0)) FILTER(WHERE "propertyType"='unit'),2) AS unit_price
FROM house_property
GROUP BY years
ORDER BY years