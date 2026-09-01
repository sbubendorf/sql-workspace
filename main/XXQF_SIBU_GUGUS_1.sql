/**
 * --------------------------------------------------------------------------------------------------------------------
 * HEADER : Copyright (c) finnova AG Bankware
 * PROJECT: TODO
 * PACKAGE: XXX
 *
 * $Source$
 * $Id$
 * $Revision$
 *
 * Description:
 * Das ist ein Template-Package für Finnova-Packages und entspricht den Guidelines gemäss
 * https://dev.finnova.ch/confluence/pages/viewpage.action?pageId=733413948
 *
 * --------------------------------------------------------------------------------------------------------------------
 * History:
 * $Log$
 *
*/

-----------------------------------------------------------------------------------------------------------------------
-- Package specification
-----------------------------------------------------------------------------------------------------------------------
/*
   <package documentation>
*/
create or replace package XXQF_SIBU_GUGUS_1 as

-- Public constant definitions ----------------------------------------------------------------------------------------

-- Public exception definitions ---------------------------------------------------------------------------------------

-- Public type definitions --------------------------------------------------------------------------------------------

-- Public function or procedure definitions ---------------------------------------------------------------------------
   /*
      %description Die Funktion gibt die CVS-Revision des Packages zurück.
   */
   function F_Revision return char; -- Die Revision

   /*
      %description Die Procedur gibt die User Bank zurück.
   */
   procedure GetUserBank(
      P_UserBank out varchar2
   );

   /*
      %description Die Procedur gibt die User Bank zurück.
   */
   procedure GetUserBank(
      P_Record in out XXYSIBU_GUGUS_1
   );

end XXQF_SIBU_GUGUS_1;
/
show err

-----------------------------------------------------------------------------------------------------------------------
-- Package body
-----------------------------------------------------------------------------------------------------------------------
create or replace package body XXQF_SIBU_GUGUS_1 as

-- Private constant definitions ---------------------------------------------------------------------------------------
   /* Constant Package Name */
   K_PACKAGE_NAME constant varchar2(32) := $$PLSQL_UNIT;

   /* It is true if the debug level is set. */
   K_DEBUG constant boolean := ALQMSG00.F_IsDebugOn(K_PACKAGE_NAME);

-- Private exception definitions --------------------------------------------------------------------------------------

-- Private type definitions -------------------------------------------------------------------------------------------

-- Private variable definitions ---------------------------------------------------------------------------------------
   /* The defined log level */
   G_ID pls_integer;

   /* Datacenter */
   G_RZ SR_USERBK.USERBK_NR%type;

   /* User bank */
   G_UB SR_USERBK.USERBK_NR%type;

   /* User language */
   G_SP AL_SPRACHE.SPRACHE_CD%type;

   /* Users KD_LNR */
   G_SU KD_USER.KD_LNR%type;

   /* Users USER_LNR */
   G_UserLnr AL_USER.USER_LNR%type;

-- Private cursor definitions -----------------------------------------------------------------------------------------

-- Private function or procedure definitions --------------------------------------------------------------------------

-- Implementation section ---------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------------------
   /*
      Die Funktion gibt die CVS-Revision des Packages zurück.
   */
   function F_Revision return char is -- Die Revision des Packages
   begin
      return '$Revision$';
   end F_Revision;

   /*
      Die Prozedur gibt die User Bank zurück.
   */
   procedure GetUserBank(
      P_UserBank out varchar2
   ) is
      K_METHOD_NAME constant varchar2(32) := 'GetUserBank';
   begin
      P_UserBank := 'User: ' || G_Su || ' Bank: ' || G_Ub;
      if K_DEBUG then
         ALQMSG00.msg_debug(K_METHOD_NAME, 'Res: ' || P_UserBank, $$PLSQL_UNIT, G_ID);
      end if;
   exception
      when others then
         ALQMSG00.msg_error_others(K_METHOD_NAME, '', $$PLSQL_UNIT);
         raise;
   end GetUserBank;

   /*
      Die Prozedur gibt die User Bank zurück.
   */
   procedure GetUserBank(
      P_Record in out XXYSIBU_GUGUS_1
   ) is
   begin
       GetUserBank( P_UserBank => P_Record.FELD_DUMMY);
   end GetUserBank;


-----------------------------------------------------------------------------------------------------------------------
   /*
      Package-Initialisierung
      Die Prozedur InitPackage initialisiert die folgenden Package-Body-Variablen:
      G_RZ, G_SP, G_SU, G_UB, G_UserLnr
   */
   procedure InitPackage is
   begin
      G_RZ        := F2QAPENV.F_Rz();
      G_SP        := F2QAPENV.F_Sp();
      G_SU        := F2QAPENV.F_Su();
      G_UB        := F2QAPENV.F_Ub();
      G_UserLnr   := F2QAPENV.F_UserLnr();
      G_ID        := ALQMSG00.F_GetLogLevel(K_PACKAGE_NAME);
   exception
      -- hier benötigtes Exception Handling einbauen
      when others then null;
   end InitPackage;
-----------------------------------------------------------------------------------------------------------------------
begin
   InitPackage();
end XXQF_SIBU_GUGUS_1;
/
show err

