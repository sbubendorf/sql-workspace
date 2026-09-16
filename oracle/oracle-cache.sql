-- --------------------------------------------------------------------------------
--  Step 1: Flushing the Shared Pool
-- --------------------------------------------------------------------------------

-- To eradicate cached SQL/explain plans, the initial step involves flushing the 
-- shared pool. Execute the following command:

ALTER SYSTEM FLUSH SHARED_POOL;

-- This command effectively eliminates all cached SQL/explain plans residing in 
-- the shared pool.

-- --------------------------------------------------------------------------------
--  Step 2: Flushing the Buffer Cache
-- --------------------------------------------------------------------------------

-- Clearing cached data entails flushing the buffer cache. Execute the following 
-- command to accomplish this task:


ALTER SYSTEM FLUSH BUFFER_CACHE;
-- This command purges all cached data from the buffer cache.

-- --------------------------------------------------------------------------------
--  Step 3: Gathering Statistics
-- --------------------------------------------------------------------------------

-- After the cache clearance, it is paramount to gather statistics 
-- to ensure precise results. To gather statistics for a specific schema, 
-- utilize the following command:
BEGIN
   DBMS_STATS.GATHER_SCHEMA_STATS('F2LDATP0');
END;
/

-- To gather statistics for the entire database, execute:
BEGIN
   DBMS_STATS.GATHER_DATABASE_STATS;
END;
/

-- --------------------------------------------------------------------------------
--  Step 4: Running the Query
-- --------------------------------------------------------------------------------

-- Once all cached items are cleared, and statistics are gathered, you can execute 
-- your query for accurate results. It is advisable to run the query multiple times 
-- to observe the benefits of caching and other optimizations.

-- Alternative Ways
-- While the aforementioned steps are the conventional approach to clear cached 
-- items in Oracle, alternative methods exist to achieve the same result. One such 
-- alternative involves restarting the instance, which effectively clears all 
-- cached items. However, this approach may not always be practical, especially 
-- in a production environment.

-- Recap
-- Clearing cached items in Oracle stands as a pivotal step when fine-tuning SQL 
-- queries for precise results. By diligently following the outlined steps in this 
-- guide, you can ensure the thorough clearance of all cached items and the 
-- collection of accurate statistics before executing your query.

-- Keep in mind that the operating system and hardware also perform caching, 
-- potentially influencing your results.

-- It is essential to note that the operating system and hardware may engage in 
-- caching, which can impact the outcome of your results.

-- FAQs on Clearing all Cached Items in Oracle

-- Q: Why is clearing cached items important in Oracle?
--    Clearing cached items is crucial in Oracle to ensure accurate results when 
--    tuning SQL queries, eliminating potential inaccuracies from cached data or 
--    SQL/explain plans.
-- Q: What is the purpose of flushing the shared pool in Oracle?
--    Flushing the shared pool in Oracle removes cached SQL/explain plans, 
--    providing a clean slate for query execution.
-- Q: How can I clear cached data in the buffer cache of Oracle?
--    You can clear cached data from the buffer cache in Oracle by executing 
--    the command: ALTER SYSTEM FLUSH BUFFER_CACHE;.
-- Q: Are there alternative methods to clear cached items in Oracle?
--    Yes, an alternative method involves restarting the instance, though it may 
--    not always be practical, especially in a production environment.
-- Q: Why is it recommended to run the query multiple times after clearing cached items?
--    Running the query multiple times allows observation of the benefits of 
--    caching and other optimizations, ensuring more accurate and reliable results.
