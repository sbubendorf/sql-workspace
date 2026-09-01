-- Flush cashed data (needs SYSDBA)
alter system flush buffer_cache;

-- Flush cached SQL and PL/SQL code (needs SYSDBA)
alter system flush shared_pool;