-- Displaying Rollback Segment Information
-- The DBA_ROLLBACK_SEGS data dictionary view stores information about the rollback segments of a database. 
-- For example, the following query lists the name, associated tablespace, and status of each rollback segment in a database:

select  segment_id,
        segment_name,
        owner, 
        tablespace_name, 
        status
from    sys.dba_rollback_segs
order   by  segment_id
;

-- In addition, the following data dictionary views contain information about the segments of a database, including rollback segments:

select  us.segment_name,
        us.segment_type,
        us.tablespace_name,
        to_char(us.bytes,  '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as bytes,
        to_char(us.blocks, '999G999G999G999', 'NLS_NUMERIC_CHARACTERS=''.''''') as blocks,
        us.extents,
        us.initial_extent,
        us.next_extent,
        us.min_extents,
        us.max_extents,
        us.max_size
from    user_segments   us
--where   us.segment_name like '%COMMUNICATION%'


select  *
from    dba_segments;




-- Displaying All Rollback Segments
-- The following query returns the name of each rollback segment, the tablespace that contains it, and its size:

select  segment_name, 
        tablespace_name, 
        bytes, 
        blocks, 
        extents
from    sys.dba_segments
where   segment_type = 'ROLLBACK';
   

-- Displaying Whether a Rollback Segment Has Gone Offline
-- When you take a rollback segment offline, it does not actually go offline until all active transactions in 
-- it have completed. Between the time when you attempt to take it offline and when it actually is offline, 
-- its status in DBA_ROLLBACK_SEGS remains ONLINE, but it is not used for new transactions. To determine 
-- whether any rollback segments for an instance are in this state, use the following query:

select  name, 
        xacts active_transactions
from    v$rollname, 
        v$rollstat
where   status = 'PENDING OFFLINE'
    and v$rollname.usn = v$rollstat.usn;
   
-- If your instance is part of a Parallel Server configuration, this query displays information for rollback 
-- segments of the current instance only, not those of other instances.

-- Displaying Deferred Rollback Segments
-- The following query shows which rollback segments are private and which are public. Note that it only 
-- displays information about the rollback segments that are currently online for the current instance:

select  segment_name, 
        tablespace_name, 
        owner
from    sys.dba_rollback_segs;
   


-- Displaying All Deferred Rollback Segments
-- The following query shows all deferred rollback segments (rollback segments that were created to hold 
-- rollback entries for tablespaces taken offline until the tablespaces are brought back online):

select  segment_name, 
        segment_type, 
        tablespace_name
from    sys.dba_segments
where   segment_type = 'DEFERRED ROLLBACK';


