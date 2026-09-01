select  INSTANCE_NAME,
        HOST_NAME,
        VERSION_FULL,
        STARTUP_TIME,
        STATUS,
        LOGINS
from    v$instance
;