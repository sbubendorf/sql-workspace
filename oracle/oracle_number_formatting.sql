-- Number formatting -----------------------------------------------------------
select  to_char(102637771,'999G999G999D99', q'[NLS_NUMERIC_CHARACTERS='.''']'),
        to_char(102637771,'999G999G999D99', 'NLS_NUMERIC_CHARACTERS=''.''''')
from    dual
;


