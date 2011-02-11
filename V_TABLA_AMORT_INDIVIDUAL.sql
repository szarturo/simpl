
  CREATE OR REPLACE FORCE VIEW "V_TABLA_AMORT_INDIVIDUAL" ("CVE_GPO_EMPRESA", "CVE_EMPRESA", "ID_PRESTAMO", "CVE_PRESTAMO", "NUM_PAGO_AMORTIZACION", "FECHA_AMORTIZACION", "IMP_SALDO_INICIAL", "TASA_INTERES", "INTERES", "IMP_CAPITAL_AMORT", "IMP_PAGO", "IMP_ACCESORIO", "PAGO_TOTAL", "IMP_SALDO_FINAL") AS 
  SELECT A.CVE_GPO_EMPRESA,
    A.CVE_EMPRESA,
    A.ID_PRESTAMO,
    A.CVE_PRESTAMO,
    A.NUM_PAGO_AMORTIZACION,
    A.FECHA_AMORTIZACION,
    TO_CHAR(A.IMP_SALDO_INICIAL,'999,999,999.9999') IMP_SALDO_INICIAL,
    A.TASA_INTERES,
    A.INTERES,
    A.IMP_CAPITAL_AMORT,
    A.IMP_PAGO,
    B.IMP_ACCESORIO,
    A.IMP_PAGO + B.IMP_ACCESORIO PAGO_TOTAL,
    TO_CHAR(A.IMP_SALDO_FINAL,'999,999,999.9999') IMP_SALDO_FINAL
  FROM
    (SELECT T.CVE_GPO_EMPRESA,
      T.CVE_EMPRESA,
      T.ID_PRESTAMO,
      P.CVE_PRESTAMO,
      C.NOM_COMPLETO,
      O.NOM_PRODUCTO,
      P.NUM_CICLO,
      T.NUM_PAGO_AMORTIZACION,
      T.FECHA_AMORTIZACION,
      T.IMP_SALDO_INICIAL,
      T.TASA_INTERES,
      SUM(NVL(T.IMP_INTERES,0) + NVL(T.IMP_IVA_INTERES,0) + NVL(T.IMP_INTERES_EXTRA,0) + NVL(T.IMP_IVA_INTERES_EXTRA,0)) INTERES,
      T.IMP_CAPITAL_AMORT,
      T.IMP_PAGO,
      T.IMP_SALDO_FINAL
    FROM SIM_TABLA_AMORTIZACION T,
      SIM_PRESTAMO P,
      RS_GRAL_PERSONA C,
      SIM_PRODUCTO O
    WHERE T.CVE_GPO_EMPRESA = 'SIM'
    AND T.CVE_EMPRESA       = 'CREDICONFIA'
    AND P.CVE_GPO_EMPRESA   = T.CVE_GPO_EMPRESA
    AND P.CVE_EMPRESA       = T.CVE_EMPRESA
    AND P.ID_PRESTAMO       = T.ID_PRESTAMO
    AND C.CVE_GPO_EMPRESA   = P.CVE_GPO_EMPRESA
    AND C.CVE_EMPRESA       = P.CVE_EMPRESA
    AND C.ID_PERSONA        = P.ID_CLIENTE
    AND O.CVE_GPO_EMPRESA   = P.CVE_GPO_EMPRESA
    AND O.CVE_EMPRESA       = P.CVE_EMPRESA
    AND O.ID_PRODUCTO       = P.ID_PRODUCTO
    GROUP BY T.CVE_GPO_EMPRESA,
      T.CVE_EMPRESA,
      T.ID_PRESTAMO,
      P.CVE_PRESTAMO,
      C.NOM_COMPLETO,
      O.NOM_PRODUCTO,
      P.NUM_CICLO,
      T.NUM_PAGO_AMORTIZACION,
      T.FECHA_AMORTIZACION,
      T.IMP_SALDO_INICIAL,
      T.TASA_INTERES,
      T.IMP_CAPITAL_AMORT,
      T.IMP_PAGO,
      T.IMP_SALDO_FINAL
    )A,
    (SELECT T.CVE_GPO_EMPRESA,
      T.CVE_EMPRESA,
      P.ID_PRESTAMO,
      P.CVE_PRESTAMO,
      T.NUM_PAGO_AMORTIZACION,
      T.FECHA_AMORTIZACION,
      SUM(A.IMP_ACCESORIO) IMP_ACCESORIO
    FROM SIM_TABLA_AMORTIZACION T,
      SIM_TABLA_AMORT_ACCESORIO A,
      SIM_CAT_ACCESORIO N,
      SIM_PRESTAMO P,
      RS_GRAL_PERSONA C,
      SIM_PRODUCTO O
    WHERE T.CVE_GPO_EMPRESA     = 'SIM'
    AND T.CVE_EMPRESA           = 'CREDICONFIA'
    AND A.CVE_GPO_EMPRESA       = T.CVE_GPO_EMPRESA
    AND A.CVE_EMPRESA           = T.CVE_EMPRESA
    AND A.ID_PRESTAMO           = T.ID_PRESTAMO
    AND A.NUM_PAGO_AMORTIZACION = T.NUM_PAGO_AMORTIZACION
    AND N.CVE_GPO_EMPRESA       = A.CVE_GPO_EMPRESA
    AND N.CVE_EMPRESA           = A.CVE_EMPRESA
    AND N.ID_ACCESORIO          = A.ID_ACCESORIO
    AND P.CVE_GPO_EMPRESA       = T.CVE_GPO_EMPRESA
    AND P.CVE_EMPRESA           = T.CVE_EMPRESA
    AND P.ID_PRESTAMO           = T.ID_PRESTAMO
    AND C.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
    AND C.CVE_EMPRESA           = P.CVE_EMPRESA
    AND C.ID_PERSONA            = P.ID_CLIENTE
    AND O.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
    AND O.CVE_EMPRESA           = P.CVE_EMPRESA
    AND O.ID_PRODUCTO           = P.ID_PRODUCTO
    GROUP BY T.CVE_GPO_EMPRESA,
      T.CVE_EMPRESA,
      P.ID_PRESTAMO,
      P.CVE_PRESTAMO,
      T.NUM_PAGO_AMORTIZACION,
      T.FECHA_AMORTIZACION
    )B
  WHERE A.CVE_GPO_EMPRESA     = B.CVE_GPO_EMPRESA
  AND A.CVE_EMPRESA           = B.CVE_EMPRESA
  AND A.ID_PRESTAMO           = B.ID_PRESTAMO
  AND A.NUM_PAGO_AMORTIZACION = B.NUM_PAGO_AMORTIZACION
  ORDER BY Id_Prestamo,
    NUM_PAGO_AMORTIZACION;
 