--1.Count and calculate the percentage of movies versus TV shows.

SELECT * FROM [PortfolioProject].[dbo].[disney]

SELECT 
    type,
    COUNT(*) AS total,
    COUNT(*) * 100 / SUM(COUNT(*)) OVER () AS percentage
FROM [PortfolioProject].[dbo].[disney]
GROUP BY type;

--2.Find the most common rating for movies and TV shows

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

--3. List all TV Shows released in a specific year(e.g., 2018)

SELECT 
	*
FROM [PortfolioProject].[dbo].[disney]
WHERE type = 'TV Show'
AND release_year = '2018'

--4. Find the Top 5 Countries with the Most Content on Disney

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



--5. Identify the longest movie on Disney

SELECT TOP 1
    *
FROM [PortfolioProject].[dbo].[disney]
WHERE type = 'Movie'
ORDER BY 
    CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) DESC;

--6.Find Content Added in the Last 5 Years

SELECT *
FROM [PortfolioProject].[dbo].[disney]
WHERE 
    date_added >= DATEADD(YEAR, -5, GETDATE())
ORDER BY date_added DESC;

--Find All Movies/TV Shows starred by 'Robert Downey Jr.'


SELECT *
FROM (
    SELECT 
        *, 
        TRIM(value) AS cast_name
    FROM [PortfolioProject].[dbo].[disney]
    CROSS APPLY STRING_SPLIT(cast, ',')
) AS t
WHERE cast_name IS NOT NULL
AND cast_name = 'Robert Downey Jr.';

--7.List All TV Shows with More Than 5 Seasons


SELECT
    *
FROM [PortfolioProject].[dbo].[disney]
WHERE type = 'TV Show'
AND CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) > 5
ORDER BY 
    CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) DESC;


--8.Count the Number of Content Items in Each Genre

SELECT
	TRIM(value) AS genre,
    COUNT(*) AS total_content
FROM [PortfolioProject].[dbo].[disney]
    CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY TRIM(value);

--10.Find each year and the average numbers of content release in United States on Disney

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

--11. List All Movies that are Documentaries

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
	
--12. Find All Content Without a Director

SELECT
	* 
FROM [PortfolioProject].[dbo].[disney]
WHERE director IS NULL;

--13. Find How Many Movies director 'Anthony Russo' directed in the Last 10 Years

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

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in United States

SELECT TOP 10
		COUNT(*) AS total_count,
		TRIM(value) AS actors
FROM [PortfolioProject].[dbo].[disney]
CROSS APPLY STRING_SPLIT(cast, ',')	
WHERE country = 'United States'
GROUP BY TRIM(value)
ORDER BY COUNT(*) DESC;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

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
