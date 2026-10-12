-- Set SQL*Plus environment for CSV output
SET ECHO OFF
SET FEEDBACK ON
SET HEADING ON
SET PAGESIZE 0
SET LINESIZE 32767
SET TERMOUT OFF
SET TRIMSPOOL ON
SET COLSEP ','        -- Use comma as column separator
SET UNDERLINE OFF

-- Optional: Remove extra spaces around data
COLUMN column_name FORMAT A50

-- Start writing to CSV file
SPOOL output.csv