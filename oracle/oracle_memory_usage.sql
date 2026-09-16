select  round(sum(bytes)/1024/1024,2)||' MB' total_sga,
        round(round(sum(bytes)/1024/1024,2) - round(sum(decode(name,'free memory',bytes,0))/1024/1024,2))||' MB' used,
        round(sum(decode(name,'free memory',bytes,0))/1024/1024,2)||' MB' free
from    v$sgastat;