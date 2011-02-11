
  CREATE OR REPLACE FUNCTION "FFECHAHOY" (pCveGpoEmpresa IN PFIN_PARAMETRO.CVE_GPO_EMPRESA%TYPE, pCveEmpresa IN PFIN_PARAMETRO.CVE_EMPRESA%TYPE) RETURN DATE AS 
  vlFecha DATE;
BEGIN
  SELECT F_MEDIO
    INTO vlFecha
    FROM PFIN_PARAMETRO
   WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
         CVE_EMPRESA     = pCveEmpresa    AND
         CVE_MEDIO       = 'SYSTEM';
         
  RETURN vlFecha;
END FFECHAHOY;
/
 