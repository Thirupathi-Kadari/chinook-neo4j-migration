// ======================================================
// Chinook Neo4j Analysis Queries
// Project: Relational to Graph Database Migration
// Author: Thirupathi Kadari
// ======================================================

// 1. View sample customers
MATCH (c:Customer)
RETURN c
LIMIT 10;


// 2. Count total nodes by label
MATCH (n)
RETURN labels(n) AS Node_Label, count(n) AS Total_Count
ORDER BY Total_Count DESC;


// 3. Count total relationships by type
MATCH ()-[r]->()
RETURN type(r) AS Relationship_Type, count(r) AS Total_Count
ORDER BY Total_Count DESC;


// 4. Top 10 customers by total purchase amount
MATCH (c:Customer)-[:PLACED]->(i:Invoice)
RETURN c.FirstName + " " + c.LastName AS Customer_Name,
       c.Country AS Country,
       round(sum(i.Total), 2) AS Total_Spent
ORDER BY Total_Spent DESC
LIMIT 10;


// 5. Top 10 countries by revenue
MATCH (c:Customer)-[:PLACED]->(i:Invoice)
RETURN c.Country AS Country,
       round(sum(i.Total), 2) AS Total_Revenue
ORDER BY Total_Revenue DESC
LIMIT 10;


// 6. Top 10 most purchased tracks
MATCH (t:Track)<-[:CONTAINS]-(il:InvoiceLine)
RETURN t.Name AS Track_Name,
       sum(il.Quantity) AS Total_Quantity_Sold
ORDER BY Total_Quantity_Sold DESC
LIMIT 10;


// 7. Top 10 artists by number of tracks sold
MATCH (ar:Artist)-[:CREATED]->(al:Album)-[:HAS_TRACK]->(t:Track)<-[:CONTAINS]-(il:InvoiceLine)
RETURN ar.Name AS Artist_Name,
       sum(il.Quantity) AS Total_Tracks_Sold
ORDER BY Total_Tracks_Sold DESC
LIMIT 10;


// 8. Most popular genres by sales
MATCH (g:Genre)<-[:BELONGS_TO]-(t:Track)<-[:CONTAINS]-(il:InvoiceLine)
RETURN g.Name AS Genre,
       sum(il.Quantity) AS Total_Sales
ORDER BY Total_Sales DESC;


// 9. Revenue by genre
MATCH (g:Genre)<-[:BELONGS_TO]-(t:Track)<-[:CONTAINS]-(il:InvoiceLine)
RETURN g.Name AS Genre,
       round(sum(il.UnitPrice * il.Quantity), 2) AS Revenue
ORDER BY Revenue DESC;


// 10. Customers and their favorite genre
MATCH (c:Customer)-[:PLACED]->(i:Invoice)-[:HAS_LINE]->(il:InvoiceLine)-[:CONTAINS]->(t:Track)-[:BELONGS_TO]->(g:Genre)
RETURN c.FirstName + " " + c.LastName AS Customer_Name,
       g.Name AS Genre,
       count(*) AS Purchase_Count
ORDER BY Customer_Name, Purchase_Count DESC;


// 11. Top 10 albums by sales
MATCH (al:Album)-[:HAS_TRACK]->(t:Track)<-[:CONTAINS]-(il:InvoiceLine)
RETURN al.Title AS Album_Title,
       sum(il.Quantity) AS Total_Sales
ORDER BY Total_Sales DESC
LIMIT 10;


// 12. Top 10 employees by customer support count
MATCH (e:Employee)<-[:SUPPORTED_BY]-(c:Customer)
RETURN e.FirstName + " " + e.LastName AS Employee_Name,
       count(c) AS Customers_Supported
ORDER BY Customers_Supported DESC
LIMIT 10;


// 13. Customers supported by each employee
MATCH (e:Employee)<-[:SUPPORTED_BY]-(c:Customer)
RETURN e.FirstName + " " + e.LastName AS Employee_Name,
       collect(c.FirstName + " " + c.LastName) AS Customers
ORDER BY Employee_Name;


// 14. Recommendation idea:
// Recommend tracks from the same genre that the customer has not purchased
MATCH (c:Customer {CustomerId: 1})-[:PLACED]->(:Invoice)-[:HAS_LINE]->(:InvoiceLine)-[:CONTAINS]->(purchased:Track)-[:BELONGS_TO]->(g:Genre)
MATCH (recommended:Track)-[:BELONGS_TO]->(g)
WHERE NOT (c)-[:PLACED]->(:Invoice)-[:HAS_LINE]->(:InvoiceLine)-[:CONTAINS]->(recommended)
RETURN DISTINCT recommended.Name AS Recommended_Track,
       g.Name AS Genre
LIMIT 10;


// 15. Artist recommendation based on customer purchase history
MATCH (c:Customer {CustomerId: 1})-[:PLACED]->(:Invoice)-[:HAS_LINE]->(:InvoiceLine)-[:CONTAINS]->(:Track)<-[:HAS_TRACK]-(:Album)<-[:CREATED]-(ar:Artist)
RETURN ar.Name AS Artist_Name,
       count(*) AS Purchase_Count
ORDER BY Purchase_Count DESC
LIMIT 10;


// 16. Find customers who bought tracks from a specific artist
MATCH (ar:Artist {Name: "AC/DC"})-[:CREATED]->(:Album)-[:HAS_TRACK]->(t:Track)<-[:CONTAINS]-(:InvoiceLine)<-[:HAS_LINE]-(:Invoice)<-[:PLACED]-(c:Customer)
RETURN DISTINCT c.FirstName + " " + c.LastName AS Customer_Name,
       c.Country AS Country;


// 17. Monthly revenue trend
MATCH (i:Invoice)
RETURN date(i.InvoiceDate).year AS Year,
       date(i.InvoiceDate).month AS Month,
       round(sum(i.Total), 2) AS Revenue
ORDER BY Year, Month;


// 18. Average invoice amount by country
MATCH (c:Customer)-[:PLACED]->(i:Invoice)
RETURN c.Country AS Country,
       round(avg(i.Total), 2) AS Avg_Invoice_Amount
ORDER BY Avg_Invoice_Amount DESC;


// 19. Tracks with highest unit price
MATCH (t:Track)
RETURN t.Name AS Track_Name,
       t.UnitPrice AS Unit_Price
ORDER BY Unit_Price DESC
LIMIT 10;


// 20. Graph insight:
// Customer → Invoice → Track → Genre relationship path
MATCH path = (c:Customer)-[:PLACED]->(:Invoice)-[:HAS_LINE]->(:InvoiceLine)-[:CONTAINS]->(:Track)-[:BELONGS_TO]->(:Genre)
RETURN path
LIMIT 25;