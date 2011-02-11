
  CREATE OR REPLACE FORCE VIEW "V_MOV_EDO_CTA_IND" ("CVE_GPO_EMPRESA", "CVE_EMPRESA", "ID_PRESTAMO", "F_OPERACION", "NUM_PAGO_AMORTIZACION", "F_APLICACION", "DESC_MOVIMIENTO", "IMP_PAGO", "IMP_CONCEPTO", "ID_MOVIMIENTO") AS 
  SELECT A.CVE_GPO_EMPRESA,
    A.CVE_EMPRESA,
    A.ID_PRESTAMO,
    A.FECHA_AMORTIZACION AS F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.FECHA_AMORTIZACION AS F_APLICACION,
    INITCAP(B.DESC_CORTA),
    0              AS IMP_PAGO,
    A.IMP_ORIGINAL AS IMP_CONCEPTO,
    0              AS ID_MOVIMIENTO
  FROM V_SIM_TABLA_AMORT_CONCEPTO A,
    PFIN_CAT_CONCEPTO B
  WHERE A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA
  AND A.CVE_EMPRESA       = B.CVE_EMPRESA
  AND A.CVE_CONCEPTO      = B.CVE_CONCEPTO
  AND A.IMP_ORIGINAL     <> 0
  UNION ALL
  SELECT A.CVE_GPO_EMPRESA,
    A.CVE_EMPRESA,
    A.ID_PRESTAMO,
    A.F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.F_APLICACION,
    CASE
      WHEN A.TX_NOTA = 'Movimiento extraordinario'
      THEN D.DESC_LARGA
      WHEN A.TX_NOTA = 'Pago de prestamo'
      THEN 'Pago '
        || INITCAP(C.DESC_CORTA)
    END AS DESCRIPCION,
    0   AS IMP_PAGO,
    CASE
      WHEN D.CVE_AFECTA_CREDITO = 'D'
      THEN B.IMP_CONCEPTO
      WHEN D.CVE_AFECTA_CREDITO = 'I'
      THEN -B.IMP_CONCEPTO
    END AS IMP_CONCEPTO,
    A.ID_MOVIMIENTO
  FROM PFIN_MOVIMIENTO A,
    PFIN_MOVIMIENTO_DET B,
    PFIN_CAT_CONCEPTO C,
    PFIN_CAT_OPERACION D
  WHERE A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA
  AND A.CVE_EMPRESA       = B.CVE_EMPRESA
  AND A.ID_MOVIMIENTO     = B.ID_MOVIMIENTO
  AND A.SIT_MOVIMIENTO   <> 'CA'
  AND B.CVE_GPO_EMPRESA   = C.CVE_GPO_EMPRESA
  AND B.CVE_EMPRESA       = C.CVE_EMPRESA
  AND B.CVE_CONCEPTO      = C.CVE_CONCEPTO
  AND D.CVE_GPO_EMPRESA   = A.CVE_GPO_EMPRESA
  AND D.CVE_EMPRESA       = A.CVE_EMPRESA
  AND D.CVE_OPERACION     = A.CVE_OPERACION
  UNION ALL
  SELECT A.CVE_GPO_EMPRESA,
    A.CVE_EMPRESA,
    A.ID_PRESTAMO,
    A.F_OPERACION,
    A.NUM_PAGO_AMORTIZACION,
    A.F_APLICACION,
    CASE
      WHEN A.TX_NOTA = 'Pago de prestamo'
      THEN 'Pago prestamo'
    END AS DESCRIPCION,
    CASE
      WHEN A.TX_NOTA = 'Pago de prestamo'
      THEN A.IMP_NETO
    END AS IMP_PAGO,
    0   AS IMP_CONCEPTO,
    A.ID_MOVIMIENTO
  FROM PFIN_MOVIMIENTO A,
    PFIN_CAT_OPERACION D
  WHERE A.SIT_MOVIMIENTO <> 'CA'
  AND D.CVE_GPO_EMPRESA   = A.CVE_GPO_EMPRESA
  AND D.CVE_EMPRESA       = A.CVE_EMPRESA
  AND D.CVE_OPERACION     = A.CVE_OPERACION;
 