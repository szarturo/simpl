CREATE OR REPLACE FORCE VIEW V_MOV_EDO_CTA_GPO ("CVE_GPO_EMPRESA", "CVE_EMPRESA", "ID_PRESTAMO", "F_OPERACION", "NUM_PAGO_AMORTIZACION", "F_APLICACION", "CVE_CONCEPTO", "ID_ACCESORIO", "DESC_MOVIMIENTO", "IMP_PAGO", "IMP_CONCEPTO", "ID_MOVIMIENTO")
AS
  SELECT G.CVE_GPO_EMPRESA,
    G.CVE_EMPRESA,
    G.ID_PRESTAMO_GRUPO  AS ID_PRESTAMO,
    A.FECHA_AMORTIZACION AS F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.FECHA_AMORTIZACION AS F_APLICACION,
    B.CVE_CONCEPTO,
    ACC.ID_ACCESORIO,
    INITCAP(B.DESC_CORTA),
    0                   AS IMP_PAGO,
    SUM(A.IMP_ORIGINAL) AS IMP_CONCEPTO,
    0                   AS ID_MOVIMIENTO
  FROM SIM_PRESTAMO_GPO_DET G,
    V_SIM_TABLA_AMORT_CONCEPTO A,
    PFIN_CAT_CONCEPTO B,
    SIM_CAT_ACCESORIO ACC
  WHERE G.CVE_GPO_EMPRESA    = A.CVE_GPO_EMPRESA
  AND G.CVE_EMPRESA          = A.CVE_EMPRESA
  AND G.ID_PRESTAMO          = A.ID_PRESTAMO
  AND A.CVE_GPO_EMPRESA      = B.CVE_GPO_EMPRESA
  AND A.CVE_EMPRESA          = B.CVE_EMPRESA
  AND A.CVE_CONCEPTO         = B.CVE_CONCEPTO
  AND A.IMP_ORIGINAL        <> 0
  AND ACC.CVE_GPO_EMPRESA (+)= B.CVE_GPO_EMPRESA
  AND ACC.CVE_EMPRESA (+)    = B.CVE_EMPRESA
  AND ACC.ID_ACCESORIO (+)   = B.ID_ACCESORIO
  GROUP BY G.CVE_GPO_EMPRESA,
    G.CVE_EMPRESA,
    G.ID_PRESTAMO_GRUPO,
    A.FECHA_AMORTIZACION,
    A.NUM_PAGO_AMORTIZACION,
    A.FECHA_AMORTIZACION,
    B.CVE_CONCEPTO,
    ACC.ID_ACCESORIO,
    INITCAP(B.DESC_CORTA),
    0,
    0
  UNION ALL
  -- Recupera informacion de los conceptos que afectan al credito
  SELECT G.CVE_GPO_EMPRESA,
    G.CVE_EMPRESA,
    G.ID_PRESTAMO_GRUPO AS ID_PRESTAMO,
    A.F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.F_APLICACION,
    C.CVE_CONCEPTO,
    ACC.ID_ACCESORIO,
    INITCAP(D.DESC_CORTA)
    || ' '
    || INITCAP(C.DESC_CORTA) AS DESCRIPCION,
    0                        AS IMP_PAGO,
    SUM(
    CASE
      WHEN D.CVE_AFECTA_CREDITO = 'D'
      THEN B.IMP_CONCEPTO
      WHEN D.CVE_AFECTA_CREDITO = 'I'
      THEN -B.IMP_CONCEPTO
    END) AS IMP_CONCEPTO,
    A.ID_MOVIMIENTO
  FROM SIM_PRESTAMO_GPO_DET G,
    PFIN_MOVIMIENTO A,
    PFIN_MOVIMIENTO_DET B,
    PFIN_CAT_CONCEPTO C,
    PFIN_CAT_OPERACION D,
    SIM_CAT_ACCESORIO ACC
  WHERE G.CVE_GPO_EMPRESA    = A.CVE_GPO_EMPRESA
  AND G.CVE_EMPRESA          = A.CVE_EMPRESA
  AND G.ID_PRESTAMO          = A.ID_PRESTAMO
  AND A.CVE_GPO_EMPRESA      = B.CVE_GPO_EMPRESA
  AND A.CVE_EMPRESA          = B.CVE_EMPRESA
  AND A.ID_MOVIMIENTO        = B.ID_MOVIMIENTO
  AND A.SIT_MOVIMIENTO      <> 'CA'
  AND B.CVE_GPO_EMPRESA      = C.CVE_GPO_EMPRESA
  AND B.CVE_EMPRESA          = C.CVE_EMPRESA
  AND B.CVE_CONCEPTO         = C.CVE_CONCEPTO
  AND D.CVE_GPO_EMPRESA      = A.CVE_GPO_EMPRESA
  AND D.CVE_EMPRESA          = A.CVE_EMPRESA
  AND D.CVE_OPERACION        = A.CVE_OPERACION
  AND D.CVE_AFECTA_CREDITO  IN ('D','I')
  AND ACC.CVE_GPO_EMPRESA (+)= C.CVE_GPO_EMPRESA
  AND ACC.CVE_EMPRESA (+)    = C.CVE_EMPRESA
  AND ACC.ID_ACCESORIO (+)   = C.ID_ACCESORIO
  GROUP BY G.CVE_GPO_EMPRESA,
    G.CVE_EMPRESA,
    G.ID_PRESTAMO_GRUPO,
    A.F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.F_APLICACION,
    C.CVE_CONCEPTO,
    ACC.ID_ACCESORIO,
    INITCAP(D.DESC_CORTA)
    || ' '
    || INITCAP(C.DESC_CORTA),
    0,
    D.CVE_AFECTA_CREDITO,
    A.ID_MOVIMIENTO
  UNION ALL
  -- Recupera informacion del movimiento
  SELECT G.CVE_GPO_EMPRESA,
    G.CVE_EMPRESA,
    G.ID_PRESTAMO_GRUPO AS ID_PRESTAMO,
    A.F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.F_APLICACION,
    '',
    0,
    INITCAP(D.DESC_LARGA) AS DESCRIPCION,
    CASE
      WHEN D.CVE_AFECTA_CREDITO LIKE ('%D%')
      THEN A.IMP_NETO
      WHEN D.CVE_AFECTA_CREDITO LIKE ('%I%')
      THEN -A.IMP_NETO
    END AS IMP_PAGO,
    0   AS IMP_CONCEPTO,
    A.ID_MOVIMIENTO
  FROM SIM_PRESTAMO_GPO_DET G,
    PFIN_MOVIMIENTO A,
    PFIN_CAT_OPERACION D
  WHERE G.CVE_GPO_EMPRESA   = A.CVE_GPO_EMPRESA
  AND G.CVE_EMPRESA         = A.CVE_EMPRESA
  AND G.ID_PRESTAMO         = A.ID_PRESTAMO
  AND A.SIT_MOVIMIENTO     <> 'CA'
  AND D.CVE_GPO_EMPRESA     = A.CVE_GPO_EMPRESA
  AND D.CVE_EMPRESA         = A.CVE_EMPRESA
  AND D.CVE_OPERACION       = A.CVE_OPERACION
  AND D.CVE_AFECTA_CREDITO IN ('D','I')
  GROUP BY G.CVE_GPO_EMPRESA,
    G.CVE_EMPRESA,
    G.ID_PRESTAMO_GRUPO,
    A.F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.F_APLICACION,
    '',
    0,
    INITCAP(D.DESC_LARGA),
    CASE
      WHEN D.CVE_AFECTA_CREDITO LIKE ('%D%')
      THEN A.IMP_NETO
      WHEN D.CVE_AFECTA_CREDITO LIKE ('%I%')
      THEN -A.IMP_NETO
    END,
    0,
    A.ID_MOVIMIENTO;