# Disney Movies and TV Shows Data Analysis using SQL
## Overview
This project involves a comprehensive analysis of Disney's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies and TV Shows Dataset](https://www.kaggle.com/datasets/shivamb/disney-movies-and-tv-shows)
## Business Problems and Solutions

### 1. Count and calculate the percentage of movies versus TV shows.

```sql
SELECT 
    type,
    COUNT(*) AS total,
    COUNT(*) * 100 / SUM(COUNT(*)) OVER () AS percentage
FROM [PortfolioProject].[dbo].[disney]
GROUP BY type;
```
**Objective:** Determine the distribution of content types on Disney.

### 2. Find the most common rating for Movies and TV Shows.

```sql
WITH ratings AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM [PortfolioProject].[dbo].[disney]
    GROUP BY type, rating
),
Ranked AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM ratings
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM Ranked
WHERE rank = 1;
```
**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List all TV Shows released in a specific year (e.g., 2018).

```sql
SELECT 
	*
FROM [PortfolioProject].[dbo].[disney]
WHERE type = 'TV Show'
AND release_year = '2018'
```
**Objective:** Retrieve all TV Shows released in a specific year.

### 4. Find the top 5 countries with the most content on Disney.

```sql
SELECT TOP 5
    *
FROM (
    SELECT 
        TRIM(value) AS country,
        COUNT(*) AS total_content
    FROM [PortfolioProject].[dbo].[disney]
    CROSS APPLY STRING_SPLIT(country, ',')
    GROUP BY TRIM(value)
) AS t1
WHERE country IS NOT NULL
ORDER BY total_content DESC;
```
**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the longest movie on Disney.

```sql
SELECT TOP 1
    *
FROM [PortfolioProject].[dbo].[disney]
WHERE type = 'Movie'
ORDER BY 
    CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) DESC;
```
**Objective:** identify the movie with the longest duration on Disney.

### 6. Find content added in the last 5 Years.

```sql
SELECT
    *
FROM [PortfolioProject].[dbo].[disney]
WHERE 
    date_added >= DATEADD(YEAR, -5, GETDATE())
ORDER BY date_added DESC;
```
**Objective:** Retrieve content added to Disney in the last 5 years.

### 7. Find all Movies/TV Shows starred by 'Robert Downey Jr.'

```sql
SELECT
    *
FROM
    (SELECT 
        *, 
        TRIM(value) AS cast_name
    FROM [PortfolioProject].[dbo].[disney]
    CROSS APPLY STRING_SPLIT(cast, ',')
) AS t
WHERE cast_name IS NOT NULL
AND cast_name = 'Robert Downey Jr.';
```
**Objective:** List all content starred by 'Robert Downey Jr.'

### 8. List all TV Shows with more than 5 Seasons.

```sql
SELECT
    *
FROM [PortfolioProject].[dbo].[disney]
WHERE type = 'TV Show'
AND CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) > 5
ORDER BY 
    CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) DESC;
```
**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the number of content items in each genre.

```sql
SELECT
	TRIM(value) AS genre,
    COUNT(*) AS total_content
FROM [PortfolioProject].[dbo].[disney]
    CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value);
```
**Objective:** Count the number of content in each genre.

### 10. Find each year and the average numbers of content release in United States on Disney.

```sql
select * from [PortfolioProject].[dbo].[disney]

SELECT TOP 5
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS FLOAT) / 
        (SELECT COUNT(show_id) FROM [PortfolioProject].[dbo].[disney] WHERE country = 'United States') * 100, 
        2
    ) AS avg_release
FROM [PortfolioProject].[dbo].[disney]
WHERE country = 'United States'
GROUP BY country, release_year
ORDER BY avg_release DESC;
```
**Objective:** Calculate and rank years by the average number of content releases by United States.

### 11. List all movies that are documentaries.

```sql
SELECT
	* 
FROM
	(SELECT 
		*,
		TRIM(value) as documentary
	FROM [PortfolioProject].[dbo].[disney]
	CROSS APPLY STRING_SPLIT(listed_in, ','))
	AS d
WHERE documentary = 'Documentary'
AND type = 'Movie';
```
**Objective:** Retrieve all movies classified as documentaries.

### 12. Find all content without a director.

```sql
SELECT
	* 
FROM [PortfolioProject].[dbo].[disney]
WHERE director IS NULL;
```
**Objective:** List content that does not have a director.

### 13. Find how many movies are directed by 'Anthony Russo' in the Last 10 Years.

```sql
SELECT
	*
FROM
	(SELECT 
		*,
		TRIM(value) as directed_by
	FROM [PortfolioProject].[dbo].[disney]
	CROSS APPLY STRING_SPLIT(director, ',')) AS d
WHERE directed_by = 'Anthony Russo'
AND
	release_year > YEAR(GETDATE()) - 10;
```
**Objective:** Count the number of movies directed by 'Anthony Russo' in the last 10 years.

### 14. Find the top 10 actors who have appeared in the highest number of movies produced in United States.

```sql
SELECT TOP 10
		COUNT(*) AS total_count,
		TRIM(value) AS actors
FROM [PortfolioProject].[dbo].[disney]
CROSS APPLY STRING_SPLIT(cast, ',')	
WHERE country = 'United States'
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;
```
**Objective:** Identify the top 10 actors with the most appearances in United States-produced movies.

### 15. Categorize content based on the presence of 'Kill' and 'Violence' keywords.

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM [PortfolioProject].[dbo].[disney]
) AS categorized_content
GROUP BY category;
```
**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by United States highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Disney.
