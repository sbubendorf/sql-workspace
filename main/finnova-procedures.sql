begin
   dbms_output.enable;
   dbms_output.put_line('setuser:   ' || f2qlogin.f_setuser(p_id=> 'MD1AT', p_pw=> 'berlin08'));
   dbms_output.put_line('userbank:  ' || f2qlogin.f_ub);
   B2QF_PROGRAM_PARAMS.InitPP;
   dbms_output.put_line('param:' || B2QF_PROGRAM_PARAMS.F_GetWVPOGroups);
end;
/

begin
    f2qapenv.setlogpar(64147726648959,1,949,9500); -- 64147726648959 = md1mth
end;
/


select   u.*
from     al_user     u
where    u.user_id = 'MTH'
;

select  p.prg_id,
        p.par_id,
        p.userbk_nr,
        p.par_wert
from    SR_PRG_PAR      p
where   1=1
    and p.par_id = 'WVPO_GROUPS'
    and p.userbk_nr = 'MD1'
;