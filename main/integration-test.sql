-- --------------------------------------------------------------------------------
--  Execution of Integration tests
-- --------------------------------------------------------------------------------

begin
   ut.run('IT_B2QI_TRADING_HEADERS_1');
end;

/*

   Output:

   F_ReadBoersenauftragHeaders integration tests
   Each filter returns only matching headers [4.903 sec]
   Combined filters return matching headers [3.762 sec]
   Bulk request with multiple indexed filter collections [3.381 sec]
   Paging size and next cursor return consecutive distinct headers [1.085 sec]
   Unknown instrument produces an empty response [3.248 sec]
   Invalid paging size is rejected by the public API [.024 sec]

   Finished in 17.326659 seconds

   6 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)

*/
