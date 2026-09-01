-- =============================================================================
-- Package : B2QF_HPROF_SAMPLE
-- Description : Sample package to demonstrate DBMS_HPROF profiling
-- Author : Auto-fixed
-- Revision : $Revision$
-- =============================================================================

CREATE OR REPLACE PACKAGE B2QF_HPROF_SAMPLE AS
    -- Procedure to run the sample profiling loop
    PROCEDURE sample_proc;
END B2QF_HPROF_SAMPLE;
/

CREATE OR REPLACE PACKAGE BODY B2QF_HPROF_SAMPLE AS
    PROCEDURE sample_proc IS
        K_MAX CONSTANT INTEGER := 100000;
        L_SUM INTEGER := 0;
    BEGIN
        <<sample_loop>>
        FOR i IN 1..K_MAX LOOP
            L_SUM := L_SUM + i;
        END LOOP sample_loop;
        SYS.DBMS_OUTPUT.PUT_LINE('Sum = ' || L_SUM);
    END sample_proc;
END B2QF_HPROF_SAMPLE;
/

BEGIN
    DBMS_HPROF.CREATE_TABLES(force_it => true);
END;
/

DECLARE
BEGIN
    -- Start profiling and write raw data to a file
    DBMS_HPROF.START_PROFILING(
        location => 'MANIFEST_DIR',   -- Must match directory object name
        filename => 'sample_proc.trc'
    );
    -- Run the procedure you want to profile
    B2QF_HPROF_SAMPLE.sample_proc;
    -- Stop profiling
    DBMS_HPROF.STOP_PROFILING;
END;
/

SET LONG 1000000
SET PAGESIZE 0
SET LINESIZE 32767

SPOOL sample_proc_report.html

SELECT DBMS_HPROF.ANALYZE(
           location => 'MANIFEST_DIR',
           filename => 'sample_proc.trc'
       )
FROM dual;

SPOOL OFF


DROP PACKAGE B2QF_HPROF_SAMPLE;
