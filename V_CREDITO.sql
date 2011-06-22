CREATE OR REPLACE PACKAGE PKG_CREDITO AS

    -- Declaraci�n de variables globales
    vgFechaSistema                      DATE;
    vgFolioGrupo                        NUMBER;
    cFalso                              CONSTANT VARCHAR2(1)                                     := 'F';
    cVerdadero                          CONSTANT VARCHAR2(1)                                     := 'V';
    cDecrementa                         CONSTANT VARCHAR2(1)                                     := 'D';
    cIncrementa                         CONSTANT VARCHAR2(1)                                     := 'I';
    cNoAplica                           CONSTANT VARCHAR2(1)                                     := 'N';    
    cDivisaPeso                         CONSTANT PFIN_MOVIMIENTO.CVE_DIVISA%TYPE                 := 'MXP';
    cPagoPrestamo                       CONSTANT PFIN_MOVIMIENTO.CVE_OPERACION%TYPE              := 'CRPAGOPRES';
    cAbonoAjuste                        CONSTANT PFIN_MOVIMIENTO.CVE_OPERACION%TYPE              := 'ABAJUS';
    cCargoAjuste                        CONSTANT PFIN_MOVIMIENTO.CVE_OPERACION%TYPE              := 'CAAJUS';
    cPagoDefuncion                      CONSTANT PFIN_MOVIMIENTO.CVE_OPERACION%TYPE              := 'EXTDEF';
    cCancelaPago                        CONSTANT PFIN_MOVIMIENTO.CVE_OPERACION%TYPE              := 'CANPAG';
    cDepositoTesoreria                  CONSTANT PFIN_MOVIMIENTO.CVE_OPERACION%TYPE              := 'TEDEPEFE';    
    cImpBruto                           CONSTANT PFIN_MOVIMIENTO_DET.CVE_CONCEPTO%TYPE           := 'IMPBRU';
    cSitCancelada                       CONSTANT PFIN_MOVIMIENTO.SIT_MOVIMIENTO%TYPE             := 'CA';
    vgResultado                         NUMBER;
    cEtapaLiquidado                     CONSTANT SIM_CAT_ETAPA_PRESTAMO.ID_ETAPA_PRESTAMO%TYPE   := 8;
    cEtapaLiqXDefuncion                 CONSTANT SIM_CAT_ETAPA_PRESTAMO.ID_ETAPA_PRESTAMO%TYPE   := 8;    
    
    -- Procedimiento que actuliza la informacion variable de los creditos, esto lo realiza para todas las amortizaciones
    -- pendientes de pago
    --      Por atraso: Pago tardio, interes moratorio e IVA de interes moratorio
    --      Intereses devengados: Interes devengado del dia e interes devengado acumulado en el mes
    FUNCTION fActualizaInformacionCredito(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                          pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                          pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                          pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                          pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER;    

    --********************************************************************************************************--
    --*     pGeneraTablaAmortizacion                                                                         *--
    --*     Prop�sito:  Generar la tabla de amortizaci�n de un pr�stamo de un cliente                        *--
    --*     Par�metros:                                                                                      *--
    --*         pCveGpoEmpresa:     Clave de Grupo de Empresa                                                *--
    --*         pCveEmpresa:        Clave de Empresa                                                         *--
    --*         pIdPrestamo:        Indentificador del pr�stamo                                              *--
    --*         pTxRespuesta:       Par�metro de salida que indica el resultado de la operaci�n              *--
    --********************************************************************************************************--
    PROCEDURE pGeneraTablaAmortizacion(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                       pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                       pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                                       pTxrespuesta     OUT VARCHAR2);


    --********************************************************************************************************--
    --*     pAplicaPagoCreditoPorAmort                                                                       *--
    --*     Prop�sito:  Aplicar el pago de un pr�stamo y distribuirlo en los diferentes conceptos            *--
    --*                 este pago puede ser por ajuste, defuncion o pago normal                              *--
    --*                 Este metodo es el que inserta el pago para cada amortizacion ya que los pagos        *--
    --*                 se realizan para cada una de las amortizaciones                                      *--
    --********************************************************************************************************--    
    FUNCTION pAplicaPagoCreditoPorAmort(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                         pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                         pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                         pNumAmortizacion IN SIM_TABLA_AMORTIZACION.NUM_PAGO_AMORTIZACION%TYPE,                                         
                                         pImportePago     IN PFIN_MOVIMIENTO.IMP_NETO%TYPE,
                                         pIdCuenta        IN PFIN_MOVIMIENTO.ID_CUENTA%TYPE,
                                         pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                         pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                         pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                         pIdGrupo         IN PFIN_PRE_MOVIMIENTO.ID_GRUPO%TYPE,
                                         pTxrespuesta     OUT VARCHAR2)
    RETURN NUMBER;

    --********************************************************************************************************--
    --*     pAplicaPagoCredito (Recargado para que no pida pCveOperacion)                                    *--
    --*     Prop�sito:  Aplicar el pago de un pr�stamo y distribuirlo en los diferentes conceptos            *--
    --*                 este metodo envia siempre la pCveOperacion = cPagoPrestamo                           *--
    --*                 Es utilizado para el llamado desde la pantalla de pago de prestamo                   *--
    --********************************************************************************************************--
    PROCEDURE pAplicaPagoCredito(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                 pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                 pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                 pIdGrupo         IN PFIN_PRE_MOVIMIENTO.ID_GRUPO%TYPE,
                                 pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                 pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                 pTxrespuesta     OUT VARCHAR2);

    --********************************************************************************************************--
    --*     pAplicaPagoCredito                                                                               *--
    --*     Prop�sito:  Aplicar el pago de un pr�stamo y distribuirlo en los diferentes conceptos            *--
    --*                 este pago puede ser por ajuste, defuncion o pago normal                              *--
    --********************************************************************************************************--
    PROCEDURE pAplicaPagoCredito(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                 pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                 pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                 pIdGrupo         IN PFIN_PRE_MOVIMIENTO.ID_GRUPO%TYPE,
                                 pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                 pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                 pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                 pTxrespuesta     OUT VARCHAR2);

    --********************************************************************************************************--
    --*     DameFechaValida                                                                                  *--
    --*     Prop�sito:  Obtener una fecha v�lida para las amortizaciones y fechas de liquidaci�n             *--
    --*     Par�metros:                                                                                      *--
    --*         pCveGpoEmpresa:     Clave de Grupo de Empresa                                                *--
    --*         pCveEmpresa:        Clave de Empresa                                                         *--
    --*         pFecha              Fecha a validar                                                          *--
    --*         pCvePais            Clave del pa�s a validar d�as festivos                                   *--
    --*         pTxRespuesta:       Par�metro de salida que indica el resultado de la operaci�n              *--
    --********************************************************************************************************--
    FUNCTION DameFechaValida (pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                              pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                              pFecha           IN SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE,
                              pCvePais         IN PFIN_DIA_FESTIVO.CVE_PAIS%TYPE,
                              pTxRespuesta    OUT VARCHAR2)
    RETURN SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE;


    --********************************************************************************************************--
    --*     DameTasaMoratoriaDiaria                                                                          *--
    --*     Prop�sito:  Obtener la tasa de inter�s moratorio en caso de aplicar, de lo contrario regresa 0   *--
    --*     Par�metros:                                                                                      *--
    --*         pCveGpoEmpresa:     Clave de Grupo de Empresa                                                *--
    --*         pCveEmpresa:        Clave de Empresa                                                         *--
    --*         pIdPrestamo         Identificador del pr�stamo                                               *--
    --********************************************************************************************************--
    FUNCTION DameTasaMoratoriaDiaria(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                     pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE)
    RETURN SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE;

    --********************************************************************************************************--
    --*     dameIdTasaRefDet                                                                                 *--
    --*     Prop�sito:  Obtener el Id de referencia m�s actual de una tasa                                   *--
    --*     Par�metros:                                                                                      *--
    --*         pCveGpoEmpresa:     Clave de Grupo de Empresa                                                *--
    --*         pCveEmpresa:        Clave de Empresa                                                         *--
    --*         pIdTasaRef:         Identificador de la tasa de referencia                                   *--
    --********************************************************************************************************--
    FUNCTION dameIdTasaRefDet(  pCveGpoEmpresa  IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                pCveEmpresa     IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                pIdTasaRef      IN SIM_CAT_TASA_REFER_DETALLE.ID_TASA_REFERENCIA%TYPE)
    RETURN SIM_CAT_TASA_REFER_DETALLE.ID_TASA_REFERENCIA_DETALLE%TYPE;
    
    -- Metodo que se ejecuta para actualizar los acumulados de la tabla de amortizacion
    PROCEDURE pActualizaTablaAmortizacion(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                          pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                          pIdMovimiento    IN PFIN_MOVIMIENTO.ID_MOVIMIENTO%TYPE,
                                          pTxRespuesta     OUT VARCHAR2);    

    -- Funcion que determina la proporcion del pago de acuerdo a un importe
    FUNCTION fCalculaProporcion(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                pImpPago         IN PFIN_MOVIMIENTO.IMP_NETO%TYPE,
                                pTxRespuesta     OUT VARCHAR2)
    RETURN SYS_REFCURSOR;

    -- Funcion utilizada para registrar el pago total de un credito individual en caso de que muera la persona
    FUNCTION fRegistraMovtoDefuncion(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                     pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                     pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                     pFValor          IN PFIN_PRE_MOVIMIENTO.F_OPERACION%TYPE,
                                     pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER;
    
    -- Funcion utilizada para cancelar el ultimo pago que se haya aplicado al credito
    FUNCTION fCancelaPago(pCveGpoEmpresa    IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                          pCveEmpresa       IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                          pIdMovimientoPago IN PFIN_PRE_MOVIMIENTO.ID_MOVIMIENTO%TYPE,
                          pCveUsuario       IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                          pTxRespuesta      OUT VARCHAR2)
    RETURN NUMBER;

    -- Funcion utilizada para registrar los diferentes tipos de movimientos extraordinarios
    FUNCTION fRegistraMovtoExtraordinario(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                          pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                          pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                          pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                          pArrayConceptos  IN TT_MOVTO_AJUSTE,
                                          pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER;
    
    -- Funcion utilizada para registrar los diferentes tipos de pagos extraordinarios
    FUNCTION fRegistraMovtoExtraPago(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                     pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                     pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                     pArrayConceptos  IN TT_MOVTO_AJUSTE,
                                     pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER;

    -- Funcion utilizada para registrar los diferentes tipos de cobros extraordinarios
    FUNCTION fRegistraMovtoExtraCobro(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                      pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                      pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                      pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                      pArrayConceptos  IN TT_MOVTO_AJUSTE,
                                      pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER;

    FUNCTION TestMovtoExtraordinario(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                     pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                     pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                     pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER;
    
End Pkg_Credito;
/


CREATE OR REPLACE PACKAGE BODY PKG_CREDITO AS
    FUNCTION fObtieneCuenta(pCveGpoEmpresa   IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                            pCveEmpresa      IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                            pIdPrestamo      IN PFIN_MOVIMIENTO.ID_PRESTAMO%TYPE,
                            pTxrespuesta    OUT VARCHAR2)
    RETURN SIM_PRESTAMO.ID_CUENTA_REFERENCIA%TYPE
    IS
       vlIdCuenta  SIM_PRESTAMO.ID_CUENTA_REFERENCIA%TYPE;    
    BEGIN
       SELECT NVL(ID_CUENTA_REFERENCIA,0), 
              CASE WHEN NVL(ID_CUENTA_REFERENCIA,0) = 0 THEN 'No existe cuenta asociada al credito'
                   ELSE ''
              END
         INTO vlIdCuenta, pTxrespuesta
         FROM SIM_PRESTAMO
        WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
          AND CVE_EMPRESA     = pCveEmpresa
          AND ID_PRESTAMO     = pIdPrestamo;
        
       RETURN vlIdCuenta;
       
       EXCEPTION   
          WHEN NO_DATA_FOUND THEN
               pTxrespuesta := 'No existe el prestamo';
               RETURN -1;
    END fObtieneCuenta;

    FUNCTION fEsPrestamoGrupal(pCveGpoEmpresa   IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                pCveEmpresa      IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                pIdPrestamo      IN PFIN_MOVIMIENTO.ID_PRESTAMO%TYPE)
    RETURN SIM_PRESTAMO.B_ENTREGADO%TYPE
    IS
       vlBEsGrupo SIM_PRESTAMO.B_ENTREGADO%TYPE;
    BEGIN
       -- Valida que el prestamo exsita en la tabla grupal
       BEGIN
          SELECT cVerdadero
            INTO vlBEsGrupo
            FROM SIM_PRESTAMO_GRUPO
           WHERE CVE_GPO_EMPRESA   = pCveGpoEmpresa
             AND CVE_EMPRESA       = pCveEmpresa
             AND ID_PRESTAMO_GRUPO = pIdPrestamo;
             
          EXCEPTION WHEN NO_DATA_FOUND THEN vlBEsGrupo := cFalso;
             
       END;      
       
       RETURN vlBEsGrupo;
       
    END fEsPrestamoGrupal;

    FUNCTION fExistePresamoIndividual(pCveGpoEmpresa   IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                       pCveEmpresa      IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                       pIdPrestamo      IN PFIN_MOVIMIENTO.ID_PRESTAMO%TYPE)
    RETURN SIM_PRESTAMO.B_ENTREGADO%TYPE
    IS
       vlBExistePresIndiv SIM_PRESTAMO.B_ENTREGADO%TYPE;
    BEGIN
       -- Valida que el prestamo exsita en la tabla grupal
       BEGIN
          SELECT cVerdadero
            INTO vlBExistePresIndiv
            FROM SIM_PRESTAMO
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
             AND CVE_EMPRESA     = pCveEmpresa
             AND ID_PRESTAMO     = pIdPrestamo;
             
          EXCEPTION WHEN NO_DATA_FOUND THEN vlBExistePresIndiv := cFalso;
             
       END;      
       
       RETURN vlBExistePresIndiv;
       
    END fExistePresamoIndividual;

    FUNCTION actualizaDiasAntiguedad (pCveGpoEmpresa   IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                      pCveEmpresa      IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                      pFValor          IN PFIN_PARAMETRO.F_MEDIO%TYPE,
                                      pImpDeudaMinima IN SIM_PARAMETRO_GLOBAL.IMP_DEUDA_MINIMA%TYPE)
    RETURN NUMBER
    IS
    
      vlFechaDiasAntiguedad DATE;
      vlDiasAntiguedad NUMBER;
      vlValorEncontrado VARCHAR2(1);
      vlIdDistribucionPago SIM_CAT_FORMA_DISTRIBUCION.ID_FORMA_DISTRIBUCION%TYPE;
      vlSumaPagosCapital SIM_TABLA_AMORTIZACION.IMP_CAPITAL_AMORT_PAGADO%TYPE;
      vlIdPrestamo NUMBER;
    
      --Cursor prestamos
      CURSOR curPrestamos IS
        SELECT P.ID_PRESTAMO, P.ID_GRUPO
          FROM SIM_PRESTAMO P
         WHERE P.CVE_GPO_EMPRESA = pCveGpoEmpresa
           AND P.CVE_EMPRESA     = pCveEmpresa
        ORDER BY P.ID_PRESTAMO;
        
      --Cursor de cada importe que se tiene que pagar a capital y su fecha de amortizaci�n para un prestamo
      CURSOR curAmortizacionesCapital IS
        SELECT IMP_CAPITAL_AMORT, FECHA_AMORTIZACION
          FROM SIM_TABLA_AMORTIZACION
         WHERE CVE_GPO_EMPRESA   = pCveGpoEmpresa
           AND CVE_EMPRESA       = pCveEmpresa
           AND ID_PRESTAMO       = vlIdPrestamo
         ORDER BY NUM_PAGO_AMORTIZACION;        
     
    BEGIN
      -- Itera todos los prestamos
      FOR vlBufPrestamo IN curPrestamos LOOP
      
        vlFechaDiasAntiguedad  := '';
        vlDiasAntiguedad       := 0;  
        vlValorEncontrado      := CFALSO;
        
        --Obtienen la forma de distribucion del pago del prestamo
        SELECT NVL(P.ID_FORMA_DISTRIBUCION,0) ID_FORMA_DISTRIBUCION
          INTO vlIdDistribucionPago
          FROM SIM_PRESTAMO P, SIM_CAT_FORMA_DISTRIBUCION D
         WHERE P.CVE_GPO_EMPRESA          = pCveGpoEmpresa
           AND P.CVE_EMPRESA              = pCveEmpresa
           AND P.ID_PRESTAMO              = vlBufPrestamo.ID_PRESTAMO
           AND D.CVE_GPO_EMPRESA(+)       = P.CVE_GPO_EMPRESA
           AND D.CVE_EMPRESA(+)           = P.CVE_EMPRESA
           AND D.ID_FORMA_DISTRIBUCION(+) = P.ID_FORMA_DISTRIBUCION;
           
        IF vlIdDistribucionPago = 1 THEN
          --El calculo de dias de antiguedad se hace sobre el capital
          --Falta incluir cuando el �ltimo concepto a pagar es un accesorio
          
          --Obtiene la suma total de pagos aplicados a capital del prestamo
          SELECT SUM(TA.IMP_CAPITAL_AMORT_PAGADO) IMP_CAPITAL_AMORT_PAGADO
            INTO vlSumaPagosCapital
            FROM SIM_TABLA_AMORTIZACION TA
           WHERE TA.CVE_GPO_EMPRESA = pCveGpoEmpresa
             AND TA.CVE_EMPRESA     = pCveEmpresa
             AND TA.ID_PRESTAMO     = vlBufPrestamo.ID_PRESTAMO;
            
          vlIdPrestamo := vlBufPrestamo.ID_PRESTAMO;
          
          -- Itera cada importe que se tiene que pagar a capital y su fecha de amortizaci�n de un prestamo
          FOR vlBufAmortizaciones IN curAmortizacionesCapital LOOP
            
            vlSumaPagosCapital := vlSumaPagosCapital - vlBufAmortizaciones.IMP_CAPITAL_AMORT;
            IF  vlValorEncontrado = CFALSO THEN
              IF (vlSumaPagosCapital < -pImpDeudaMinima AND pFValor >=  vlBufAmortizaciones.FECHA_AMORTIZACION) THEN
                --En esta fecha no alcanzo a cubrir el pago a Capital
                vlFechaDiasAntiguedad := vlBufAmortizaciones.FECHA_AMORTIZACION;
                --Resta de la fecha valor la fecha donde no alcanzo a pagar el capital
                vlDiasAntiguedad := pFValor -vlFechaDiasAntiguedad;
                vlValorEncontrado := CVERDADERO;
 
              END IF;
            END IF;
            
          END LOOP;
        
         --Actualiza los d�as de antiguedad para el prestamo individual
         UPDATE SIM_PRESTAMO
             SET NUM_DIAS_ANTIGUEDAD = vlDiasAntiguedad
           WHERE CVE_GPO_EMPRESA     = pCveGpoEmpresa
             AND CVE_EMPRESA         = pCveEmpresa
             AND ID_PRESTAMO         = vlIdPrestamo;
          
          --Actualiza los d�as de antiguedad para el prestamo grupal
          UPDATE SIM_PRESTAMO_GRUPO
             SET NUM_DIAS_ANTIGUEDAD = CASE WHEN vlDiasAntiguedad >= NVL(NUM_DIAS_ANTIGUEDAD,0) THEN vlDiasAntiguedad
                                            ELSE NUM_DIAS_ANTIGUEDAD
                                       END
           WHERE CVE_GPO_EMPRESA     = pCveGpoEmpresa
             AND CVE_EMPRESA         = pCveEmpresa
             AND ID_GRUPO            = vlBufPrestamo.ID_GRUPO;             
        
        END IF;
      
      END LOOP;
      
      RETURN 0;
      
      EXCEPTION
        WHEN OTHERS THEN RETURN -1;
    END actualizaDiasAntiguedad;
    
    FUNCTION actualizaFechasPrestamo (pCveGpoEmpresa  IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                      pCveEmpresa     IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                      pIdPrestamo     IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                                      pBGrupo         IN SIM_TABLA_AMORTIZACION.B_PAGADO%TYPE)
    RETURN NUMBER
    IS
      CURSOR curPrestamos IS
        SELECT CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO,
               MAX(CASE WHEN B_PAGADO = 'F' THEN FECHA_AMORTIZACION ELSE NULL END) AS F_ULT_AMORTIZACION,           
               MAX(FECHA_AMORT_PAGO_ULTIMO) AS F_ULT_PAGO_REALIZADO,
               MIN(CASE WHEN B_PAGADO = 'F' THEN FECHA_AMORTIZACION ELSE NULL END) AS F_PROX_PAGO
          FROM SIM_TABLA_AMORTIZACION 
         WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
               CVE_EMPRESA     = pCveEmpresa
         GROUP BY CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO;
         
      CURSOR curPrestamo IS
        SELECT CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO,
               MAX(CASE WHEN B_PAGADO = 'F' THEN FECHA_AMORTIZACION ELSE NULL END) AS F_ULT_AMORTIZACION,           
               MAX(FECHA_AMORT_PAGO_ULTIMO) AS F_ULT_PAGO_REALIZADO,
               MIN(CASE WHEN B_PAGADO = 'F' THEN FECHA_AMORTIZACION ELSE NULL END) AS F_PROX_PAGO
          FROM SIM_TABLA_AMORTIZACION 
         WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
               CVE_EMPRESA     = pCveEmpresa    AND
               ID_PRESTAMO     = pIdPrestamo
         GROUP BY CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO;

      CURSOR curPrestamoGpo IS
        SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO,
               MAX(CASE WHEN B_PAGADO = 'F' THEN FECHA_AMORTIZACION ELSE NULL END) AS F_ULT_AMORTIZACION,           
               MAX(FECHA_AMORT_PAGO_ULTIMO) AS F_ULT_PAGO_REALIZADO,
               MIN(CASE WHEN B_PAGADO = 'F' THEN FECHA_AMORTIZACION ELSE NULL END) AS F_PROX_PAGO
          FROM SIM_PRESTAMO_GPO_DET A, SIM_TABLA_AMORTIZACION B
         WHERE A.CVE_GPO_EMPRESA   = pCveGpoEmpresa    AND
               A.CVE_EMPRESA       = pCveEmpresa       AND
               A.ID_PRESTAMO_GRUPO = pIdPrestamo       AND
               A.CVE_GPO_EMPRESA   = B.CVE_GPO_EMPRESA AND
               A.CVE_EMPRESA       = B.CVE_EMPRESA     AND
               A.ID_PRESTAMO       = B.ID_PRESTAMO
         GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO;
         
    BEGIN
      -- Elige el cursor de un prestamo o de todos, si el parametro es cero significa que debe actualizar todos los prestamos
      IF pIdPrestamo = 0 THEN
         FOR vlBufPrestamo IN curPrestamos LOOP
             -- Actualiza todos los prestamos
             UPDATE SIM_PRESTAMO
                SET F_ULT_PAGO_REALIZADO = vlBufPrestamo.F_ULT_PAGO_REALIZADO,
                    F_PROX_PAGO          = vlBufPrestamo.F_PROX_PAGO,
                    F_ULT_AMORTIZACION   = vlBufPrestamo.F_ULT_AMORTIZACION
              WHERE CVE_GPO_EMPRESA = vlBufPrestamo.CVE_GPO_EMPRESA AND
                    CVE_EMPRESA     = vlBufPrestamo.CVE_EMPRESA     AND
                    ID_PRESTAMO     = vlBufPrestamo.ID_PRESTAMO;
         END LOOP;
      ELSE
         IF pBGrupo = cFalso THEN
            FOR vlBufPrestamo IN curPrestamo LOOP
                -- Actualiza un prestamo
                UPDATE SIM_PRESTAMO
                   SET F_ULT_PAGO_REALIZADO = vlBufPrestamo.F_ULT_PAGO_REALIZADO,
                       F_PROX_PAGO          = vlBufPrestamo.F_PROX_PAGO,
                       F_ULT_AMORTIZACION   = vlBufPrestamo.F_ULT_AMORTIZACION
                 WHERE CVE_GPO_EMPRESA = vlBufPrestamo.CVE_GPO_EMPRESA AND
                       CVE_EMPRESA     = vlBufPrestamo.CVE_EMPRESA     AND
                       ID_PRESTAMO     = vlBufPrestamo.ID_PRESTAMO;
            END LOOP;
         ELSE
            FOR vlBufPrestamo IN curPrestamoGpo LOOP
                -- Actualiza los prestamos de un grupo
                UPDATE SIM_PRESTAMO
                   SET F_ULT_PAGO_REALIZADO = vlBufPrestamo.F_ULT_PAGO_REALIZADO,
                       F_PROX_PAGO          = vlBufPrestamo.F_PROX_PAGO,
                       F_ULT_AMORTIZACION   = vlBufPrestamo.F_ULT_AMORTIZACION
                 WHERE CVE_GPO_EMPRESA = vlBufPrestamo.CVE_GPO_EMPRESA AND
                       CVE_EMPRESA     = vlBufPrestamo.CVE_EMPRESA     AND
                       ID_PRESTAMO     = vlBufPrestamo.ID_PRESTAMO;
            END LOOP;
         
         END IF;
      END IF;
      
      RETURN 0;
      
      EXCEPTION
        WHEN OTHERS THEN RETURN -1;
    END actualizaFechasPrestamo;
    
    FUNCTION actualizaFechasPrestamoGpo (pCveGpoEmpresa  IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                         pCveEmpresa     IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                         pIdPrestamo     IN SIM_PRESTAMO.ID_PRESTAMO%TYPE)
    RETURN NUMBER
    IS
      CURSOR curPrestamos IS
        SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO AS ID_PRESTAMO,
               MAX(B.F_ULT_AMORTIZACION) AS F_ULT_AMORTIZACION,           
               MAX(B.F_ULT_PAGO_REALIZADO) AS F_ULT_PAGO_REALIZADO,
               MIN(B.F_PROX_PAGO) AS F_PROX_PAGO
          FROM SIM_PRESTAMO_GPO_DET A, SIM_PRESTAMO B
         WHERE A.CVE_GPO_EMPRESA = pCveGpoEmpresa    AND
               A.CVE_EMPRESA     = pCveEmpresa       AND
               A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA AND
               A.CVE_EMPRESA     = B.CVE_EMPRESA     AND
               A.ID_PRESTAMO     = B.ID_PRESTAMO
         GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO;
         
      CURSOR curPrestamo IS
        SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO AS ID_PRESTAMO,
               MAX(B.F_ULT_AMORTIZACION) AS F_ULT_AMORTIZACION,           
               MAX(B.F_ULT_PAGO_REALIZADO) AS F_ULT_PAGO_REALIZADO,
               MIN(B.F_PROX_PAGO) AS F_PROX_PAGO
          FROM SIM_PRESTAMO_GPO_DET A, SIM_PRESTAMO B
         WHERE A.CVE_GPO_EMPRESA   = pCveGpoEmpresa  AND
               A.CVE_EMPRESA       = pCveEmpresa     AND
               A.ID_PRESTAMO_GRUPO = pIdPrestamo     AND
               A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA AND
               A.CVE_EMPRESA     = B.CVE_EMPRESA     AND
               A.ID_PRESTAMO     = B.ID_PRESTAMO
         GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO;

    BEGIN
      -- Elige el cursor de un prestamo o de todos, si el parametro es cero significa que debe actualizar todos los prestamos
      IF pIdPrestamo = 0 THEN
         FOR vlBufPrestamo IN curPrestamos LOOP
             -- Actualiza todos los prestamos
             UPDATE SIM_PRESTAMO_GRUPO
                SET F_ULT_PAGO_REALIZADO = vlBufPrestamo.F_ULT_PAGO_REALIZADO,
                    F_PROX_PAGO          = vlBufPrestamo.F_PROX_PAGO,
                    F_ULT_AMORTIZACION   = vlBufPrestamo.F_ULT_AMORTIZACION
              WHERE CVE_GPO_EMPRESA   = vlBufPrestamo.CVE_GPO_EMPRESA AND
                    CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                    ID_PRESTAMO_GRUPO = vlBufPrestamo.ID_PRESTAMO;
         END LOOP;
      ELSE
         FOR vlBufPrestamo IN curPrestamo LOOP
             -- Actualiza un prestamo de grupo
             UPDATE SIM_PRESTAMO_GRUPO
                SET F_ULT_PAGO_REALIZADO = vlBufPrestamo.F_ULT_PAGO_REALIZADO,
                    F_PROX_PAGO          = vlBufPrestamo.F_PROX_PAGO,
                    F_ULT_AMORTIZACION   = vlBufPrestamo.F_ULT_AMORTIZACION
              WHERE CVE_GPO_EMPRESA   = vlBufPrestamo.CVE_GPO_EMPRESA AND
                    CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                    ID_PRESTAMO_GRUPO = vlBufPrestamo.ID_PRESTAMO;
         END LOOP;
      END IF;
      
      RETURN 0;
      
      EXCEPTION
        WHEN OTHERS THEN RETURN -1;
    END actualizaFechasPrestamoGpo;
    
    FUNCTION dameIdTasaRefDet(  pCveGpoEmpresa  IN PFIN_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                pCveEmpresa     IN PFIN_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                pIdTasaRef      IN SIM_CAT_TASA_REFER_DETALLE.ID_TASA_REFERENCIA%TYPE)
    RETURN SIM_CAT_TASA_REFER_DETALLE.ID_TASA_REFERENCIA_DETALLE%TYPE
    IS 
        IdTasaRefDet  SIM_CAT_TASA_REFER_DETALLE.ID_TASA_REFERENCIA_DETALLE%TYPE;
        vlFBusqueda   DATE;
    BEGIN
        -- Inicializa la fecha de busqueda con la fecha del sistema
        vlFBusqueda := vgFechaSistema;
    
        -- Se obtiene la tasa de referencia de la fecha mas cercana a la fecha de busqueda siempre y cuando sea menor o igual a la fecha de busqueda
        SELECT  NVL(ID_TASA_REFERENCIA_DETALLE,0)
        INTO    IdTasaRefDet
        FROM    SIM_CAT_TASA_REFER_DETALLE
        WHERE   CVE_GPO_EMPRESA             = pCveGpoEmpresa
            AND CVE_EMPRESA                 = pCveEmpresa
            AND ID_TASA_REFERENCIA          = pIdTasaRef
            AND FECHA_PUBLICACION           = (SELECT NVL(MAX(FECHA_PUBLICACION),NULL)
                                                 FROM SIM_CAT_TASA_REFER_DETALLE
                                                WHERE CVE_GPO_EMPRESA             = pCveGpoEmpresa
                                                  AND CVE_EMPRESA                 = pCveEmpresa
                                                  AND ID_TASA_REFERENCIA          = pIdTasaRef
                                                  AND FECHA_PUBLICACION          <= vlFBusqueda);
                
        RETURN IdTasaRefDet;
        
        EXCEPTION
            WHEN OTHERS THEN
                RETURN NULL;
    END dameIdTasaRefDet;

    FUNCTION DameTasaAmort(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                           pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                           pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                           pTasaIva         IN SIM_CAT_SUCURSAL.TASA_IVA%TYPE,
                           pTxRespuesta    OUT VARCHAR2)
    RETURN SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE
    IS
        vlTasaInteres   SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE;
    BEGIN
        -- Se obtiene el valor de la tasa, en caso de no ser indexada toma la tasa del prestamo, de lo contrario
        -- toma la tasa de referencia.
        -- A la tasa que obtiene le suma el IVA que recibe como parametro
        -- Al valor resultante lo divide entre los dias de la periodicidad del prestamo em caso de no ser indexada la tasa
        -- de lo contrario lo divide entre la periodicidad de la tasa de referencia.
        -- por ultimo multiplica el dato por los dias del prestamo.
        SELECT 	ROUND(DECODE(P.TIPO_TASA,'No indexada', P.VALOR_TASA, T.VALOR)
                        * (1 + pTasaIva / 100) / 100
			/ DECODE(P.TIPO_TASA,'No indexada', PT.DIAS, PTI.DIAS)
			* PP.DIAS
                      ,20) AS TASA_INTERES
           INTO vlTasaInteres
           FROM SIM_PRESTAMO P, SIM_CAT_PERIODICIDAD PT, SIM_CAT_PERIODICIDAD PTI,
                SIM_CAT_PERIODICIDAD PP, SIM_CAT_TASA_REFER_DETALLE T, SIM_CAT_TASA_REFERENCIA TR
          WHERE P.CVE_GPO_EMPRESA 	        = pCveGpoEmpresa
            AND P.CVE_EMPRESA     	        = pCveEmpresa
            AND P.ID_PRESTAMO     	        = pIdPrestamo
            AND P.CVE_GPO_EMPRESA 	        = PT.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = PT.CVE_EMPRESA(+)
            AND P.ID_PERIODICIDAD_TASA      = PT.ID_PERIODICIDAD(+)
            AND P.CVE_GPO_EMPRESA 	        = PP.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = PP.CVE_EMPRESA(+)
            AND P.ID_PERIODICIDAD_PRODUCTO  = PP.ID_PERIODICIDAD(+)
            AND P.CVE_GPO_EMPRESA 	        = TR.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = TR.CVE_EMPRESA(+)
            AND P.ID_TASA_REFERENCIA        = TR.ID_TASA_REFERENCIA(+)
            AND P.CVE_GPO_EMPRESA 	        = T.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = T.CVE_EMPRESA(+)
            AND P.ID_TASA_REFERENCIA        = T.ID_TASA_REFERENCIA(+)
            AND P.FECHA_TASA_REFERENCIA     = T.FECHA_PUBLICACION(+)
            AND TR.CVE_GPO_EMPRESA 	        = PTI.CVE_GPO_EMPRESA(+)
            AND TR.CVE_EMPRESA     	        = PTI.CVE_EMPRESA(+)
            AND TR.ID_PERIODICIDAD          = PTI.ID_PERIODICIDAD(+);

        IF vlTasaInteres IS NULL THEN
            -- Si no se pbtiene un valor regresa 0 y se indica el error
            pTxRespuesta := 'No se pudo obtener el valor de la tasa';
            RETURN 0;
        END IF;

        RETURN vlTasaInteres;

        EXCEPTION
            WHEN OTHERS THEN
                pTxRespuesta := SQLERRM;
                RETURN 0;

    END DameTasaAmort;

    FUNCTION DameTasaMoratoriaDiaria(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                     pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE)
    RETURN SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE
    IS
        vlTasaIntMora   SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE;
    BEGIN
        -- Se obtiene el valor de la tasa
        SELECT NVL(CASE WHEN P.ID_TIPO_RECARGO IN (3,5) THEN -- Si el tipo de recargo implica inter�s moratorio regresa el valor de la tasa
                             CASE WHEN P.TIPO_TASA_RECARGO = 'Fija independiente' THEN 
                                       ROUND(DECODE(P.TIPO_TASA,'No indexada', P.TASA_RECARGO, T.VALOR)/100/
            			 		                 DECODE(P.TIPO_TASA,'No indexada', PT.DIAS, TRV.DIAS) ,20)
                                  ELSE P.VALOR_TASA * P.FACTOR_TASA_RECARGO
                             END
                        ELSE 0 -- Si el recargo no es de tipo inter�s moratorio regresa 0 en el valor de la tasa
                   END, 0) AS TASA_INTERES_MORATORIO
          INTO vlTasaIntMora
          FROM SIM_PRESTAMO P, SIM_CAT_SUCURSAL S, SIM_CAT_PERIODICIDAD PT, SIM_CAT_PERIODICIDAD TRV, 
               SIM_CAT_TASA_REFER_DETALLE T, SIM_CAT_TASA_REFERENCIA TR
          WHERE P.CVE_GPO_EMPRESA 	            = pCveGpoEmpresa
            AND P.CVE_EMPRESA     	            = pCveEmpresa
            AND P.ID_PRESTAMO     	            = pIdPrestamo
            --  Recupera la informacion de la sucursal
            AND P.CVE_GPO_EMPRESA 	            = S.CVE_GPO_EMPRESA
            AND P.CVE_EMPRESA     	            = S.CVE_EMPRESA
            AND P.ID_SUCURSAL                   = S.ID_SUCURSAL
            --  Periodicidad de la tasa de recargo
            AND P.CVE_GPO_EMPRESA 	            = PT.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	            = PT.CVE_EMPRESA(+)
            AND P.ID_PERIODICIDAD_TASA_RECARGO  = PT.ID_PERIODICIDAD(+)
            --  Relaci�n con la tasa de referencia
            AND P.CVE_GPO_EMPRESA 	            = TR.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	            = TR.CVE_EMPRESA(+)
            AND P.ID_TASA_REFERENCIA_RECARGO    = TR.ID_TASA_REFERENCIA(+)
            --  Relaci�n con el detalle de la tasa de referencia
            AND TR.CVE_GPO_EMPRESA 	            = TRV.CVE_GPO_EMPRESA(+)
            AND TR.CVE_EMPRESA     	            = TRV.CVE_EMPRESA(+)
            AND TR.ID_PERIODICIDAD              = TRV.ID_PERIODICIDAD(+)
            --  Relaci�n con la tasa de referencia
            AND P.CVE_GPO_EMPRESA 	            = T.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	            = T.CVE_EMPRESA(+)
            AND P.ID_TASA_REFERENCIA_RECARGO    = T.ID_TASA_REFERENCIA(+)
            -- Se obtiene el m�ximo de id referencia detalle, esto es la tasa m�s actual
            AND PKG_CREDITO.dameidtasarefdet(P.CVE_GPO_EMPRESA,P.CVE_EMPRESA,
                P.ID_TASA_REFERENCIA_RECARGO) = T.ID_TASA_REFERENCIA_DETALLE(+);

        RETURN vlTasaIntMora;

        EXCEPTION
            WHEN OTHERS THEN
                RETURN 0;
    END DameTasaMoratoriaDiaria;

    FUNCTION DameInteresExtra(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                              pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                              pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                              pSaldoInicial    IN SIM_TABLA_AMORTIZACION.IMP_SALDO_INICIAL%TYPE,
                              pTasaIva         IN SIM_CAT_SUCURSAL.TASA_IVA%TYPE,
                              pTxRespuesta    OUT VARCHAR2)
    RETURN SIM_TABLA_AMORTIZACION.IMP_INTERES_EXTRA%TYPE
    IS
        vlImpInteresExtra   SIM_TABLA_AMORTIZACION.IMP_INTERES_EXTRA%TYPE;
    BEGIN

        -- Se obtiene el valor de la tasa
        SELECT 	ROUND(pSaldoInicial * (NVL(P.FECHA_REAL, P.FECHA_ENTREGA) - P.FECHA_ENTREGA) / DECODE(P.TIPO_TASA, 'No indexada',  PT.DIAS, PTI.DIAS) * 
                      (DECODE(P.TIPO_TASA, 'No indexada', P.VALOR_TASA, T.VALOR) * (1 + pTasaIva / 100) ) /100 /P.PLAZO, 10)
          INTO vlImpInteresExtra
          FROM SIM_PRESTAMO P, SIM_CAT_PERIODICIDAD PT, SIM_CAT_PERIODICIDAD PTI, SIM_CAT_PERIODICIDAD PP, 
               SIM_CAT_TASA_REFER_DETALLE T, SIM_CAT_TASA_REFERENCIA TR
         WHERE  P.CVE_GPO_EMPRESA 	        = pCveGpoEmpresa
            AND P.CVE_EMPRESA     	        = pCveEmpresa
            AND P.ID_PRESTAMO     	        = pIdPrestamo
            AND P.CVE_GPO_EMPRESA 	        = PT.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = PT.CVE_EMPRESA(+)
            AND P.ID_PERIODICIDAD_TASA      = PT.ID_PERIODICIDAD(+)
            AND P.CVE_GPO_EMPRESA 	        = PP.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = PP.CVE_EMPRESA(+)
            AND P.ID_PERIODICIDAD_PRODUCTO  = PP.ID_PERIODICIDAD(+)
            AND P.CVE_GPO_EMPRESA 	        = TR.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = TR.CVE_EMPRESA(+)
            AND P.ID_TASA_REFERENCIA        = TR.ID_TASA_REFERENCIA(+)
            AND P.CVE_GPO_EMPRESA 	        = T.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	        = T.CVE_EMPRESA(+)
            AND P.ID_TASA_REFERENCIA        = T.ID_TASA_REFERENCIA(+)
            AND P.FECHA_TASA_REFERENCIA     = T.FECHA_PUBLICACION(+)
            AND TR.CVE_GPO_EMPRESA 	        = PTI.CVE_GPO_EMPRESA(+)
            AND TR.CVE_EMPRESA     	        = PTI.CVE_EMPRESA(+)
            AND TR.ID_PERIODICIDAD          = PTI.ID_PERIODICIDAD(+);

        IF vlImpInteresExtra IS NULL THEN
            RETURN 0;

        END IF;

        RETURN vlImpInteresExtra;

        EXCEPTION
            WHEN OTHERS THEN
                pTxRespuesta := SQLERRM;
                RETURN 0;
    END DameInteresExtra;

    FUNCTION DameFechaValida (pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                              pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                              pFecha           IN SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE,
                              pCvePais         IN PFIN_DIA_FESTIVO.CVE_PAIS%TYPE,
                              pTxRespuesta    OUT VARCHAR2)
    RETURN SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE
    IS
        vlFechaOK       SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE;
        vlFechaTemp     SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE;
        vlBufParametro  PFIN_PARAMETRO%ROWTYPE;
        vlDia           VARCHAR2(2);
        lbFechaValida   BOOLEAN := FALSE;
        
        FUNCTION esDiaFestivo
        RETURN BOOLEAN 
        IS
           vlFFind     DATE;
        BEGIN
            -- Si existe la fecha como fecha v�lida regresa verdadero de otro modo falso
            SELECT F_DIA_FESTIVO
              INTO vlFFind
              FROM PFIN_DIA_FESTIVO
             WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
               AND CVE_EMPRESA     = pCveEmpresa
               AND CVE_PAIS        = pCvePais
               AND F_DIA_FESTIVO   = vlFechaTemp;
                
            RETURN TRUE;
            
            EXCEPTION   
                WHEN NO_DATA_FOUND THEN
                    RETURN FALSE;
        END esDiaFestivo;
        
    BEGIN
        -- Se obtienen los datos de la tabla de par�metros
        SELECT *
          INTO vlBufParametro
          FROM PFIN_PARAMETRO
         WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
           AND CVE_EMPRESA     = pCveEmpresa
           AND CVE_MEDIO       = 'SYSTEM';
            
        vlFechaTemp := pFecha;
        
        WHILE 1 = 1 LOOP
            vlDia := TO_CHAR(vlFechaTemp, 'D');
        
            IF vlDia IN ('6','7') OR esDiaFestivo THEN
                IF vlBufParametro.B_OPERA_DOMINGO           = 'V' AND vlDia = '7'  THEN
                    RETURN vlFechaTemp;
                ELSIF vlBufParametro.B_OPERA_SABADO         = 'V' AND vlDia = '6'  THEN
                    RETURN vlFechaTemp;
                ELSIF vlBufParametro.B_OPERA_DIA_FESTIVO    = 'V' AND esDiaFestivo THEN
                    RETURN vlFechaTemp;
                ELSE
                    vlFechaTemp := vlFechaTemp + 1;
                END IF;
            ELSE
                RETURN vlFechaTemp;
            END IF;
        END LOOP;
        
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                pTxRespuesta := '';
                pTxrespuesta := CHR(10)||'No se encontr� el par�metro del medio SYSTEM: '||CHR(10)||
                    ' Grupo Empresa: '||pCveGpoEmpresa||CHR(10)||
                    ' Empresa:       '||pCveEmpresa;
                RETURN NULL;
            WHEN OTHERS THEN
                pTxRespuesta := SQLERRM;
                RETURN NULL;
    END DameFechaValida;

    FUNCTION DameMontoAutorizado(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                 pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                 pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                                 pIdCliente       IN SIM_PRESTAMO.ID_CLIENTE%TYPE,
                                 pTxrespuesta     OUT VARCHAR2)
    RETURN SIM_CLIENTE_MONTO.MONTO_AUTORIZADO%TYPE
    IS
      vlMontoCliente   SIM_CLIENTE_MONTO.MONTO_AUTORIZADO%TYPE;
    BEGIN
        -- Se obtiene el monto autorizado
        SELECT NVL(MONTO_AUTORIZADO, MONTO_SOLICITADO)
          INTO vlMontoCliente
          FROM SIM_CLIENTE_MONTO
         WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
           AND CVE_EMPRESA     = pCveEmpresa
           AND ID_PRESTAMO     = pIdPrestamo
           AND ID_CLIENTE      = pIdCliente;
            
        RETURN vlMontoCliente;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                pTxrespuesta := CHR(10)||'No se encontr� el monto autorizado del cliente: '||CHR(10)||
                    ' Grupo Empresa: '||pCveGpoEmpresa||CHR(10)||
                    ' Empresa:       '||pCveEmpresa||CHR(10)||
                    ' Pr�stamo:      '||pIdPrestamo||CHR(10)||
                    ' Cliente:       '||pIdCliente;
                RETURN 0;
            WHEN OTHERS THEN
                pTxRespuesta := SQLERRM;
                RETURN 0;
    END DameMontoAutorizado;

    FUNCTION DameCargoInicial(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                              pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                              pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                              pTxrespuesta     OUT VARCHAR2)
    RETURN  SIM_PRESTAMO_CARGO_COMISION.CARGO_INICIAL%TYPE
    IS
        vlCargoInicial   SIM_PRESTAMO_CARGO_COMISION.CARGO_INICIAL%TYPE;
    BEGIN
        -- Se obtiene el cargo inicial
        SELECT SUM(NVL(C.CARGO_INICIAL, C.PORCENTAJE_MONTO / 100 * M.MONTO_AUTORIZADO) ) CARGO_INICIAL
          INTO vlCargoInicial
          FROM SIM_PRESTAMO_CARGO_COMISION C, SIM_CLIENTE_MONTO M
         WHERE C.CVE_GPO_EMPRESA     = pCveGpoEmpresa
           AND C.CVE_EMPRESA         = pCveEmpresa
           AND C.ID_PRESTAMO         = pIdPrestamo
           AND C.ID_FORMA_APLICACION = 1
           AND M.CVE_GPO_EMPRESA     = C.CVE_GPO_EMPRESA
           AND M.CVE_EMPRESA         = C.CVE_EMPRESA
           AND M.ID_PRESTAMO         = C.ID_PRESTAMO;

        RETURN vlCargoInicial;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                pTxrespuesta := CHR(10)||'No se encontr� el cargo inicial: '||CHR(10)||
                    ' Grupo Empresa: '||pCveGpoEmpresa||CHR(10)||
                    ' Empresa:       '||pCveEmpresa||CHR(10)||
                    ' Pr�stamo:      '||pIdPrestamo||CHR(10);
                RETURN 0;
            WHEN OTHERS THEN
                pTxRespuesta := SQLERRM;
                RETURN 0;

    END DameCargoInicial;

    PROCEDURE pDameInteresMoratorio(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                    pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                    pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                                    pNumPagoAmort    IN SIM_TABLA_AMORTIZACION.NUM_PAGO_AMORTIZACION%TYPE,
                                    pFValor          IN SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE,
                                    pInteresMora     OUT SIM_TABLA_AMORTIZACION.IMP_INTERES%TYPE,
                                    pIVAInteresMora  OUT SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE,
                                    pTxRespuesta     OUT VARCHAR2)
    IS
       vlBufTablaAmortizacion       SIM_TABLA_AMORTIZACION%ROWTYPE;
       vlTasaMoratoria              SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE;
       vlTasaIVA                    SIM_CAT_SUCURSAL.TASA_IVA%TYPE; 
       vlFechaCalculoAnt            SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE;
       vlCapitalPromedioMora        SIM_TABLA_AMORTIZACION.IMP_CAPITAL_AMORT%TYPE;
       vlCapitalActualizadoAnterior SIM_TABLA_AMORTIZACION.IMP_CAPITAL_AMORT%TYPE;
       vlImporteAcumulado           SIM_TABLA_AMORTIZACION.IMP_CAPITAL_AMORT%TYPE;
       vlNumDiasMora                NUMBER;
       vlNumDiasPeriodo             NUMBER;
       vlImpDeudaMinima             SIM_PARAMETRO_GLOBAL.IMP_DEUDA_MINIMA%TYPE;       
       
       CURSOR curPagosCapital IS
           SELECT F_VALOR, SUM(IMP_CAPITAL_PAGADO) AS IMP_CAPITAL_PAGADO
             FROM (SELECT CASE WHEN NVL(A.F_APLICACION, A.F_LIQUIDACION) <= vlBufTablaAmortizacion.FECHA_AMORTIZACION THEN vlBufTablaAmortizacion.FECHA_AMORTIZACION
                               ELSE NVL(A.F_APLICACION, A.F_LIQUIDACION)
                          END AS F_VALOR, B.IMP_CONCEPTO AS IMP_CAPITAL_PAGADO
                     FROM PFIN_MOVIMIENTO A, PFIN_MOVIMIENTO_DET B, PFIN_CAT_OPERACION C
                    WHERE A.CVE_GPO_EMPRESA       = pCveGpoEmpresa     AND
                          A.CVE_EMPRESA           = pCveEmpresa        AND
                          A.ID_PRESTAMO           = pIdPrestamo        AND
                          A.NUM_PAGO_AMORTIZACION = pNumPagoAmort      AND              
                          A.SIT_MOVIMIENTO       <> 'CA'               AND
                          A.CVE_GPO_EMPRESA       = B.CVE_GPO_EMPRESA  AND
                          A.CVE_EMPRESA           = B.CVE_EMPRESA      AND
                          A.ID_MOVIMIENTO         = B.ID_MOVIMIENTO    AND
                          B.CVE_CONCEPTO          = 'CAPITA'           AND
                          A.CVE_GPO_EMPRESA       = C.CVE_GPO_EMPRESA  AND
                          A.CVE_EMPRESA           = C.CVE_EMPRESA      AND
                          A.CVE_OPERACION         = C.CVE_OPERACION    AND
                          C.CVE_AFECTA_CREDITO    = 'D'
                    UNION ALL
                   -- Inserta un registro para la fecha de amortizacion
                   SELECT vlBufTablaAmortizacion.FECHA_AMORTIZACION AS F_VALOR, 0 AS IMP_CAPITAL_PAGADO
                     FROM DUAL
                    UNION ALL
                   -- Inserta un registro para la fecha en la que se esta realizando el pago
                   SELECT pFValor AS F_VALOR, 0 AS IMP_CAPITAL_PAGADO
                     FROM DUAL)
            GROUP BY F_VALOR
            ORDER BY F_VALOR;

    BEGIN
       -- Recupera el importe de la deuda minima
       SELECT IMP_DEUDA_MINIMA
         INTO vlImpDeudaMinima
         FROM SIM_PARAMETRO_GLOBAL 
        WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
              CVE_EMPRESA     = pCveEmpresa;
       
       -- Recupera el registro de la amortizacion correspondiente
       BEGIN
          SELECT *
            INTO vlBufTablaAmortizacion
            FROM SIM_TABLA_AMORTIZACION
           WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa   AND
                 CVE_EMPRESA           = pCveEmpresa      AND
                 ID_PRESTAMO           = pIdPrestamo      AND
                 NUM_PAGO_AMORTIZACION = pNumPagoAmort;
          
          EXCEPTION 
               WHEN NO_DATA_FOUND THEN
                    pTxRespuesta    := 'No existe el registro de la tabla de amortizacion';
                    pInteresMora    := 0;
                    pIVAInteresMora := 0;
       END;
       
       -- Inicializa datos para calcular el interes moratorio
       pInteresMora          := 0;  
       pIVAInteresMora       := 0;

       -- Calcula los dias de mora y en caso de que no haya mora regresa cero
       vlNumDiasMora         := pFValor - vlBufTablaAmortizacion.FECHA_AMORTIZACION;

       IF vlNumDiasMora <= 0 THEN
          pTxRespuesta := 'No aplican intereses moratorios por que no hay atraso en la fecha';
          RETURN;
       END IF;
       
       -- Valida que el capital que se adeuda sea mayor a la deuda minima, de lo contrato el interes es cero
       IF vlBufTablaAmortizacion.IMP_CAPITAL_AMORT - vlBufTablaAmortizacion.IMP_CAPITAL_AMORT_PAGADO < vlImpDeudaMinima THEN
          pTxRespuesta := 'No aplican intereses moratorios por que la deuda de capital es menor a la deuda minima';
          RETURN;
       END IF;
       
       -- Recupera la tasa de IVA
       BEGIN
         SELECT S.TASA_IVA
           INTO vlTasaIVA
           FROM SIM_PRESTAMO P, SIM_CAT_SUCURSAL S
          WHERE P.CVE_GPO_EMPRESA   = pCveGpoEmpresa     AND
                P.CVE_EMPRESA       = pCveEmpresa        AND
                P.ID_PRESTAMO       = pIdPrestamo        AND
                P.CVE_GPO_EMPRESA   = S.CVE_GPO_EMPRESA  AND
                P.CVE_EMPRESA       = S.CVE_EMPRESA      AND
                P.ID_SUCURSAL       = S.ID_SUCURSAL;

          EXCEPTION 
               WHEN NO_DATA_FOUND THEN
                    pTxRespuesta    := 'No existe el registro de la SUCURSAL';
                    pInteresMora    := 0;
                    pIVAInteresMora := 0;
       END;

       -- Recupera la tasa moratoria
       vlTasaMoratoria := PKG_CREDITO.dametasamoratoriadiaria(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo);
              
       -- Acumula el capital que se debe, en caso de que lo deba por varios dias tiene que multiplicar por el numero de dias
       FOR vlBufPagos IN curPagosCapital LOOP
           -- Inicializa el capital pagado a la fecha de amortizacion
           IF vlBufPagos.F_VALOR = vlBufTablaAmortizacion.FECHA_AMORTIZACION THEN
              vlCapitalActualizadoAnterior := vlBufTablaAmortizacion.IMP_CAPITAL_AMORT - vlBufPagos.IMP_CAPITAL_PAGADO;
              vlImporteAcumulado           := 0;
              vlFechaCalculoAnt            := vlBufTablaAmortizacion.FECHA_AMORTIZACION;
           ELSE
              vlNumDiasPeriodo   := vlBufPagos.F_VALOR - vlFechaCalculoAnt;
              vlImporteAcumulado := vlImporteAcumulado + (vlCapitalActualizadoAnterior * vlNumDiasPeriodo);
              
              -- Actualiza los acumulados
              vlCapitalActualizadoAnterior := vlCapitalActualizadoAnterior - vlBufPagos.IMP_CAPITAL_PAGADO;
              vlFechaCalculoAnt            := vlBufPagos.F_VALOR;
           END IF;
       END LOOP;

       vlCapitalPromedioMora    := vlImporteAcumulado / vlNumDiasMora;
       
       pInteresMora             := vlImporteAcumulado * vlTasaMoratoria * vlNumDiasMora;
       pIVAInteresMora          := pInteresMora * vlTasaIVA;
       
    END pDameInteresMoratorio;

    PROCEDURE pActualizaTablaAmortizacion(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                          pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                          pIdMovimiento    IN PFIN_MOVIMIENTO.ID_MOVIMIENTO%TYPE,
                                          pTxRespuesta     OUT VARCHAR2)
    IS
        vlInteresMora       SIM_TABLA_AMORTIZACION.IMP_INTERES%TYPE;
        vlIVAInteresMora    SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlCapitalPagado     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlInteresPagado     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlIVAInteresPag     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlInteresExtPag     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlIVAIntExtPag      SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpPagoTardio     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpIntMora        SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpIVAIntMora     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpDeuda          SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE; 
        vlIdPrestamo        SIM_TABLA_AMORTIZACION.ID_PRESTAMO%TYPE;
        vlNumAmortizacion   SIM_TABLA_AMORTIZACION.NUM_PAGO_AMORTIZACION%TYPE;
        vlFValor            SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE;
        vlBPagado           SIM_TABLA_AMORTIZACION.B_PAGADO%TYPE;
     	  vlImpVariaPago      SIM_PARAMETRO_GLOBAL.IMP_VAR_PAGO%TYPE;
         
        -- Cursor de conceptos pagados por el movimiento
        CURSOR curConceptoPagado IS 
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, A.NUM_PAGO_AMORTIZACION, B.CVE_CONCEPTO, 
                  CASE WHEN O.CVE_AFECTA_CREDITO = cDecrementa THEN B.IMP_CONCEPTO
                       WHEN O.CVE_AFECTA_CREDITO = cIncrementa THEN B.IMP_CONCEPTO * -1
                       ELSE 0
                  END AS IMP_CONCEPTO, C.ID_ACCESORIO
             FROM PFIN_MOVIMIENTO A, PFIN_MOVIMIENTO_DET B, PFIN_CAT_CONCEPTO C, PFIN_CAT_OPERACION O
            WHERE A.CVE_GPO_EMPRESA       = pCveGpoEmpresa          AND
                  A.CVE_EMPRESA           = pCveEmpresa             AND
                  A.ID_MOVIMIENTO         = pIdMovimiento           AND
                  A.CVE_GPO_EMPRESA       = B.CVE_GPO_EMPRESA       AND
                  A.CVE_EMPRESA           = B.CVE_EMPRESA           AND
                  A.ID_MOVIMIENTO         = B.ID_MOVIMIENTO         AND
                  B.CVE_GPO_EMPRESA       = C.CVE_GPO_EMPRESA       AND
                  B.CVE_EMPRESA           = C.CVE_EMPRESA           AND
                  B.CVE_CONCEPTO          = C.CVE_CONCEPTO          AND
                  A.CVE_GPO_EMPRESA       = O.CVE_GPO_EMPRESA       AND
                  A.CVE_EMPRESA           = O.CVE_EMPRESA           AND
                  A.CVE_OPERACION         = O.CVE_OPERACION         AND                  
                  C.ID_ACCESORIO NOT IN (1,99);
    BEGIN
        -- Recupera la informacion del credito desde el movimiento
        SELECT A.ID_PRESTAMO, A.NUM_PAGO_AMORTIZACION, A.F_APLICACION,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'CAPITA'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_CAPITAL_AMORT_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'INTERE'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_INTERES_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'IVAINT'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_IVA_INTERES_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'INTEXT'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_INTERES_EXTRA_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'IVAINTEX' THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_IVA_INTERES_EXTRA_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'PAGOTARD' THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_PAGO_TARDIO_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'INTMORA'  THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_INTERES_MORA_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'IVAINTMO' THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, 1, cIncrementa, -1, 0) ELSE 0 END) AS IMP_IVA_INTERES_MORA_PAGADO
          INTO vlIdPrestamo, vlNumAmortizacion, vlFValor, vlCapitalPagado, vlInteresPagado, vlIVAInteresPag, 
               vlInteresExtPag, vlIVAIntExtPag, vlImpPagoTardio, vlImpIntMora, vlImpIVAIntMora
          FROM PFIN_MOVIMIENTO A, PFIN_MOVIMIENTO_DET B, PFIN_CAT_OPERACION O
         WHERE A.CVE_GPO_EMPRESA = pCveGpoEmpresa     AND
               A.CVE_EMPRESA     = pCveEmpresa        AND
               A.ID_MOVIMIENTO   = pIdMovimiento      AND
               A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA  AND
               A.CVE_EMPRESA     = B.CVE_EMPRESA      AND
               A.ID_MOVIMIENTO   = B.ID_MOVIMIENTO    AND
               A.CVE_GPO_EMPRESA = O.CVE_GPO_EMPRESA  AND
               A.CVE_EMPRESA     = O.CVE_EMPRESA      AND
               A.CVE_OPERACION   = O.CVE_OPERACION
         GROUP BY A.ID_PRESTAMO, A.NUM_PAGO_AMORTIZACION, A.F_APLICACION;

        -- Actualiza la informacion de la tabla de amortizacion
        UPDATE SIM_TABLA_AMORTIZACION 
           SET IMP_CAPITAL_AMORT_PAGADO     = NVL(IMP_CAPITAL_AMORT_PAGADO,0)      + NVL(vlCapitalPagado,0),
               IMP_INTERES_PAGADO           = NVL(IMP_INTERES_PAGADO,0)            + NVL(vlInteresPagado,0),
               IMP_IVA_INTERES_PAGADO       = NVL(IMP_IVA_INTERES_PAGADO,0)        + NVL(vlIVAInteresPag,0),
               IMP_INTERES_EXTRA_PAGADO     = NVL(IMP_INTERES_EXTRA_PAGADO,0)      + NVL(vlInteresExtPag,0),
               IMP_IVA_INTERES_EXTRA_PAGADO = NVL(IMP_IVA_INTERES_EXTRA_PAGADO,0)  + NVL(vlIVAIntExtPag,0),
               IMP_PAGO_TARDIO_PAGADO       = NVL(IMP_PAGO_TARDIO_PAGADO,0)        + NVL(vlImpPagoTardio,0),
               IMP_INTERES_MORA_PAGADO      = NVL(IMP_INTERES_MORA_PAGADO,0)       + NVL(vlImpIntMora,0),
               IMP_IVA_INTERES_MORA_PAGADO  = NVL(IMP_IVA_INTERES_MORA_PAGADO,0)   + NVL(vlImpIVAIntMora,0),
               FECHA_AMORT_PAGO_ULTIMO      = vlFValor
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
           AND CVE_EMPRESA           = pCveEmpresa
           AND ID_PRESTAMO           = vlIdPrestamo
           AND NUM_PAGO_AMORTIZACION = vlNumAmortizacion;
    
        -- Actualiza la informacion de los accesorios pagados
        FOR vlBufConceptoPagado IN curConceptoPagado LOOP
            UPDATE SIM_TABLA_AMORT_ACCESORIO
               SET IMP_ACCESORIO_PAGADO  = NVL(IMP_ACCESORIO_PAGADO,0) + vlBufConceptoPagado.IMP_CONCEPTO
             WHERE CVE_GPO_EMPRESA       = vlBufConceptoPagado.CVE_GPO_EMPRESA       AND
                   CVE_EMPRESA           = vlBufConceptoPagado.CVE_EMPRESA           AND
                   ID_PRESTAMO           = vlBufConceptoPagado.ID_PRESTAMO           AND
                   NUM_PAGO_AMORTIZACION = vlBufConceptoPagado.NUM_PAGO_AMORTIZACION AND
                   ID_ACCESORIO          = vlBufConceptoPagado.ID_ACCESORIO;
        END LOOP;
        
        -- Recupera el saldo de la amortizacion
        SELECT SUM(IMP_NETO)
          INTO vlImpDeuda
          FROM V_SIM_TABLA_AMORT_CONCEPTO 
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
               CVE_EMPRESA           = pCveEmpresa    AND
               ID_PRESTAMO           = vlIdPrestamo   AND
               NUM_PAGO_AMORTIZACION = vlNumAmortizacion;

        -- Recupera el valor de la deuda minima
        SELECT IMP_VAR_PAGO
          INTO vlImpVariaPago
          FROM SIM_PARAMETRO_GLOBAL 
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
               CVE_EMPRESA           = pCveEmpresa;

       -- Verifica si se liquido el pago total del credito
        IF vlImpDeuda > -vlImpVariaPago THEN 
           vlBPagado := cVerdadero ;
        ELSE 
           vlBPagado := cFalso;
        END IF;
        
        -- Actualiza la informacion de pago puntual y pago completo en la tabla de amortizacion 
        UPDATE SIM_TABLA_AMORTIZACION 
           SET B_PAGO_PUNTUAL        = CASE WHEN FECHA_AMORTIZACION >= vlFValor AND vlBPagado = cVerdadero THEN cVerdadero
                                            ELSE cFalso
                                       END,
               B_PAGADO              = vlBPagado,
               IMP_PAGO_PAGADO       = IMP_CAPITAL_AMORT_PAGADO + IMP_INTERES_PAGADO + IMP_INTERES_EXTRA_PAGADO + 
                                       IMP_IVA_INTERES_PAGADO   + IMP_IVA_INTERES_EXTRA_PAGADO               
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
           AND CVE_EMPRESA           = pCveEmpresa
           AND ID_PRESTAMO           = vlIdPrestamo
           AND NUM_PAGO_AMORTIZACION = vlNumAmortizacion;
           
    END pActualizaTablaAmortizacion;
    
    PROCEDURE pActualizaTablaAmortXCargo(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                         pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                         pIdMovimiento    IN PFIN_MOVIMIENTO.ID_MOVIMIENTO%TYPE,
                                         pTxRespuesta     OUT VARCHAR2)
    IS
        vlInteresMora       SIM_TABLA_AMORTIZACION.IMP_INTERES%TYPE;
        vlIVAInteresMora    SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlCapitalPagado     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlInteresPagado     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlIVAInteresPag     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlInteresExtPag     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlIVAIntExtPag      SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpPagoTardio     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpIntMora        SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpIVAIntMora     SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE;
        vlImpDeuda          SIM_TABLA_AMORTIZACION.IMP_IVA_INTERES%TYPE; 
        vlIdPrestamo        SIM_TABLA_AMORTIZACION.ID_PRESTAMO%TYPE;
        vlNumAmortizacion   SIM_TABLA_AMORTIZACION.NUM_PAGO_AMORTIZACION%TYPE;
        vlFValor            SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE;
        vlBPagado           SIM_TABLA_AMORTIZACION.B_PAGADO%TYPE;
     	  vlImpVariaPago      SIM_PARAMETRO_GLOBAL.IMP_VAR_PAGO%TYPE;
         
        -- Cursor de conceptos pagados por el movimiento
        CURSOR curConceptoPagado IS 
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, A.NUM_PAGO_AMORTIZACION, B.CVE_CONCEPTO, 
                  CASE WHEN O.CVE_AFECTA_CREDITO = cDecrementa THEN B.IMP_CONCEPTO * -1
                       WHEN O.CVE_AFECTA_CREDITO = cIncrementa THEN B.IMP_CONCEPTO
                       ELSE 0
                  END AS IMP_CONCEPTO, C.ID_ACCESORIO
             FROM PFIN_MOVIMIENTO A, PFIN_MOVIMIENTO_DET B, PFIN_CAT_CONCEPTO C, PFIN_CAT_OPERACION O
            WHERE A.CVE_GPO_EMPRESA       = pCveGpoEmpresa          AND
                  A.CVE_EMPRESA           = pCveEmpresa             AND
                  A.ID_MOVIMIENTO         = pIdMovimiento           AND
                  A.CVE_GPO_EMPRESA       = B.CVE_GPO_EMPRESA       AND
                  A.CVE_EMPRESA           = B.CVE_EMPRESA           AND
                  A.ID_MOVIMIENTO         = B.ID_MOVIMIENTO         AND
                  B.CVE_GPO_EMPRESA       = C.CVE_GPO_EMPRESA       AND
                  B.CVE_EMPRESA           = C.CVE_EMPRESA           AND
                  B.CVE_CONCEPTO          = C.CVE_CONCEPTO          AND
                  A.CVE_GPO_EMPRESA       = O.CVE_GPO_EMPRESA       AND
                  A.CVE_EMPRESA           = O.CVE_EMPRESA           AND
                  A.CVE_OPERACION         = O.CVE_OPERACION         AND                  
                  C.ID_ACCESORIO NOT IN (1,99);
    BEGIN
        -- Recupera la informacion del credito desde el movimiento
        SELECT A.ID_PRESTAMO, A.NUM_PAGO_AMORTIZACION, A.F_APLICACION,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'CAPITA'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_CAPITAL_AMORT_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'INTERE'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_INTERES_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'IVAINT'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_IVA_INTERES_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'INTEXT'   THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_INTERES_EXTRA_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'IVAINTEX' THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_IVA_INTERES_EXTRA_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'PAGOTARD' THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_PAGO_TARDIO_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'INTMORA'  THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_INTERES_MORA_PAGADO,
               SUM(CASE WHEN B.CVE_CONCEPTO = 'IVAINTMO' THEN IMP_CONCEPTO * DECODE(O.CVE_AFECTA_CREDITO, cDecrementa, -1, cIncrementa, 1, 0) ELSE 0 END) AS IMP_IVA_INTERES_MORA_PAGADO
          INTO vlIdPrestamo, vlNumAmortizacion, vlFValor, vlCapitalPagado, vlInteresPagado, vlIVAInteresPag, 
               vlInteresExtPag, vlIVAIntExtPag, vlImpPagoTardio, vlImpIntMora, vlImpIVAIntMora
          FROM PFIN_MOVIMIENTO A, PFIN_MOVIMIENTO_DET B, PFIN_CAT_OPERACION O
         WHERE A.CVE_GPO_EMPRESA = pCveGpoEmpresa     AND
               A.CVE_EMPRESA     = pCveEmpresa        AND
               A.ID_MOVIMIENTO   = pIdMovimiento      AND
               A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA  AND
               A.CVE_EMPRESA     = B.CVE_EMPRESA      AND
               A.ID_MOVIMIENTO   = B.ID_MOVIMIENTO    AND
               A.CVE_GPO_EMPRESA = O.CVE_GPO_EMPRESA  AND
               A.CVE_EMPRESA     = O.CVE_EMPRESA      AND
               A.CVE_OPERACION   = O.CVE_OPERACION
         GROUP BY A.ID_PRESTAMO, A.NUM_PAGO_AMORTIZACION, A.F_APLICACION;

        -- Actualiza la informacion de la tabla de amortizacion
        UPDATE SIM_TABLA_AMORTIZACION 
           SET IMP_EXT_CAPITAL_AMORT     = NVL(IMP_EXT_CAPITAL_AMORT,0)      + NVL(vlCapitalPagado,0),
               IMP_EXT_INTERES           = NVL(IMP_EXT_INTERES,0)            + NVL(vlInteresPagado,0),
               IMP_EXT_IVA_INTERES       = NVL(IMP_EXT_IVA_INTERES,0)        + NVL(vlIVAInteresPag,0),
               IMP_EXT_INTERES_EXTRA     = NVL(IMP_EXT_INTERES_EXTRA,0)      + NVL(vlInteresExtPag,0),
               IMP_EXT_IVA_INTERES_EXTRA = NVL(IMP_EXT_IVA_INTERES_EXTRA,0)  + NVL(vlIVAIntExtPag,0),
               IMP_EXT_PAGO_TARDIO       = NVL(IMP_EXT_PAGO_TARDIO,0)        + NVL(vlImpPagoTardio,0),
               IMP_EXT_INTERES_MORA      = NVL(IMP_EXT_INTERES_MORA,0)       + NVL(vlImpIntMora,0),
               IMP_EXT_IVA_INTERES_MORA  = NVL(IMP_EXT_IVA_INTERES_MORA,0)   + NVL(vlImpIVAIntMora,0)
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
           AND CVE_EMPRESA           = pCveEmpresa
           AND ID_PRESTAMO           = vlIdPrestamo
           AND NUM_PAGO_AMORTIZACION = vlNumAmortizacion;
    
        -- Actualiza la informacion de los accesorios pagados
        FOR vlBufConceptoPagado IN curConceptoPagado LOOP
            UPDATE SIM_TABLA_AMORT_ACCESORIO
               SET IMP_EXT_ACCESORIO = NVL(IMP_EXT_ACCESORIO,0) + vlBufConceptoPagado.IMP_CONCEPTO
             WHERE CVE_GPO_EMPRESA       = vlBufConceptoPagado.CVE_GPO_EMPRESA       AND
                   CVE_EMPRESA           = vlBufConceptoPagado.CVE_EMPRESA           AND
                   ID_PRESTAMO           = vlBufConceptoPagado.ID_PRESTAMO           AND
                   NUM_PAGO_AMORTIZACION = vlBufConceptoPagado.NUM_PAGO_AMORTIZACION AND
                   ID_ACCESORIO          = vlBufConceptoPagado.ID_ACCESORIO;
        END LOOP;
        
        -- Recupera el saldo de la amortizacion
        SELECT SUM(IMP_NETO)
          INTO vlImpDeuda
          FROM V_SIM_TABLA_AMORT_CONCEPTO 
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
               CVE_EMPRESA           = pCveEmpresa    AND
               ID_PRESTAMO           = vlIdPrestamo   AND
               NUM_PAGO_AMORTIZACION = vlNumAmortizacion;

        -- Recupera el valor de la deuda minima
        SELECT IMP_VAR_PAGO
          INTO vlImpVariaPago
          FROM SIM_PARAMETRO_GLOBAL 
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
               CVE_EMPRESA           = pCveEmpresa;

       -- Verifica si se liquido el pago total del credito
        IF vlImpDeuda > -vlImpVariaPago THEN 
           vlBPagado := cVerdadero ;
        ELSE 
           vlBPagado := cFalso;
        END IF;
        
        -- Actualiza la informacion de pago puntual y pago completo en la tabla de amortizacion 
        UPDATE SIM_TABLA_AMORTIZACION 
           SET B_PAGO_PUNTUAL        = CASE WHEN FECHA_AMORTIZACION >= vlFValor AND vlBPagado = cVerdadero THEN cVerdadero
                                            ELSE cFalso
                                       END,
               B_PAGADO              = vlBPagado,
               IMP_PAGO_PAGADO       = IMP_CAPITAL_AMORT_PAGADO + IMP_INTERES_PAGADO + IMP_INTERES_EXTRA_PAGADO + 
                                       IMP_IVA_INTERES_PAGADO   + IMP_IVA_INTERES_EXTRA_PAGADO               
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
           AND CVE_EMPRESA           = pCveEmpresa
           AND ID_PRESTAMO           = vlIdPrestamo
           AND NUM_PAGO_AMORTIZACION = vlNumAmortizacion;
           
    END pActualizaTablaAmortXCargo;
    
    PROCEDURE pGeneraTablaAmortizacion(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                       pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                       pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                                       pTxRespuesta     OUT VARCHAR2)
    IS
    vlIdCliente         SIM_PRESTAMO.ID_CLIENTE%TYPE;
    vlIdGrupo           SIM_PRESTAMO.ID_GRUPO%TYPE;
    vlIdSucursal        SIM_PRODUCTO_SUCURSAL.ID_SUCURSAL%TYPE;
    vlCveMetodo         SIM_PRESTAMO.CVE_METODO%TYPE;
    vlPlazo             SIM_PRESTAMO.PLAZO%TYPE;
    vlTasaInteres       SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE;
    vlTasaIVA           SIM_CAT_SUCURSAL.TASA_IVA%TYPE;    
    vlFInicioEntrega    SIM_PRESTAMO.FECHA_ENTREGA%TYPE;
    vlMontoInicial      SIM_CLIENTE_MONTO.MONTO_AUTORIZADO%TYPE;    
    vlFReal             SIM_PRESTAMO.FECHA_REAL%TYPE;
    vlFEntrega          SIM_PRESTAMO.FECHA_ENTREGA%TYPE;
    vlIdPeriodicidad    SIM_PRESTAMO.ID_PERIODICIDAD_PRODUCTO%TYPE;
    vlDiasPeriodicidad  SIM_CAT_PERIODICIDAD.DIAS%TYPE;
    vlFechaAmort        SIM_TABLA_AMORTIZACION.FECHA_AMORTIZACION%TYPE;
    vlNumPagos          NUMBER;
    i                   NUMBER(10):= 0;
    V                   SIM_TABLA_AMORTIZACION%ROWTYPE;
    vgResultado         NUMBER;

    CURSOR curAccesorios IS
   	
   	    -- Cursor que obtiene los accesorios que tiene relacionados el pr�stamo
        SELECT C.ID_CARGO_COMISION, C.ID_FORMA_APLICACION, C.VALOR VALOR_CARGO, U.VALOR VALOR_UNIDAD, 
               PC.DIAS DIAS_CARGO, PP.DIAS DIAS_PRODUCTO, CASE WHEN NVL(CA.TASA_IVA,0) <> 0 THEN NVL(SUC.TASA_IVA ,0) ELSE 0 END AS TASA_IVA
          FROM SIM_PRESTAMO P, SIM_PRESTAMO_CARGO_COMISION C, SIM_CAT_ACCESORIO CA, SIM_CAT_PERIODICIDAD PC, 
               SIM_CAT_PERIODICIDAD PP, SIM_CAT_UNIDAD U, SIM_CAT_SUCURSAL SUC
          WHERE P.CVE_GPO_EMPRESA 	         = pCveGpoEmpresa
            AND P.CVE_EMPRESA     	         = pCveEmpresa
            AND P.ID_PRESTAMO     	         = pIdPrestamo
            AND P.CVE_GPO_EMPRESA 	         = C.CVE_GPO_EMPRESA
            AND P.CVE_EMPRESA     	         = C.CVE_EMPRESA
            AND P.ID_PRESTAMO     	         = C.ID_PRESTAMO
            AND C.CVE_GPO_EMPRESA 	         = CA.CVE_GPO_EMPRESA
            AND C.CVE_EMPRESA     	         = CA.CVE_EMPRESA
            AND C.ID_CARGO_COMISION          = CA.ID_ACCESORIO
            AND CA.CVE_TIPO_ACCESORIO        = 'CARGO_COMISION'
            AND C.CVE_GPO_EMPRESA 	         = U.CVE_GPO_EMPRESA(+)
            AND C.CVE_EMPRESA     	         = U.CVE_EMPRESA(+)
            AND C.ID_UNIDAD                  = U.ID_UNIDAD(+)
            AND C.CVE_GPO_EMPRESA 	         = PC.CVE_GPO_EMPRESA(+)
            AND C.CVE_EMPRESA     	         = PC.CVE_EMPRESA(+)
            AND C.ID_PERIODICIDAD            = PC.ID_PERIODICIDAD(+)
            AND P.CVE_GPO_EMPRESA 	         = PP.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	         = PP.CVE_EMPRESA(+)
            AND P.ID_PERIODICIDAD_PRODUCTO   = PP.ID_PERIODICIDAD(+)
            AND P.CVE_GPO_EMPRESA 	         = SUC.CVE_GPO_EMPRESA(+)
            AND P.CVE_EMPRESA     	         = SUC.CVE_EMPRESA(+)
            AND P.ID_SUCURSAL                = SUC.ID_SUCURSAL(+)
            AND C.ID_FORMA_APLICACION          NOT IN (1,2);
    BEGIN
        -- Inicializa datos del buffer con los parametros del procedimiento
        V.CVE_GPO_EMPRESA   := pCveGpoEmpresa;
        V.CVE_EMPRESA       := pCveEmpresa;
        V.ID_PRESTAMO       := pIdPrestamo;
        
        -- Se asigna la fecha del sistema a la variable global
        vgFechaSistema := PKG_PROCESOS.DameFechaSistema(pCveGpoEmpresa,pCveEmpresa);

        BEGIN
            -- Revisa que no exista ningun movimiento de pago de prestamo para este prestamo, en caso de existir
            -- No vuelve a generar la tabla de amortizacion
            BEGIN
              SELECT COUNT(1)
                INTO vlNumPagos
                FROM PFIN_MOVIMIENTO
               WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
                     CVE_EMPRESA     = pCveEmpresa    AND
                     ID_PRESTAMO     = pIdPrestamo    AND
                     CVE_OPERACION   = cPagoPrestamo  AND
                     SIT_MOVIMIENTO  <> cSitCancelada;
              
              EXCEPTION WHEN NO_DATA_FOUND THEN vlNumPagos := 0;
            END;
                   
            IF vlNumPagos > 0 THEN
               pTxRespuesta := 'No se actualiza la tabla de amortizacion por que ya existen pagos para este prestamo';
               RETURN;
            END IF;

            -- Se obtienen los datos gen�ricos del pr�stamo
            SELECT P.ID_CLIENTE, P.ID_GRUPO, P.FECHA_ENTREGA, P.CVE_METODO, S.ID_SUCURSAL, C.TASA_IVA,
            		   P.PLAZO, NVL(P.FECHA_REAL, P.FECHA_ENTREGA) FECHA_REAL, P.ID_PERIODICIDAD_PRODUCTO, P.FECHA_ENTREGA, PP.DIAS
              INTO vlIdCliente, vlIdGrupo, vlFInicioEntrega, vlCveMetodo, vlIdSucursal, vlTasaIVA, 
                   vlPlazo, vlFReal, vlIdPeriodicidad, vlFEntrega, vlDiasPeriodicidad
              FROM SIM_PRESTAMO P, SIM_PRODUCTO_SUCURSAL S, SIM_CAT_SUCURSAL C, SIM_CAT_PERIODICIDAD PP
             WHERE P.CVE_GPO_EMPRESA 	         = pCveGpoEmpresa
               AND P.CVE_EMPRESA     	         = pCveEmpresa
               AND P.ID_PRESTAMO     	         = pIdPrestamo
               AND P.CVE_GPO_EMPRESA	         = S.CVE_GPO_EMPRESA
               AND P.CVE_EMPRESA    	         = S.CVE_EMPRESA
        		   AND P.ID_PRODUCTO		           = S.ID_PRODUCTO
        		   AND P.ID_SUCURSAL               = S.ID_SUCURSAL        -- verificar la relaci�n de estas tablas
        		   AND S.CVE_GPO_EMPRESA	         = C.CVE_GPO_EMPRESA
               AND S.CVE_EMPRESA    	         = C.CVE_EMPRESA
               AND S.ID_SUCURSAL 		           = C.ID_SUCURSAL
               AND P.CVE_GPO_EMPRESA 	         = PP.CVE_GPO_EMPRESA(+)
               AND P.CVE_EMPRESA     	         = PP.CVE_EMPRESA(+)
               AND P.ID_PERIODICIDAD_PRODUCTO  = PP.ID_PERIODICIDAD(+);
        		
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    pTxRespuesta := 'No se encontr� el pr�stamo en su relaci�n con producto_sucursal con las siguientes carater�sticas: '||CHR(10)||
                        ' Grupo Empresa: '||pCveGpoEmpresa||CHR(10)||
                        ' Empresa:       '||pCveEmpresa||CHR(10)||
                        ' Pr�stamo:      '||pIdPrestamo;
                    RETURN;
                WHEN TOO_MANY_ROWS THEN
                    pTxRespuesta := 'Al solicitar los datos gen�ricos del pr�stamo se obtienen demasiados registros';
                    RETURN;
        END;

        -- Valida que la fecha real de entrega del prestamo no sea nulo
        IF vlFReal IS NULL THEN
           pTxRespuesta := 'La fecha real de la entrega del prestamo no puede ser nulo';
           RETURN;
        END IF;

        V.TASA_INTERES  := DameTasaAmort(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, vlTasaIVA, pTxRespuesta);

        IF pTxRespuesta IS NOT NULL THEN
            pTxRespuesta := 'Error al calcular la tasa de inter�s del pr�stamo, verifique : '||pTxRespuesta;
            RETURN;
        END IF;

        -- se borra la tabla de accesorios de amortizaci�n
        DELETE SIM_TABLA_AMORT_ACCESORIO
         WHERE CVE_GPO_EMPRESA 	= pCveGpoEmpresa
           AND CVE_EMPRESA     	= pCveEmpresa
           AND ID_PRESTAMO     	= pIdPrestamo;

        -- se borra la tabla de amortizaci�n
        DELETE SIM_TABLA_AMORTIZACION
         WHERE CVE_GPO_EMPRESA 	= pCveGpoEmpresa
           AND CVE_EMPRESA     	= pCveEmpresa
           AND ID_PRESTAMO     	= pIdPrestamo;
           
        -- Inicializa variables
        V.B_PAGO_PUNTUAL                := cFalso;
        V.IMP_INTERES_PAGADO            := 0;
        V.IMP_INTERES_EXTRA_PAGADO      := 0;
        V.IMP_CAPITAL_AMORT_PAGADO      := 0;
        V.IMP_PAGO_PAGADO               := 0;
        V.IMP_IVA_INTERES_PAGADO        := 0;
        V.IMP_IVA_INTERES_EXTRA_PAGADO  := 0;
        V.B_PAGADO                      := cFalso;
        V.FECHA_AMORT_PAGO_ULTIMO       := NULL; 
        V.IMP_CAPITAL_AMORT_PREPAGO     := 0;
        V.NUM_DIA_ATRASO                := 0;
           
        WHILE i < vlPlazo LOOP
            BEGIN
                -- Se incrementa el contador
                i := i + 1;
                V.NUM_PAGO_AMORTIZACION := i;

                IF i = 1 THEN
                    -- Se obtiene el monto inicial la primera vez
                    V.IMP_SALDO_INICIAL := ROUND( DameMontoAutorizado(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, vlIdCliente, pTxRespuesta) +
                                                  DameCargoInicial(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pTxRespuesta), 10);

                    IF pTxRespuesta IS NOT NULL THEN
                        pTxRespuesta := 'Error al calcular el saldo inicial del pr�stamo: '||pTxRespuesta;
                        ROLLBACK;
                        RETURN;
                    END IF;

                    -- si la periodicidad es Catorcenal o Semanal y la fecha de entrega es diferente a la 
                    -- real se calculan intereses extra
                    IF vlIdPeriodicidad IN (7,8) AND vlFEntrega <> vlFReal THEN

                        IF vlCveMetodo NOT IN ('05','06') THEN
                            --  Se calcula el importe de inter�s extra y el iva del mismo
                            V.IMP_INTERES_EXTRA := DameInteresExtra(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, V.IMP_SALDO_INICIAL,
                                                                    vlTasaIVA, pTxRespuesta) / (1 + vlTasaIVA/100);
                                                                    
                            V.IMP_IVA_INTERES_EXTRA := ROUND(V.IMP_INTERES_EXTRA * (vlTasaIVA / 100), 10);

                            -- Verifica que no haya habido error
                            IF pTxRespuesta IS NOT NULL THEN
                                pTxRespuesta := 'Error al calcular el inter�s extra: '||pTxRespuesta;
                                ROLLBACK;
                                RETURN;
                            END IF;

                        ELSE
                            -- Si no se trata de los m�todos anteriores
                            V.IMP_SALDO_INICIAL := ROUND(V.IMP_SALDO_INICIAL + 
                                                        (DameInteresExtra(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, V.IMP_SALDO_INICIAL,
                                                                          vlTasaIVA,pTxRespuesta) * vlPlazo), 10);

                            IF pTxRespuesta IS NOT NULL THEN
                                pTxRespuesta := 'Error al calcular el inter�s extra: '||pTxRespuesta;
                                ROLLBACK;
                                RETURN;
                            END IF;

                            V.IMP_INTERES_EXTRA     := 0;
                            V.IMP_IVA_INTERES_EXTRA := 0;
                        END IF;

                    ELSE
                        V.IMP_INTERES_EXTRA     := 0;
                        V.IMP_IVA_INTERES_EXTRA := 0;
                    END IF;

                    -- Se guarda el monto para c�lculos posteriores
                    vlMontoInicial                 := V.IMP_SALDO_INICIAL;
                    V.IMP_CAPITAL_AMORT            := ROUND(V.IMP_SALDO_INICIAL / vlPlazo, 10);
                    V.IMP_INTERES                  := ROUND(V.IMP_SALDO_INICIAL * V.TASA_INTERES / (1+vlTasaIVA / 100), 10);
                    V.IMP_IVA_INTERES              := ROUND(V.IMP_INTERES * (vlTasaIVA / 100), 10);
                    V.IMP_SALDO_FINAL              := ROUND(V.IMP_SALDO_INICIAL - V.IMP_CAPITAL_AMORT, 10);
                    V.FECHA_AMORTIZACION           := vlFReal;
                    vlFechaAmort                   := vlFReal;
                ELSE
                    V.IMP_SALDO_INICIAL     := V.IMP_SALDO_FINAL;
                    V.IMP_SALDO_FINAL       := ROUND(V.IMP_SALDO_INICIAL - V.IMP_CAPITAL_AMORT,10);
                    
                    IF vlCveMetodo <> '01' THEN
                        V.IMP_INTERES       := ROUND(V.IMP_SALDO_INICIAL * V.TASA_INTERES / (1 + vlTasaIVA / 100), 10);
                        V.IMP_IVA_INTERES   := ROUND(V.IMP_INTERES * (vlTasaIVA / 100), 10);
                    END IF;

                END IF;

                -- Se calcula la fecha de amortizaci�n
                vlFechaAmort                := vlFechaAmort + vlDiasPeriodicidad;
                V.FECHA_AMORTIZACION        := DameFechaValida(pCveGpoEmpresa, pCveEmpresa, vlFechaAmort, 'MX', pTxRespuesta);

                IF pTxRespuesta IS NOT NULL THEN
                    pTxRespuesta := 'Error al calcular la fecha de amortizaci�n: '||pTxRespuesta;
                    ROLLBACK;
                    RETURN;
                END IF;
                            
                -- C�lculo del monto a pagar
                IF vlCveMetodo IN ('05','06') THEN
                    V.IMP_PAGO              := ROUND((NVL(V.IMP_SALDO_INICIAL, 0) * NVL(V.TASA_INTERES, 0)) /
                                                     (1 - (1 / POWER(1 + NVL(V.TASA_INTERES, 0), (vlPlazo - i + 1) ) ) ), 10);
                    V.IMP_CAPITAL_AMORT     := ROUND(V.IMP_PAGO - (NVL(V.IMP_INTERES, 0) + NVL(V.IMP_IVA_INTERES, 0) ), 10);
                    V.IMP_SALDO_FINAL       := ROUND(V.IMP_SALDO_INICIAL - V.IMP_CAPITAL_AMORT, 10);
                ELSE
                    V.IMP_PAGO              := ROUND(NVL(V.IMP_INTERES, 0) + NVL(V.IMP_IVA_INTERES, 0) + NVL(V.IMP_INTERES_EXTRA, 0) + 
                                                     NVL(V.IMP_IVA_INTERES_EXTRA, 0) + NVL(V.IMP_CAPITAL_AMORT, 0), 10)  ;
                END IF;

                -- Inicializa variables
                V.B_PAGO_PUNTUAL                := cFalso;
                V.IMP_INTERES_PAGADO            := 0;
                V.IMP_INTERES_EXTRA_PAGADO      := 0;
                V.IMP_CAPITAL_AMORT_PAGADO      := 0;
                V.IMP_PAGO_PAGADO               := 0;
                V.IMP_IVA_INTERES_PAGADO        := 0;
                V.IMP_IVA_INTERES_EXTRA_PAGADO  := 0;
                V.B_PAGADO                      := cFalso;
                V.FECHA_AMORT_PAGO_ULTIMO       := NULL; 
                V.IMP_PAGO_TARDIO               := 0;
                V.IMP_PAGO_TARDIO_PAGADO        := 0;
                V.IMP_INTERES_MORA              := 0;
                V.IMP_INTERES_MORA_PAGADO       := 0;
                V.IMP_IVA_INTERES_MORA          := 0;
                V.IMP_IVA_INTERES_MORA_PAGADO   := 0;
                V.F_VALOR_CALCULO               := NULL;
                V.F_INI_AMORTIZACION            := V.FECHA_AMORTIZACION - vlDiasPeriodicidad;
                V.IMP_EXT_INTERES               := 0;
                V.IMP_EXT_INTERES_EXTRA         := 0;
                V.IMP_EXT_CAPITAL_AMORT         := 0;
                V.IMP_EXT_PAGO                  := 0;
                V.IMP_EXT_IVA_INTERES           := 0;
                V.IMP_EXT_IVA_INTERES_EXTRA     := 0;
                V.IMP_EXT_PAGO_TARDIO           := 0;
                V.IMP_EXT_INTERES_MORA          := 0;
                V.IMP_EXT_IVA_INTERES_MORA      := 0;
                
                -- Actualiza el importe de interes devengado por dia, no incluye el interes e IVA extra ya que solo 
                -- considera el de la periodicidad estandar
                V.IMP_INTERES_DEV_X_DIA         := (V.IMP_INTERES + V.IMP_IVA_INTERES) / vlDiasPeriodicidad;

                -- Se inserta el registro
                INSERT INTO SIM_TABLA_AMORTIZACION VALUES V;

            EXCEPTION
                WHEN OTHERS THEN
                    pTxrespuesta := 'Error al generar la tabla: '||SQLERRM;
                    ROLLBACK;
                    RETURN;
            END;
        END LOOP;

        -- Se itera para generar los accesorios
        FOR vlBufAccesorios IN curAccesorios LOOP
        
            BEGIN
                -- Se calcula el importe del accesorio
                INSERT INTO SIM_TABLA_AMORT_ACCESORIO(CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO, NUM_PAGO_AMORTIZACION, ID_ACCESORIO,
                                                      ID_FORMA_APLICACION, IMP_ACCESORIO, IMP_IVA_ACCESORIO, IMP_ACCESORIO_PAGADO, 
                                                      IMP_IVA_ACCESORIO_PAGADO, IMP_EXT_ACCESORIO, IMP_EXT_IVA_ACCESORIO)
                SELECT CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO, NUM_PAGO_AMORTIZACION, vlBufAccesorios.ID_CARGO_COMISION, 
                       vlBufAccesorios.ID_FORMA_APLICACION,
                       ROUND(
                            DECODE(vlBufAccesorios.ID_FORMA_APLICACION,3, vlMontoInicial,5,1,4,IMP_SALDO_INICIAL) *
                            vlBufAccesorios.VALOR_CARGO /
                            DECODE(vlBufAccesorios.ID_FORMA_APLICACION,3,vlBufAccesorios.VALOR_UNIDAD,5,1,4,
                            vlBufAccesorios.VALOR_UNIDAD) /
                            vlBufAccesorios.DIAS_CARGO * vlBufAccesorios.DIAS_PRODUCTO
                       ,10) AS IMP_ACCESORIO, 
                       ROUND(
                            DECODE(vlBufAccesorios.ID_FORMA_APLICACION,3, vlMontoInicial,5,1,4,IMP_SALDO_INICIAL) *
                            vlBufAccesorios.VALOR_CARGO /
                            DECODE(vlBufAccesorios.ID_FORMA_APLICACION,3,vlBufAccesorios.VALOR_UNIDAD,5,1,4,
                            vlBufAccesorios.VALOR_UNIDAD) /
                            vlBufAccesorios.DIAS_CARGO * vlBufAccesorios.DIAS_PRODUCTO
                       ,10) * (NVL(vlBufAccesorios.TASA_IVA,1) - 1) AS IMP_IVA_ACCESORIO, 0, 0, 0, 0
                  FROM SIM_TABLA_AMORTIZACION
                 WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
                   AND CVE_EMPRESA     = pCveEmpresa
                   AND ID_PRESTAMO     = pIdPrestamo;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        pTxrespuesta := 'Error al calcular los accesorios: '||SQLERRM;
                        ROLLBACK;
                        RETURN;
            END;

        END LOOP;
        
        -- Actualiza la informacion del credito
        vgResultado := fActualizaInformacionCredito(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, vgFechaSistema, pTxRespuesta);

        pTxrespuesta := 'La tabla de amortizaci�n del pr�stamo '||pIdPrestamo||' se gener� correctamente.';

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            pTxrespuesta := 'Error global al calcular la tabla de amortizaci�n del pr�stamo '||pIdPrestamo||' '||SQLERRM;
            RETURN;
    END pGeneraTablaAmortizacion;

    PROCEDURE pGeneraTablaAmortPrePago(pCveGpoEmpresa   IN SIM_PRESTAMO.CVE_GPO_EMPRESA%TYPE,
                                       pCveEmpresa      IN SIM_PRESTAMO.CVE_EMPRESA%TYPE,
                                       pIdPrestamo      IN SIM_PRESTAMO.ID_PRESTAMO%TYPE,
                                       pNumAmortizacion IN SIM_TABLA_AMORTIZACION.NUM_PAGO_AMORTIZACION%TYPE,
                                       pTxRespuesta     OUT VARCHAR2)
    IS
       vlSaldoFinal      SIM_TABLA_AMORTIZACION.IMP_PAGO%TYPE;
       vlSaldoInicial    SIM_TABLA_AMORTIZACION.IMP_PAGO%TYPE;
       vlImpInteres      SIM_TABLA_AMORTIZACION.IMP_PAGO%TYPE;
       vlImpIVAInteres   SIM_TABLA_AMORTIZACION.IMP_PAGO%TYPE;
       vlImpPago         SIM_TABLA_AMORTIZACION.IMP_PAGO%TYPE;
       vlImpCapitAmort   SIM_TABLA_AMORTIZACION.IMP_PAGO%TYPE;
       vlPlazo           SIM_PRESTAMO.PLAZO%TYPE;
       vlTasaInteres     SIM_TABLA_AMORTIZACION.TASA_INTERES%TYPE;
       vlTasaIVA         SIM_CAT_SUCURSAL.TASA_IVA%TYPE;    

       vlImpIntDevXDia   SIM_TABLA_AMORTIZACION.IMP_PAGO%TYPE;
    
       CURSOR curAmortizaciones IS
          SELECT *
            FROM SIM_TABLA_AMORTIZACION
           WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
                 CVE_EMPRESA           = pCveEmpresa    AND
                 ID_PRESTAMO           = pIdPrestamo    AND
                 NUM_PAGO_AMORTIZACION > pNumAmortizacion
           ORDER BY NUM_PAGO_AMORTIZACION;

    BEGIN
       
        -- Recupera el saldo inicial
        SELECT IMP_SALDO_FINAL
          INTO vlSaldoFinal
          FROM SIM_TABLA_AMORTIZACION
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
               CVE_EMPRESA           = pCveEmpresa    AND
               ID_PRESTAMO           = pIdPrestamo    AND
               NUM_PAGO_AMORTIZACION = pNumAmortizacion;
        
        -- Recupera el nuevo plazo, a partir de la amortizacion siguiente a la que se le aplico un prepago de capital
        SELECT MAX(NUM_PAGO_AMORTIZACION)
          INTO vlPlazo
          FROM SIM_TABLA_AMORTIZACION
         WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
               CVE_EMPRESA           = pCveEmpresa    AND
               ID_PRESTAMO           = pIdPrestamo;
        
        -- Recupera la tasa de IVA
        BEGIN
           SELECT S.TASA_IVA
             INTO vlTasaIVA
             FROM SIM_PRESTAMO P, SIM_CAT_SUCURSAL S
            WHERE P.CVE_GPO_EMPRESA   = pCveGpoEmpresa     AND
                  P.CVE_EMPRESA       = pCveEmpresa        AND
                  P.ID_PRESTAMO       = pIdPrestamo        AND
                  P.CVE_GPO_EMPRESA   = S.CVE_GPO_EMPRESA  AND
                  P.CVE_EMPRESA       = S.CVE_EMPRESA      AND
                  P.ID_SUCURSAL       = S.ID_SUCURSAL;

            EXCEPTION 
                 WHEN NO_DATA_FOUND THEN
                      pTxRespuesta    := 'No existe el registro de la SUCURSAL';
        END;

        -- Itera las amortizaciones posteriores a la amortizacion recibida como parametro
        FOR vlAmortizacion IN curAmortizaciones LOOP
            vlSaldoInicial    := vlSaldoFinal;
            vlImpInteres      := ROUND(vlSaldoInicial * vlAmortizacion.TASA_INTERES / (1+vlTasaIVA / 100), 10);
            vlImpIVAInteres   := ROUND(vlImpInteres * (vlTasaIVA / 100), 10);            
            vlImpPago         := ROUND((NVL(vlSaldoInicial, 0) * NVL(vlAmortizacion.TASA_INTERES, 0)) /
                                      (1 - (1 / POWER(1 + NVL(vlAmortizacion.TASA_INTERES, 0), (vlPlazo - vlAmortizacion.NUM_PAGO_AMORTIZACION + 1) ) ) ), 10);
            vlImpCapitAmort   := ROUND(vlImpPago - (NVL(vlImpInteres, 0) + NVL(vlImpIVAInteres, 0) ), 10);
            vlSaldoFinal      := ROUND(vlSaldoFinal - vlImpCapitAmort, 10);

            -- Actualiza el importe de interes devengado por dia, no incluye el interes e IVA extra ya que solo 
            vlImpIntDevXDia   := (vlImpInteres + vlImpIVAInteres) / (vlAmortizacion.FECHA_AMORTIZACION - vlAmortizacion.F_INI_AMORTIZACION);
            
            -- Actualiza la tabla de amortizacion
            UPDATE SIM_TABLA_AMORTIZACION
               SET IMP_SALDO_INICIAL     = vlSaldoInicial,
                   IMP_INTERES           = vlImpInteres,
                   IMP_IVA_INTERES       = vlImpIVAInteres,
                   IMP_PAGO              = vlImpPago,
                   IMP_CAPITAL_AMORT     = vlImpCapitAmort,
                   IMP_SALDO_FINAL       = vlSaldoFinal,
                   IMP_INTERES_DEV_X_DIA = vlImpIntDevXDia
             WHERE CVE_GPO_EMPRESA   = pCveGpoEmpresa     AND
                   CVE_EMPRESA       = pCveEmpresa        AND
                   ID_PRESTAMO       = pIdPrestamo        AND
                   NUM_PAGO_AMORTIZACION = vlAmortizacion.NUM_PAGO_AMORTIZACION;
        END LOOP;

        pTxrespuesta := 'La tabla para el metodo 06 del pr�stamo ' || pIdPrestamo || ' se gener� correctamente.';

        EXCEPTION
           WHEN OTHERS THEN
                ROLLBACK;
                pTxrespuesta := 'Error global al calcular la ta tabla para el metodo 06 del pr�stamo '||pIdPrestamo||' '||SQLERRM;
                RETURN;
                
    END pGeneraTablaAmortPrePago;
    
    -- Metodo Recargado utilizado por la pantalla de pago de prestamo
    PROCEDURE pAplicaPagoCredito(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                 pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                 pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                 pIdGrupo         IN PFIN_PRE_MOVIMIENTO.ID_GRUPO%TYPE,
                                 pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                 pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                 pTxrespuesta     OUT VARCHAR2)
    IS
       vlCveOperacion   PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE := cPagoPrestamo;
    BEGIN
       pAplicaPagoCredito(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pIdGrupo, pCveUsuario, pFValor, vlCveOperacion, pTxrespuesta);
    END pAplicaPagoCredito;

    PROCEDURE pAplicaPagoCredito(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                 pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                 pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                 pIdGrupo         IN PFIN_PRE_MOVIMIENTO.ID_GRUPO%TYPE,
                                 pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                 pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                 pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                 pTxrespuesta     OUT VARCHAR2)
    IS
        vlImpSaldo             PFIN_SALDO.SDO_EFECTIVO%TYPE;
        vlIdCuenta             SIM_PRESTAMO.ID_CUENTA%TYPE;
        vlImpNeto              PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
        vlMovtosPosteriores    NUMBER;
        vgResultado            NUMBER;
        
        CURSOR curAmortizacionesPendientes IS
          SELECT NUM_PAGO_AMORTIZACION, IMP_PAGO_TARDIO, IMP_INTERES_MORA, FECHA_AMORTIZACION
            FROM SIM_TABLA_AMORTIZACION
           WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
                 CVE_EMPRESA           = pCveEmpresa    AND
                 ID_PRESTAMO           = pIdPrestamo    AND
                 NVL(B_PAGADO, cFalso) = cFalso
           ORDER BY NUM_PAGO_AMORTIZACION;
    BEGIN
    
       BEGIN 
            -- Se asigna la fecha del sistema a la variable global
            vgFechaSistema := PKG_PROCESOS.DameFechaSistema(pCveGpoEmpresa,pCveEmpresa);
            
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    pTxrespuesta := 'No se encuentra la fecha del sistema ';
                    RETURN;
       END;        
        
       DBMS_OUTPUT.PUT_LINE('Paso fecha = ' || vgFechaSistema);
        
       -- Se obtiene el id de la cuenta asociada al credito
       vlIdCuenta := fObtieneCuenta(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pTxrespuesta);

       IF vlIdCuenta <= 0 THEN
          RETURN;
       END IF;
 
       DBMS_OUTPUT.PUT_LINE('Paso recuperacion de cuenta: ' || vlIdCuenta);
 
       -- Valida que la fecha valor no sea menor a un pago previo
       BEGIN
          SELECT COUNT(1)
            INTO vlMovtosPosteriores
            FROM PFIN_MOVIMIENTO
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
             AND CVE_EMPRESA     = pCveEmpresa
             AND ID_PRESTAMO     = pIdPrestamo
             AND SIT_MOVIMIENTO <> cSitCancelada
             AND NVL(ID_TRANSACCION_CANCELA,0) = 0
             AND NVL(F_APLICACION,F_LIQUIDACION) > pFValor;
             
          EXCEPTION 
              WHEN NO_DATA_FOUND THEN vlMovtosPosteriores := 0;
       END;

       IF vlMovtosPosteriores > 0 THEN
          pTxrespuesta := 'Existen movimientos con fecha valor posterior a este movimiento';
          RETURN;
       END IF;

       DBMS_OUTPUT.PUT_LINE('Paso recuperacion de movtos posteriores: ' || vlMovtosPosteriores);

       -- Valida que la fecha valor no sea mayor a la fecha del sistema
       IF pFValor > vgFechaSistema THEN
          pTxrespuesta := 'La fecha valor es posterior a la fecha del dia';
          RETURN;
       END IF;
        
       -- Actualiza la informacion del credito
       vgResultado := fActualizaInformacionCredito(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pFValor, pTxRespuesta);

       IF vgResultado <> 0 THEN
          pTxrespuesta := 'Error al actualizar la informacion del credito a la fecha valor. ' || pTxrespuesta;
          RETURN;
       END IF;
       
       -- Se obtiene el folio de grupo para las transacciones
       IF NVL(pIdGrupo,0) = 0 THEN
          SELECT SQ02_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vgFolioGrupo FROM DUAL;
       ELSE 
          vgFolioGrupo := pIdGrupo;
       END IF;
       
       -- Ejecuta el pago de cada amortizacion mientras exista una amortizacion pendiente de pagar y el cliente 
       -- tenga saldo en su cuenta
       FOR vlBufAmortizaciones IN curAmortizacionesPendientes LOOP
           --Valida que cuando sea un pago retroactivo no existan recargos, en caso contrario envia un error
           IF pFValor < vgFechaSistema AND pFValor <= vlBufAmortizaciones.FECHA_AMORTIZACION AND 
              (NVL(vlBufAmortizaciones.IMP_PAGO_TARDIO,0) > 0 OR NVL(vlBufAmortizaciones.IMP_INTERES_MORA,0) <> 0) THEN
              pTxrespuesta := 'No es posible aplicar pagos retroactivos a amortizaciones que tienen intereses moratorios o cargos por pago tardio';
              RETURN;
           END IF;
           
           BEGIN -- Se obtiene el importe de saldo del cliente
               SELECT SDO_EFECTIVO
                 INTO vlImpSaldo
                 FROM PFIN_SALDO
                WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
                  AND CVE_EMPRESA     = pCveEmpresa
                  AND F_FOTO          = vgFechaSistema
                  AND ID_CUENTA       = vlIdCuenta
                  AND CVE_DIVISA      = cDivisaPeso;
                
               EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                       vlImpSaldo := 0;
           END;

           DBMS_OUTPUT.PUT_LINE('Recupero saldo: ' || vlImpSaldo);
           
           IF vlImpSaldo > 0 THEN
             vgResultado := pAplicaPagoCreditoPorAmort(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, vlBufAmortizaciones.NUM_PAGO_AMORTIZACION, 
                                                       vlImpSaldo, vlIdCuenta, pCveUsuario, pFValor, pCveOperacion, vgFolioGrupo, pTxrespuesta);

             DBMS_OUTPUT.PUT_LINE('Aplico pago a la amortizacion: ' || vlBufAmortizaciones.NUM_PAGO_AMORTIZACION);             
           ELSE
              EXIT;
           END IF;

       END LOOP;
       
       DBMS_OUTPUT.PUT_LINE('Fin pAplicaPagoCredito');             

    END pAplicaPagoCredito;

    -- Funcion que actualiza los recargos de los integrantes de un prestamo grupal cuando el integrante va al corriente
    -- pero en el grupo al menos un integrante tiene recargos
    -- Esto lo realiza para el prestamo enviado como parametro, en caso de que el prestamo sea igual a cero,
    -- realiza el calculo para todos los creditos
    FUNCTION fActualizaRecargoCredito(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                      pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                      pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                      pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                      pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER
    IS
       vlBEsGrupo                    SIM_TABLA_AMORTIZACION.B_PAGADO%TYPE;
       vlIdGrupo                     SIM_PRESTAMO_GRUPO.ID_GRUPO%TYPE;
       vlInteresMora                 SIM_TABLA_AMORTIZACION.IMP_INTERES%TYPE;
       vlIVAInteresMora              SIM_TABLA_AMORTIZACION.IMP_INTERES%TYPE;
       vlImpDeudaMinima              SIM_PARAMETRO_GLOBAL.IMP_DEUDA_MINIMA%TYPE;
       
       -- Recupera las tablas de amortizacion de un prestamo       
       CURSOR curPorPrestamo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, T.NUM_PAGO_AMORTIZACION, 
                  CASE WHEN T.FECHA_AMORTIZACION < pFValor THEN ROUND(NVL(P.MONTO_FIJO_PERIODO,0),2) ELSE 0 END AS IMP_PAGO_TARDIO
             FROM SIM_TABLA_AMORTIZACION T, SIM_PRESTAMO P
            WHERE T.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND T.CVE_EMPRESA           = pCveEmpresa
              AND T.ID_PRESTAMO           = pIdPrestamo
--              AND T.FECHA_AMORTIZACION    < pFValor
              AND T.B_PAGADO              = cFalso
              AND T.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
              AND T.CVE_EMPRESA           = P.CVE_EMPRESA
              AND T.ID_PRESTAMO           = P.ID_PRESTAMO
              AND P.ID_TIPO_RECARGO    IN (4,5)
              AND NVL(P.MONTO_FIJO_PERIODO,0) > 0;

       -- Recupera las tablas de amortizacion de un prestamo grupal
       CURSOR curPorGpoPrestamo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, T.NUM_PAGO_AMORTIZACION, 
                  CASE WHEN T.FECHA_AMORTIZACION < pFValor THEN ROUND(NVL(P.MONTO_FIJO_PERIODO,0),2) ELSE 0 END AS IMP_PAGO_TARDIO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_TABLA_AMORTIZACION T, SIM_PRESTAMO P
            WHERE G.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND G.CVE_EMPRESA           = pCveEmpresa
              AND G.ID_PRESTAMO_GRUPO     = pIdPrestamo
              AND G.CVE_GPO_EMPRESA       = T.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA           = T.CVE_EMPRESA
              AND G.ID_PRESTAMO           = T.ID_PRESTAMO
--              AND T.FECHA_AMORTIZACION    < pFValor
              AND T.B_PAGADO              = cFalso
              AND T.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
              AND T.CVE_EMPRESA           = P.CVE_EMPRESA
              AND T.ID_PRESTAMO           = P.ID_PRESTAMO
              AND P.ID_TIPO_RECARGO    IN (4,5)
              AND NVL(P.MONTO_FIJO_PERIODO,0) > 0;

       -- Recupera las tablas de amortizacion de todos los prestamos
       CURSOR curTodo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, T.NUM_PAGO_AMORTIZACION, 
                  CASE WHEN T.FECHA_AMORTIZACION < pFValor THEN ROUND(NVL(P.MONTO_FIJO_PERIODO,0),2) ELSE 0 END AS IMP_PAGO_TARDIO
             FROM SIM_TABLA_AMORTIZACION T, SIM_PRESTAMO P
            WHERE T.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND T.CVE_EMPRESA           = pCveEmpresa
--              AND T.FECHA_AMORTIZACION    < pFValor
              AND T.B_PAGADO              = cFalso
              AND T.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
              AND T.CVE_EMPRESA           = P.CVE_EMPRESA
              AND T.ID_PRESTAMO           = P.ID_PRESTAMO
              AND P.ID_TIPO_RECARGO    IN (4,5)
              AND NVL(P.MONTO_FIJO_PERIODO,0) > 0;
              
       -- Recupera la informacion de dias de atraso de todos los creditos
       CURSOR curDiasAtrasoTodo IS
           SELECT CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO, MAX(NUM_DIA_ATRASO) AS NUM_DIA_ATRASO
             FROM SIM_TABLA_AMORTIZACION 
            WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND CVE_EMPRESA           = pCveEmpresa
              AND NUM_DIA_ATRASO        > 0
           GROUP BY CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO;
 
       -- Recupera la informacion de dias de atraso de un credito individual
       CURSOR curDiasAtrasoPres IS
           SELECT CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO, MAX(NUM_DIA_ATRASO) AS NUM_DIA_ATRASO
             FROM SIM_TABLA_AMORTIZACION 
            WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND CVE_EMPRESA           = pCveEmpresa
              AND ID_PRESTAMO           = pIdPrestamo
              AND NUM_DIA_ATRASO        > 0
            GROUP BY CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO;

       -- Recupera la informacion de dias de atraso de las tablas de amortizacion de un credito grupal
       CURSOR curDiasAtrasoGpo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, MAX(NUM_DIA_ATRASO) AS NUM_DIA_ATRASO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_TABLA_AMORTIZACION T
            WHERE G.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND G.CVE_EMPRESA           = pCveEmpresa
              AND G.ID_PRESTAMO_GRUPO     = pIdPrestamo
              AND G.CVE_GPO_EMPRESA       = T.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA           = T.CVE_EMPRESA
              AND G.ID_PRESTAMO           = T.ID_PRESTAMO
              AND T.NUM_DIA_ATRASO        > 0
         GROUP BY T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO;

       -- Recupera la informacion de dias de atraso de los prestamos de todos los creditos grupales
       CURSOR curDiasAtrasoPresGpoTodo IS
           SELECT G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, MAX(P.NUM_DIAS_ATRASO_ACTUAL) AS NUM_DIA_ATRASO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_PRESTAMO P
            WHERE G.CVE_GPO_EMPRESA        = pCveGpoEmpresa
              AND G.CVE_EMPRESA            = pCveEmpresa
              AND G.CVE_GPO_EMPRESA        = P.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA            = P.CVE_EMPRESA
              AND G.ID_PRESTAMO            = P.ID_PRESTAMO
              AND P.NUM_DIAS_ATRASO_ACTUAL > 0
            GROUP BY G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO;
            
       -- Recupera la informacion de dias de atraso de los prestamos de todos los creditos grupales
       CURSOR curDiasAtrasoPresGpoXPres IS
           SELECT G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, MAX(P.NUM_DIAS_ATRASO_ACTUAL) AS NUM_DIA_ATRASO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_PRESTAMO P
            WHERE G.CVE_GPO_EMPRESA        = pCveGpoEmpresa
              AND G.CVE_EMPRESA            = pCveEmpresa
              AND G.ID_PRESTAMO_GRUPO      = pIdPrestamo
              AND G.CVE_GPO_EMPRESA        = P.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA            = P.CVE_EMPRESA
              AND G.ID_PRESTAMO            = P.ID_PRESTAMO
              AND P.NUM_DIAS_ATRASO_ACTUAL > 0
            GROUP BY G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO;
            
       -- Recupera la informacion de la categoria de todos los prestamos individuales
       CURSOR curPrestamoIndCatTodo IS
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.Cve_Empresa                = Pcveempresa       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO = 'AC';
                  
       -- Recupera la informacion de la categoria de todos los prestamos grupales
       CURSOR curPrestamoGpoCatTodo IS                  
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO_GRUPO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.Cve_Empresa                = Pcveempresa       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO =     'AC';
            
       -- Recupera la informacion de la categoria de un prestamo individual
       CURSOR curPrestamoIndCatXPres IS
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.CVE_EMPRESA                = pCveEmpresa       AND
                  A.Id_Prestamo                = Pidprestamo       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO       = 'AC';
                  
       -- Recupera la informacion de la categoria de un prestamos grupal
       CURSOR curPrestamoGpoCatXPres IS                  
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO_GRUPO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.CVE_EMPRESA                = pCveEmpresa       AND
                  A.Id_Prestamo_Grupo          = Pidprestamo       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO       = 'AC';
            
    BEGIN
       -- Determina si el prestamo es un prestamo grupal
       vlBEsGrupo := fEsPrestamoGrupal(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo);

       -- Recupera el importe de la deuda minima
       SELECT IMP_DEUDA_MINIMA
         INTO vlImpDeudaMinima
         FROM SIM_PARAMETRO_GLOBAL 
        WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
              CVE_EMPRESA     = pCveEmpresa;       
       
       -- Actualiza la informacion de acuerdo a la seleccion
       CASE
          -- ******************************************************************************************************
          -- Procesa todos los creditos
          -- ******************************************************************************************************          
          WHEN pIdPrestamo = 0 THEN
               DBMS_OUTPUT.PUT_LINE('Procesando todos los creditos');
               
          -- ******************************************************************************************************
          -- Procesa un grupo
          -- ******************************************************************************************************          
          WHEN vlBEsGrupo = cVerdadero THEN
               DBMS_OUTPUT.PUT_LINE('Procesando un grupo');          

          -- ******************************************************************************************************
          -- Procesa un credito individual
          -- ******************************************************************************************************
          ELSE 
               DBMS_OUTPUT.PUT_LINE('Procesando un credito');

       --**************************************************************************************        
       END CASE;
       --**************************************************************************************
       
       RETURN 0;

    END fActualizaRecargoCredito;

    -- Funcion que actuliza la informacion variable de los creditos, esto lo realiza para todas las amortizaciones
    -- pendientes de pago
    --      Por atraso: Pago tardio, interes moratorio e IVA de interes moratorio asi como la F_VALOR_CALCULO
    --      Intereses devengados: Interes devengado del dia e interes devengado acumulado en el mes
    -- Esto lo realiza para el prestamo enviado como parametro, en caso de que el prestamo sea igual a cero,
    -- realiza el calculo para todos los creditos
    FUNCTION fActualizaInformacionCredito(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                          pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                          pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                          pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                          pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER
    IS
       vlBEsGrupo                    SIM_TABLA_AMORTIZACION.B_PAGADO%TYPE;
       vlIdGrupo                     SIM_PRESTAMO_GRUPO.ID_GRUPO%TYPE;
       vlInteresMora                 SIM_TABLA_AMORTIZACION.IMP_INTERES%TYPE;
       vlIVAInteresMora              SIM_TABLA_AMORTIZACION.IMP_INTERES%TYPE;
       vlImpDeudaMinima              SIM_PARAMETRO_GLOBAL.IMP_DEUDA_MINIMA%TYPE;
       
       -- Recupera las tablas de amortizacion de un prestamo       
       CURSOR curPorPrestamo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, T.NUM_PAGO_AMORTIZACION, 
                  CASE WHEN T.FECHA_AMORTIZACION < pFValor THEN ROUND(NVL(P.MONTO_FIJO_PERIODO,0),2) ELSE 0 END AS IMP_PAGO_TARDIO
             FROM SIM_TABLA_AMORTIZACION T, SIM_PRESTAMO P
            WHERE T.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND T.CVE_EMPRESA           = pCveEmpresa
              AND T.ID_PRESTAMO           = pIdPrestamo
--              AND T.FECHA_AMORTIZACION    < pFValor
              AND T.B_PAGADO              = cFalso
              AND T.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
              AND T.CVE_EMPRESA           = P.CVE_EMPRESA
              AND T.ID_PRESTAMO           = P.ID_PRESTAMO
              AND P.ID_TIPO_RECARGO    IN (4,5)
              AND NVL(P.MONTO_FIJO_PERIODO,0) > 0;

       -- Recupera las tablas de amortizacion de un prestamo grupal
       CURSOR curPorGpoPrestamo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, T.NUM_PAGO_AMORTIZACION, 
                  CASE WHEN T.FECHA_AMORTIZACION < pFValor THEN ROUND(NVL(P.MONTO_FIJO_PERIODO,0),2) ELSE 0 END AS IMP_PAGO_TARDIO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_TABLA_AMORTIZACION T, SIM_PRESTAMO P
            WHERE G.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND G.CVE_EMPRESA           = pCveEmpresa
              AND G.ID_PRESTAMO_GRUPO     = pIdPrestamo
              AND G.CVE_GPO_EMPRESA       = T.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA           = T.CVE_EMPRESA
              AND G.ID_PRESTAMO           = T.ID_PRESTAMO
--              AND T.FECHA_AMORTIZACION    < pFValor
              AND T.B_PAGADO              = cFalso
              AND T.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
              AND T.CVE_EMPRESA           = P.CVE_EMPRESA
              AND T.ID_PRESTAMO           = P.ID_PRESTAMO
              AND P.ID_TIPO_RECARGO    IN (4,5)
              AND NVL(P.MONTO_FIJO_PERIODO,0) > 0;

       -- Recupera las tablas de amortizacion de todos los prestamos
       CURSOR curTodo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, T.NUM_PAGO_AMORTIZACION, 
                  CASE WHEN T.FECHA_AMORTIZACION < pFValor THEN ROUND(NVL(P.MONTO_FIJO_PERIODO,0),2) ELSE 0 END AS IMP_PAGO_TARDIO
             FROM SIM_TABLA_AMORTIZACION T, SIM_PRESTAMO P
            WHERE T.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND T.CVE_EMPRESA           = pCveEmpresa
--              AND T.FECHA_AMORTIZACION    < pFValor
              AND T.B_PAGADO              = cFalso
              AND T.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
              AND T.CVE_EMPRESA           = P.CVE_EMPRESA
              AND T.ID_PRESTAMO           = P.ID_PRESTAMO
              AND P.ID_TIPO_RECARGO    IN (4,5)
              AND NVL(P.MONTO_FIJO_PERIODO,0) > 0;
              
       -- Recupera la informacion de dias de atraso de todos los creditos
       CURSOR curDiasAtrasoTodo IS
           SELECT CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO, MAX(NUM_DIA_ATRASO) AS NUM_DIA_ATRASO
             FROM SIM_TABLA_AMORTIZACION 
            WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND CVE_EMPRESA           = pCveEmpresa
              AND NUM_DIA_ATRASO        > 0
           GROUP BY CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO;
 
       -- Recupera la informacion de dias de atraso de un credito individual
       CURSOR curDiasAtrasoPres IS
           SELECT CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO, MAX(NUM_DIA_ATRASO) AS NUM_DIA_ATRASO
             FROM SIM_TABLA_AMORTIZACION 
            WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND CVE_EMPRESA           = pCveEmpresa
              AND ID_PRESTAMO           = pIdPrestamo
              AND NUM_DIA_ATRASO        > 0
            GROUP BY CVE_GPO_EMPRESA, CVE_EMPRESA, ID_PRESTAMO;

       -- Recupera la informacion de dias de atraso de las tablas de amortizacion de un credito grupal
       CURSOR curDiasAtrasoGpo IS
           SELECT T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO, MAX(NUM_DIA_ATRASO) AS NUM_DIA_ATRASO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_TABLA_AMORTIZACION T
            WHERE G.CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND G.CVE_EMPRESA           = pCveEmpresa
              AND G.ID_PRESTAMO_GRUPO     = pIdPrestamo
              AND G.CVE_GPO_EMPRESA       = T.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA           = T.CVE_EMPRESA
              AND G.ID_PRESTAMO           = T.ID_PRESTAMO
              AND T.NUM_DIA_ATRASO        > 0
         GROUP BY T.CVE_GPO_EMPRESA, T.CVE_EMPRESA, T.ID_PRESTAMO;

       -- Recupera la informacion de dias de atraso de los prestamos de todos los creditos grupales
       CURSOR curDiasAtrasoPresGpoTodo IS
           SELECT G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, MAX(P.NUM_DIAS_ATRASO_ACTUAL) AS NUM_DIA_ATRASO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_PRESTAMO P
            WHERE G.CVE_GPO_EMPRESA        = pCveGpoEmpresa
              AND G.CVE_EMPRESA            = pCveEmpresa
              AND G.CVE_GPO_EMPRESA        = P.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA            = P.CVE_EMPRESA
              AND G.ID_PRESTAMO            = P.ID_PRESTAMO
              AND P.NUM_DIAS_ATRASO_ACTUAL > 0
            GROUP BY G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO;
            
       -- Recupera la informacion de dias de atraso de los prestamos de todos los creditos grupales
       CURSOR curDiasAtrasoPresGpoXPres IS
           SELECT G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, MAX(P.NUM_DIAS_ATRASO_ACTUAL) AS NUM_DIA_ATRASO
             FROM SIM_PRESTAMO_GPO_DET G, SIM_PRESTAMO P
            WHERE G.CVE_GPO_EMPRESA        = pCveGpoEmpresa
              AND G.CVE_EMPRESA            = pCveEmpresa
              AND G.ID_PRESTAMO_GRUPO      = pIdPrestamo
              AND G.CVE_GPO_EMPRESA        = P.CVE_GPO_EMPRESA
              AND G.CVE_EMPRESA            = P.CVE_EMPRESA
              AND G.ID_PRESTAMO            = P.ID_PRESTAMO
              AND P.NUM_DIAS_ATRASO_ACTUAL > 0
            GROUP BY G.CVE_GPO_EMPRESA, G.CVE_EMPRESA, G.ID_PRESTAMO_GRUPO;
            
       -- Recupera la informacion de la categoria de todos los prestamos individuales
       CURSOR curPrestamoIndCatTodo IS
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.Cve_Empresa                = Pcveempresa       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO = 'AC';
                  
       -- Recupera la informacion de la categoria de todos los prestamos grupales
       CURSOR curPrestamoGpoCatTodo IS                  
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO_GRUPO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.Cve_Empresa                = Pcveempresa       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO =     'AC';
            
       -- Recupera la informacion de la categoria de un prestamo individual
       CURSOR curPrestamoIndCatXPres IS
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.CVE_EMPRESA                = pCveEmpresa       AND
                  A.Id_Prestamo                = Pidprestamo       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO       = 'AC';
                  
       -- Recupera la informacion de la categoria de un prestamos grupal
       CURSOR curPrestamoGpoCatXPres IS                  
           SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO AS ID_PRESTAMO, B.CVE_CATEGORIA_ATRASO
             FROM SIM_PRESTAMO_GRUPO A, SIM_CATEGORIA_ATRASO B
            WHERE A.CVE_GPO_EMPRESA            = pCveGpoEmpresa    AND
                  A.CVE_EMPRESA                = pCveEmpresa       AND
                  A.Id_Prestamo_Grupo          = Pidprestamo       And
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) >= 0                 AND
                  A.CVE_GPO_EMPRESA            = B.CVE_GPO_EMPRESA AND
                  A.CVE_EMPRESA                = B.CVE_EMPRESA     AND
                  NVL(A.NUM_DIAS_ATRASO_MAX,0) BETWEEN B.NUM_DIAS_ATRASO_MIN AND B.NUM_DIAS_ATRASO_MAX AND
                  B.SIT_CATEGORIA_ATRASO       = 'AC';
            
    BEGIN
       -- Determina si el prestamo es un prestamo grupal
       vlBEsGrupo := fEsPrestamoGrupal(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo);

       -- Recupera el importe de la deuda minima
       SELECT IMP_DEUDA_MINIMA
         INTO vlImpDeudaMinima
         FROM SIM_PARAMETRO_GLOBAL 
        WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
              CVE_EMPRESA     = pCveEmpresa;       
       
       -- Actualiza la informacion de acuerdo a la seleccion
       CASE
          -- ******************************************************************************************************
          -- Procesa todos los creditos
          -- ******************************************************************************************************          
          WHEN pIdPrestamo = 0 THEN
               --DBMS_OUTPUT.PUT_LINE('Procesando todos los creditos');
               FOR vlBufAmorizacion IN curTodo LOOP

                   --DBMS_OUTPUT.PUT_LINE('Procesando el credito : ' || vlBufAmorizacion.ID_PRESTAMO || ' Amortizacion : ' || vlBufAmorizacion.IMP_PAGO_TARDIO);

                   pDameInteresMoratorio(vlBufAmorizacion.CVE_GPO_EMPRESA, vlBufAmorizacion.CVE_EMPRESA, vlBufAmorizacion.ID_PRESTAMO,
                                         vlBufAmorizacion.NUM_PAGO_AMORTIZACION, pFValor, vlInteresMora, vlIVAInteresMora, pTxRespuesta);
                   

                   --DBMS_OUTPUT.PUT_LINE('Pago tardio : ' || vlBufAmorizacion.IMP_PAGO_TARDIO || ' Interes : ' || vlInteresMora);

                   UPDATE SIM_TABLA_AMORTIZACION
                      SET IMP_PAGO_TARDIO      = vlBufAmorizacion.IMP_PAGO_TARDIO,
                          IMP_INTERES_MORA     = vlInteresMora,
                          IMP_IVA_INTERES_MORA = vlIVAInteresMora,
                          F_VALOR_CALCULO      = pFValor,
                          NUM_DIA_ATRASO       = CASE 
                                                    WHEN B_PAGADO = cFalso AND (IMP_CAPITAL_AMORT - IMP_CAPITAL_AMORT_PAGADO) >= vlImpDeudaMinima AND pFValor > FECHA_AMORTIZACION THEN pFValor - FECHA_AMORTIZACION
                                                    WHEN (B_PAGADO = cVerdadero OR (IMP_CAPITAL_AMORT - IMP_CAPITAL_AMORT_PAGADO) < vlImpDeudaMinima) AND 
                                                         NVL(FECHA_AMORT_PAGO_ULTIMO, FECHA_AMORTIZACION) > FECHA_AMORTIZACION THEN FECHA_AMORT_PAGO_ULTIMO - FECHA_AMORTIZACION
                                                    ELSE 0
                                                 END
                    WHERE CVE_GPO_EMPRESA       = vlBufAmorizacion.CVE_GPO_EMPRESA
                      AND CVE_EMPRESA           = vlBufAmorizacion.CVE_EMPRESA
                      AND ID_PRESTAMO           = vlBufAmorizacion.ID_PRESTAMO
                      AND NUM_PAGO_AMORTIZACION = vlBufAmorizacion.NUM_PAGO_AMORTIZACION;
               END LOOP;

               --DBMS_OUTPUT.PUT_LINE('Actualiza la informacion del atraso (SIM_PRESTAMO) para los prestamos individuales');
               -- Actualiza la informacion del atraso (SIM_PRESTAMO) para los prestamos individuales
               FOR vlBufPrestamo IN curDiasAtrasoTodo LOOP
                   UPDATE SIM_PRESTAMO
                      SET NUM_DIAS_ATRASO_ACTUAL = vlBufPrestamo.NUM_DIA_ATRASO,
                          NUM_DIAS_ATRASO_MAX    = CASE WHEN vlBufPrestamo.NUM_DIA_ATRASO > NVL(NUM_DIAS_ATRASO_MAX,0) THEN vlBufPrestamo.NUM_DIA_ATRASO
                                                        ELSE NUM_DIAS_ATRASO_MAX
                                                   END
                    WHERE CVE_GPO_EMPRESA = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA     = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO     = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;

               --DBMS_OUTPUT.PUT_LINE('Actualiza la informacion del atraso (SIM_PRESTAMO_GPO) para los prestamos grupales');
               -- Actualiza la informacion del atraso (SIM_PRESTAMO_GPO) para los prestamos grupales
               FOR vlBufPrestamo IN curDiasAtrasoPresGpoTodo LOOP
                   UPDATE SIM_PRESTAMO_GRUPO
                      SET NUM_DIAS_ATRASO_ACTUAL = vlBufPrestamo.NUM_DIA_ATRASO,
                          NUM_DIAS_ATRASO_MAX    = CASE WHEN vlBufPrestamo.NUM_DIA_ATRASO > NVL(NUM_DIAS_ATRASO_MAX,0) THEN vlBufPrestamo.NUM_DIA_ATRASO
                                                        ELSE NUM_DIAS_ATRASO_MAX
                                                   END
                    WHERE CVE_GPO_EMPRESA   = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO_GRUPO = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;
               
               --DBMS_OUTPUT.PUT_LINE('Actualiza la categoria de todos los prestamos individuales');               
               -- Actualiza la categoria de todos los prestamos individuales

               FOR vlBufPrestamo IN curPrestamoIndCatTodo LOOP
                   UPDATE SIM_PRESTAMO
                      SET CVE_CATEGORIA_ATRASO = vlBufPrestamo.CVE_CATEGORIA_ATRASO
                    WHERE CVE_GPO_EMPRESA   = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO       = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;

               --DBMS_OUTPUT.PUT_LINE('Actualiza la categoria de todos los prestamos grupales');
               -- Actualiza la categoria de todos los prestamos grupales

               FOR vlBufPrestamo IN curPrestamoGpoCatTodo LOOP
                   UPDATE SIM_PRESTAMO_GRUPO
                      SET CVE_CATEGORIA_ATRASO = vlBufPrestamo.CVE_CATEGORIA_ATRASO
                    WHERE CVE_GPO_EMPRESA   = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO_GRUPO = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;
               
               -- Actualiza la categoria F para todos los prestamos individuales
               UPDATE SIM_PRESTAMO
                  SET CVE_CATEGORIA_ATRASO = 'F'
                WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa AND
                      CVE_EMPRESA                   = pCveEmpresa    AND
                      NVL(CVE_CATEGORIA_ATRASO,'X') = 'E'            AND
                      NVL(NUM_DIAS_ATRASO_ACTUAL,0) > 39;
                      
               -- Actualiza la categoria F para todos los prestamos grupales
               UPDATE SIM_PRESTAMO_GRUPO
                  SET CVE_CATEGORIA_ATRASO = 'F'
                WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa AND
                      CVE_EMPRESA                   = pCveEmpresa    AND
                      NVL(CVE_CATEGORIA_ATRASO,'X') = 'E'            AND
                      NVL(NUM_DIAS_ATRASO_ACTUAL,0) > 39;
                      
               -- Actualiza el numero de integrantes de todos los grupos       
               UPDATE SIM_GRUPO A
                  SET NUM_INTEGRANTES = (SELECT COUNT(1) 
                                           FROM SIM_GRUPO_INTEGRANTE
                                          WHERE CVE_GPO_EMPRESA = A.CVE_GPO_EMPRESA AND
                                                CVE_EMPRESA     = A.CVE_EMPRESA     AND
                                                ID_GRUPO        = A.ID_GRUPO        AND
                                                FECHA_BAJA_LOGICA IS NULL)
               WHERE A.CVE_GPO_EMPRESA = pCveGpoEmpresa AND
                     A.CVE_EMPRESA     = pCveEmpresa;
                     
               -- Actualiza los dias de antiguedad de todos los prestamos
               vgResultado := actualizaDiasAntiguedad (pCveGpoEmpresa, pCveEmpresa, pFValor, vlImpDeudaMinima);
               -- Actualiza las fechas de todos los prestamos
               --DBMS_OUTPUT.PUT_LINE('Actualiza las fechas de todos los prestamos individuales');               
               vgResultado := actualizaFechasPrestamo (pCveGpoEmpresa, pCveEmpresa, 0, vlBEsGrupo);
               --DBMS_OUTPUT.PUT_LINE('Actualiza las fechas de todos los prestamos grupales');                              
               vgResultado := actualizaFechasPrestamoGpo (pCveGpoEmpresa, pCveEmpresa, 0);

          -- ******************************************************************************************************
          -- Procesa un grupo
          -- ******************************************************************************************************          
          WHEN vlBEsGrupo = cVerdadero THEN
               --DBMS_OUTPUT.PUT_LINE('Procesando un grupo');          
               FOR vlBufAmorizacion IN curPorGpoPrestamo LOOP
                   pDameInteresMoratorio(vlBufAmorizacion.CVE_GPO_EMPRESA, vlBufAmorizacion.CVE_EMPRESA, vlBufAmorizacion.ID_PRESTAMO,
                                         vlBufAmorizacion.NUM_PAGO_AMORTIZACION, pFValor, vlInteresMora, vlIVAInteresMora, pTxRespuesta);
                                         
                   UPDATE SIM_TABLA_AMORTIZACION
                      SET IMP_PAGO_TARDIO      = vlBufAmorizacion.IMP_PAGO_TARDIO,
                          IMP_INTERES_MORA     = vlInteresMora,
                          IMP_IVA_INTERES_MORA = vlIVAInteresMora,
                          F_VALOR_CALCULO      = pFValor,
                          NUM_DIA_ATRASO       = CASE 
                                                    WHEN B_PAGADO = cFalso AND (IMP_CAPITAL_AMORT - IMP_CAPITAL_AMORT_PAGADO) >= vlImpDeudaMinima AND pFValor > FECHA_AMORTIZACION THEN pFValor - FECHA_AMORTIZACION
                                                    WHEN (B_PAGADO = cVerdadero OR (IMP_CAPITAL_AMORT - IMP_CAPITAL_AMORT_PAGADO) < vlImpDeudaMinima) AND 
                                                         NVL(FECHA_AMORT_PAGO_ULTIMO, FECHA_AMORTIZACION) > FECHA_AMORTIZACION THEN FECHA_AMORT_PAGO_ULTIMO - FECHA_AMORTIZACION
                                                    ELSE 0
                                                 END
                    WHERE CVE_GPO_EMPRESA       = vlBufAmorizacion.CVE_GPO_EMPRESA
                      AND CVE_EMPRESA           = vlBufAmorizacion.CVE_EMPRESA
                      AND ID_PRESTAMO           = vlBufAmorizacion.ID_PRESTAMO
                      AND NUM_PAGO_AMORTIZACION = vlBufAmorizacion.NUM_PAGO_AMORTIZACION;               
               END LOOP;
               
              -- Actualiza la informacion del atraso (SIM_PRESTAMO) para los prestamos grupales
               FOR vlBufPrestamo IN curDiasAtrasoGpo LOOP
                   UPDATE SIM_PRESTAMO
                      SET NUM_DIAS_ATRASO_ACTUAL = vlBufPrestamo.NUM_DIA_ATRASO,
                          NUM_DIAS_ATRASO_MAX    = CASE WHEN vlBufPrestamo.NUM_DIA_ATRASO > NVL(NUM_DIAS_ATRASO_MAX,0) THEN vlBufPrestamo.NUM_DIA_ATRASO
                                                        ELSE NUM_DIAS_ATRASO_MAX
                                                   END
                    WHERE CVE_GPO_EMPRESA = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA     = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO     = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;

               -- Actualiza la informacion del atraso (SIM_PRESTAMO_GPO) para los prestamos grupales
               FOR vlBufPrestamo IN curDiasAtrasoPresGpoXPres LOOP
                   UPDATE SIM_PRESTAMO_GRUPO
                      SET NUM_DIAS_ATRASO_ACTUAL = vlBufPrestamo.NUM_DIA_ATRASO,
                          NUM_DIAS_ATRASO_MAX    = CASE WHEN vlBufPrestamo.NUM_DIA_ATRASO > NVL(NUM_DIAS_ATRASO_MAX,0) THEN vlBufPrestamo.NUM_DIA_ATRASO
                                                        ELSE NUM_DIAS_ATRASO_MAX
                                                   END
                    WHERE CVE_GPO_EMPRESA = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO_GRUPO = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;

               -- Actualiza la categoria de un prestamo grupal
               FOR vlBufPrestamo IN curPrestamoGpoCatXPres LOOP
                   UPDATE SIM_PRESTAMO_GRUPO
                      SET CVE_CATEGORIA_ATRASO = vlBufPrestamo.CVE_CATEGORIA_ATRASO
                    WHERE CVE_GPO_EMPRESA   = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO_GRUPO = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;

               -- Actualiza la categoria F para el prestamo grupal
               UPDATE SIM_PRESTAMO_GRUPO
                  SET CVE_CATEGORIA_ATRASO = 'F'
                WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa AND
                      CVE_EMPRESA                   = pCveEmpresa    AND
                      ID_PRESTAMO_GRUPO             = pIdPrestamo    AND
                      NVL(CVE_CATEGORIA_ATRASO,'X') = 'E'            AND
                      NVL(NUM_DIAS_ATRASO_ACTUAL,0) > 39;

               -- Actualiza los integrantes del grupo                       
               UPDATE SIM_GRUPO A
                  SET NUM_INTEGRANTES = (SELECT COUNT(1) 
                                           FROM SIM_GRUPO_INTEGRANTE
                                          WHERE CVE_GPO_EMPRESA = A.CVE_GPO_EMPRESA AND
                                                CVE_EMPRESA     = A.CVE_EMPRESA     AND
                                                ID_GRUPO        = A.ID_GRUPO        AND
                                                FECHA_BAJA_LOGICA IS NULL)
               WHERE A.CVE_GPO_EMPRESA = pCveGpoEmpresa AND
                     A.CVE_EMPRESA     = pCveEmpresa    AND
                     A.ID_GRUPO        = vlIdGrupo;
                     
               -- Actualiza las fecha del prestamo grupal
               --DBMS_OUTPUT.PUT_LINE('Actualiza las fechas de todos los prestamos individuales del grupo');
               vgResultado := actualizaFechasPrestamo (pCveGpoEmpresa, pCveEmpresa, 0, vlBEsGrupo);               
               --DBMS_OUTPUT.PUT_LINE('Actualiza las fechas del prestamo grupal');
               vgResultado := actualizaFechasPrestamoGpo (pCveGpoEmpresa, pCveEmpresa, vlIdGrupo);
               
          -- ******************************************************************************************************
          -- Procesa un credito individual
          -- ******************************************************************************************************
          ELSE 
               --DBMS_OUTPUT.PUT_LINE('Procesando un credito');
               FOR vlBufAmorizacion IN curPorPrestamo LOOP
                   pDameInteresMoratorio(vlBufAmorizacion.CVE_GPO_EMPRESA, vlBufAmorizacion.CVE_EMPRESA, vlBufAmorizacion.ID_PRESTAMO,
                                         vlBufAmorizacion.NUM_PAGO_AMORTIZACION, pFValor, vlInteresMora, vlIVAInteresMora, pTxRespuesta);
                                         
                   UPDATE SIM_TABLA_AMORTIZACION
                      SET IMP_PAGO_TARDIO      = vlBufAmorizacion.IMP_PAGO_TARDIO,
                          IMP_INTERES_MORA     = vlInteresMora,
                          IMP_IVA_INTERES_MORA = vlIVAInteresMora,
                          F_VALOR_CALCULO      = pFValor,
                          NUM_DIA_ATRASO       = CASE 
                                                    WHEN B_PAGADO = cFalso AND (IMP_CAPITAL_AMORT - IMP_CAPITAL_AMORT_PAGADO) >= vlImpDeudaMinima AND pFValor > FECHA_AMORTIZACION THEN pFValor - FECHA_AMORTIZACION
                                                    WHEN (B_PAGADO = cVerdadero OR (IMP_CAPITAL_AMORT - IMP_CAPITAL_AMORT_PAGADO) < vlImpDeudaMinima) AND 
                                                         NVL(FECHA_AMORT_PAGO_ULTIMO, FECHA_AMORTIZACION) > FECHA_AMORTIZACION THEN FECHA_AMORT_PAGO_ULTIMO - FECHA_AMORTIZACION
                                                    ELSE 0
                                                 END
                    WHERE CVE_GPO_EMPRESA       = vlBufAmorizacion.CVE_GPO_EMPRESA
                      AND CVE_EMPRESA           = vlBufAmorizacion.CVE_EMPRESA
                      AND ID_PRESTAMO           = vlBufAmorizacion.ID_PRESTAMO
                      AND NUM_PAGO_AMORTIZACION = vlBufAmorizacion.NUM_PAGO_AMORTIZACION;               
               END LOOP;
               
              -- Actualiza la informacion del atraso (SIM_PRESTAMO) para los prestamos individuales               
               FOR vlBufPrestamo IN curDiasAtrasoPres LOOP
                   UPDATE SIM_PRESTAMO
                      SET NUM_DIAS_ATRASO_ACTUAL = vlBufPrestamo.NUM_DIA_ATRASO,
                          NUM_DIAS_ATRASO_MAX    = CASE WHEN vlBufPrestamo.NUM_DIA_ATRASO > NVL(NUM_DIAS_ATRASO_MAX,0) THEN vlBufPrestamo.NUM_DIA_ATRASO
                                                        ELSE NUM_DIAS_ATRASO_MAX
                                                   END
                    WHERE CVE_GPO_EMPRESA = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA     = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO     = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;
               
               -- Actualiza la categoria de un prestamo individual
               FOR vlBufPrestamo IN curPrestamoIndCatXPres LOOP
                   UPDATE SIM_PRESTAMO
                      SET CVE_CATEGORIA_ATRASO = vlBufPrestamo.CVE_CATEGORIA_ATRASO
                    WHERE CVE_GPO_EMPRESA   = vlBufPrestamo.CVE_GPO_EMPRESA AND
                          CVE_EMPRESA       = vlBufPrestamo.CVE_EMPRESA     AND
                          ID_PRESTAMO       = vlBufPrestamo.ID_PRESTAMO;
               END LOOP;
               
               -- Actualiza la categoria F para el prestamo individual
               UPDATE SIM_PRESTAMO
                  SET CVE_CATEGORIA_ATRASO = 'F'
                WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa AND
                      CVE_EMPRESA                   = pCveEmpresa    AND
                      ID_PRESTAMO                   = pIdPrestamo    AND
                      NVL(CVE_CATEGORIA_ATRASO,'X') = 'E'            AND
                      NVL(NUM_DIAS_ATRASO_ACTUAL,0) > 39;
                      
               -- Actualiza las fecha del prestamo grupal
               --DBMS_OUTPUT.PUT_LINE('Actualiza las fechas de un prestamo individual');               
               vgResultado := actualizaFechasPrestamo (pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, vlBEsGrupo);
                      
       --**************************************************************************************        
       END CASE;
       --**************************************************************************************
       
       RETURN 0;

    END fActualizaInformacionCredito;

    FUNCTION pAplicaPagoCreditoPorAmort(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                        pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                        pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                        pNumAmortizacion IN SIM_TABLA_AMORTIZACION.NUM_PAGO_AMORTIZACION%TYPE,
                                        pImportePago     IN PFIN_MOVIMIENTO.IMP_NETO%TYPE,
                                        pIdCuenta        IN PFIN_MOVIMIENTO.ID_CUENTA%TYPE,
                                        pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                        pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                        pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                        pIdGrupo         IN PFIN_PRE_MOVIMIENTO.ID_GRUPO%TYPE,
                                        pTxrespuesta     OUT VARCHAR2)
    RETURN NUMBER
    IS
        vlImpSaldo               PFIN_SALDO.SDO_EFECTIVO%TYPE;
        vlIdCuentaRef            SIM_PRESTAMO.ID_CUENTA_REFERENCIA%TYPE;
        vlImpNeto                PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
        vlImpConcepto            PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE := 0;
        vlImpCapitalPendLiquidar PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE := 0;
        vlImpCapitalPrepago      PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE := 0;
        vlIdPreMovto             PFIN_PRE_MOVIMIENTO.ID_PRE_MOVIMIENTO%TYPE;
        vlIdMovimiento           PFIN_PRE_MOVIMIENTO.ID_MOVIMIENTO%TYPE;
        vlValidaPagoPuntual      SIM_TABLA_AMORTIZACION.CVE_GPO_EMPRESA%TYPE;
        vlCveMetodo              SIM_PRESTAMO.CVE_METODO%TYPE;

    -- Obtiene los conceptos del credito actualizados, los recupera de la tabla de amortizacion y de la de accesorios,
    -- toma la informacion original y le resta lo realmente pagado       
    CURSOR curDebe IS 
         SELECT DECODE(A.CVE_CONCEPTO, 'CAPITA', D.ORDEN_CAPITAL, D.ORDEN_ACCESORIO)
                * 100 + DECODE(A.CVE_CONCEPTO, 'CAPITA',0,B.ORDEN) AS ID_ORDEN, 
                A.CVE_CONCEPTO, INITCAP(C.DESC_LARGA) DESCRIPCION, ABS(ROUND(SUM(A.IMP_NETO),2)) AS IMP_NETO
           FROM V_SIM_TABLA_AMORT_CONCEPTO A, PFIN_CAT_CONCEPTO C, SIM_PRESTAMO P, SIM_CAT_FORMA_DISTRIBUCION D, SIM_PRESTAMO_ACCESORIO B
          WHERE A.CVE_GPO_EMPRESA       = pCveGpoEmpresa
            AND A.CVE_EMPRESA           = pCveEmpresa
            AND A.ID_PRESTAMO           = pIdPrestamo
            AND A.NUM_PAGO_AMORTIZACION = pNumAmortizacion
            AND A.IMP_NETO              <> 0
            AND A.CVE_GPO_EMPRESA       = C.CVE_GPO_EMPRESA
            AND A.CVE_EMPRESA           = C.CVE_EMPRESA
            AND A.CVE_CONCEPTO          = C.CVE_CONCEPTO
            AND A.CVE_GPO_EMPRESA       = P.CVE_GPO_EMPRESA
            AND A.CVE_EMPRESA           = P.CVE_EMPRESA
            AND A.ID_PRESTAMO           = P.ID_PRESTAMO
            AND P.CVE_GPO_EMPRESA       = D.CVE_GPO_EMPRESA
            AND P.CVE_EMPRESA           = D.CVE_EMPRESA
            AND P.ID_FORMA_DISTRIBUCION = D.ID_FORMA_DISTRIBUCION
            AND A.CVE_GPO_EMPRESA       = B.CVE_GPO_EMPRESA(+)
            AND A.CVE_EMPRESA           = B.CVE_EMPRESA(+)
            AND A.ID_PRESTAMO           = B.ID_PRESTAMO(+)
            AND A.ID_ACCESORIO          = B.ID_ACCESORIO(+)
        GROUP BY DECODE(A.CVE_CONCEPTO, 'CAPITA', D.ORDEN_CAPITAL, D.ORDEN_ACCESORIO)
                 * 100 + DECODE(A.CVE_CONCEPTO, 'CAPITA',0,B.ORDEN), A.CVE_CONCEPTO, INITCAP(C.DESC_LARGA)
        HAVING ROUND(SUM(IMP_NETO),2) < 0
        ORDER BY DECODE(A.CVE_CONCEPTO, 'CAPITA', D.ORDEN_CAPITAL, D.ORDEN_ACCESORIO)
                 * 100 + DECODE(A.CVE_CONCEPTO, 'CAPITA', 0, B.ORDEN);
    --******************************************************************************************
    -- Inicia la logica del bloque principal
    --******************************************************************************************
    BEGIN       
        -- Inicializa variables
        vlImpSaldo      := pImportePago;
        vlImpNeto       := 0;
        
        -- Recupera el metodo del prestamo
        SELECT NVL(CVE_METODO, '00')
          INTO vlCveMetodo
          FROM SIM_PRESTAMO
         WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
               CVE_EMPRESA     = pCveEmpresa    AND
               ID_PRESTAMO     = pIdPrestamo;
        
        -- Se obtiene el id del premovimiento
        SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

        -- Se genera el premovimiento
        PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, pIdCuenta, pIdPrestamo,
                                     cDivisaPeso, pCveOperacion, vlImpNeto, 'PRESTAMO', 'PRESTAMO', 'Pago de prestamo',
                                     pIdGrupo, pCveUsuario, pFValor, pNumAmortizacion, pTxrespuesta);            

        IF pTxrespuesta IS NOT NULL THEN 
           RETURN 1; 
        END IF;
            
        FOR vlBufDebe IN curDebe LOOP
            IF vlImpSaldo > 0 THEN
               -- Realiza la validaci�n para identificar si liquida el total del pago
               -- Si el saldo es mayor al importe del concepto, cubre todo el concepto, de lo contrario solo lo que le alcanza
               IF vlBufDebe.IMP_NETO > vlImpSaldo THEN 
                  -- Si ya no tiene saldo para el pago del concepto no paga completo
                  vlImpConcepto  := vlImpSaldo;
               ELSE
                  vlImpConcepto   := vlBufDebe.IMP_NETO;
               END IF;
            
               PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vlBufDebe.CVE_CONCEPTO, vlImpConcepto, vlBufDebe.DESCRIPCION, pTxrespuesta);

               -- Se realiza actualiza el importe neto y el saldo del cliente
               vlImpNeto   := vlImpNeto  + vlImpConcepto;
               vlImpSaldo  := vlImpSaldo - vlImpConcepto;
                    
               --DBMS_OUTPUT.PUT_LINE(vlBufDebe.CVE_CONCEPTO || ': ' || vlImpConcepto || '  SDO: '|| vlImpSaldo || '  NETO: ' || vlImpNeto);
                    
               IF pTxrespuesta IS NOT NULL 
                  THEN RETURN 2; 
               END IF;
            END IF;
        END LOOP;
           
        -- Cuando es el metodo seis y aun sobra saldo, es necesario pagar capital adelantado y recalcular la tabla de 
        -- amortizacion para los pagos subsecuentes
        -- Solo se puede adelantar hasta el capital pendiente de pago
        IF vlImpSaldo > 0 AND vlCveMetodo = '06' THEN
           
           -- Calcula el capital pendiente de liquidar, si el cliente tiene mas saldo que esto, liquida el credito
           SELECT SUM(IMP_CAPITAL_AMORT)
             INTO vlImpCapitalPendLiquidar
             FROM SIM_TABLA_AMORTIZACION
            WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
                  CVE_EMPRESA           = pCveEmpresa    AND
                  ID_PRESTAMO           = pIdPrestamo    AND
                  NUM_PAGO_AMORTIZACION > pNumAmortizacion;
           
           IF vlImpSaldo > vlImpCapitalPendLiquidar THEN
              vlImpCapitalPrepago := vlImpCapitalPendLiquidar;
           ELSE 
              vlImpCapitalPrepago := vlImpSaldo;
           END IF;
           
           -- Actualiza el importe neto y el saldo sobrante 
           vlImpNeto  := vlImpNeto  + vlImpCapitalPrepago;
           vlImpSaldo := vlImpSaldo - vlImpCapitalPrepago;

           -- Actualiza el concepto de capital en el premovimiento           
           UPDATE PFIN_PRE_MOVIMIENTO_DET
              SET IMP_CONCEPTO = IMP_CONCEPTO + vlImpCapitalPrepago
            WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
                  CVE_EMPRESA           = pCveEmpresa    AND
                  ID_PRE_MOVIMIENTO     = vlIdPreMovto   AND
                  CVE_CONCEPTO          = 'CAPITA';
           
           -- Actualiza el saldo final en el pago (amortizacion), asi como el capital prepagado, el capital lo actualiza
           -- el metodo que actualizar la tabla de amortizacion
           UPDATE SIM_TABLA_AMORTIZACION 
              SET IMP_CAPITAL_AMORT_PREPAGO = vlImpCapitalPrepago,
                  IMP_SALDO_FINAL           = IMP_SALDO_FINAL - vlImpCapitalPrepago
            WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa
              AND CVE_EMPRESA           = pCveEmpresa
              AND ID_PRESTAMO           = pIdPrestamo
              AND NUM_PAGO_AMORTIZACION = pNumAmortizacion;
              
        END IF;
        
        -- Se actualiza el monto del premovimiento
        UPDATE PFIN_PRE_MOVIMIENTO
           SET IMP_NETO            = vlImpNeto
         WHERE CVE_GPO_EMPRESA     = pCveGpoEmpresa
           AND CVE_EMPRESA         = pCveEmpresa
           AND ID_PRE_MOVIMIENTO   = vlIdPreMovto;
           
        -- Se procesa el premovimiento
        vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pcvegpoempresa, pcveempresa, vlIdPreMovto, 'PV', NULL, cFalso, ptxrespuesta);
                
        IF pTxrespuesta IS NOT NULL THEN 
           ROLLBACK; 
           RETURN 3; 
        ELSE
           -- Se actualiza el identificador del movimiento
           UPDATE PFIN_PRE_MOVIMIENTO 
              SET ID_MOVIMIENTO       = vlIdMovimiento
            WHERE CVE_GPO_EMPRESA     = pCveGpoEmpresa
              AND CVE_EMPRESA         = pCveEmpresa
              AND ID_PRE_MOVIMIENTO   = vlIdPreMovto;
        END IF;            

        -- Actualiza la informacion de la tabla de amortizacion y de los accesorios con el movimiento generado
        pActualizaTablaAmortizacion(pCveGpoEmpresa, pCveEmpresa, vlIdMovimiento, pTxRespuesta);
        
        -- Si es el metodo 06 y existio prepago, envia a actualizar la tabla de amortizacion del siguiente pago en adelante
        IF vlImpCapitalPrepago > 0 AND vlCveMetodo = '06' THEN
           pGeneraTablaAmortPrePago(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pNumAmortizacion, pTxRespuesta);
        END IF;
        
        RETURN 0;

        EXCEPTION
            WHEN OTHERS THEN
                pTxrespuesta := SQLERRM;
                RETURN 4;
    END pAplicaPagoCreditoPorAmort;   
    
    -- Funcion que determina la proporcion del pago de acuerdo a un importe
    FUNCTION fCalculaProporcion(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                pFValor          IN PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE,
                                pImpPago         IN PFIN_MOVIMIENTO.IMP_NETO%TYPE,
                                pTxRespuesta     OUT VARCHAR2)
    RETURN SYS_REFCURSOR
    IS
       vlBEsGrupo                    SIM_TABLA_AMORTIZACION.B_PAGADO%TYPE;    
       vgResultado                   NUMBER;
       vlSaldo                       PFIN_MOVIMIENTO.IMP_NETO%TYPE;
       vlSaldoProrrateo              PFIN_MOVIMIENTO.IMP_NETO%TYPE;
       vlImpAmortizacion             PFIN_MOVIMIENTO.IMP_NETO%TYPE;
       vlNumAmortProrrateo           PFIN_MOVIMIENTO.NUM_PAGO_AMORTIZACION%TYPE;
       vlCurSalida                   SYS_REFCURSOR;
       vlImpVariaProporcion          SIM_PARAMETRO_GLOBAL.IMP_VAR_PROPORCION%TYPE;
       vlImpProrrateado              PFIN_MOVIMIENTO.IMP_NETO%TYPE;
       vlImpAjuste                   PFIN_MOVIMIENTO.IMP_NETO%TYPE;
 
       -- Cursor que devuelve las amortizaciones del prestamo para todos los integrantes de un grupo y ordenadas por
       -- el numero de amortizacion, esto seria por orden cronologico
       CURSOR curAmortizaciones IS
         SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO, B.NUM_PAGO_AMORTIZACION, SUM(IMP_NETO * -1) AS IMP_DEUDA
           FROM SIM_PRESTAMO_GPO_DET A, V_SIM_TABLA_AMORT_CONCEPTO B
          WHERE A.CVE_GPO_EMPRESA   = pCveGpoEmpresa 
            AND A.CVE_EMPRESA       = pCveEmpresa
            AND A.ID_PRESTAMO_GRUPO = pIdPrestamo
            AND A.CVE_GPO_EMPRESA   = B.CVE_GPO_EMPRESA
            AND A.CVE_EMPRESA       = B.CVE_EMPRESA
            AND A.ID_PRESTAMO       = B.ID_PRESTAMO
          GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO_GRUPO, B.NUM_PAGO_AMORTIZACION
          ORDER BY B.NUM_PAGO_AMORTIZACION;
       
       -- Cursor que devuelve el monto del pago que se asignara a cada participante
       -- Se suma las amortizaciones pagadas totalmente mas la proporcion de la amortizacion final
       CURSOR curProporcion IS
         SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.ID_CLIENTE, C.NOM_COMPLETO, SUM(IMP_DEUDA) AS IMP_DEUDA
           FROM (SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO, ROUND(SUM(IMP_NETO *-1),2) AS IMP_DEUDA
                   FROM SIM_PRESTAMO_GPO_DET A, V_SIM_TABLA_AMORT_CONCEPTO B
                  WHERE A.CVE_GPO_EMPRESA   = pCveGpoEmpresa 
                    AND A.CVE_EMPRESA       = pCveEmpresa
                    AND A.ID_PRESTAMO_GRUPO = pIdPrestamo
                    AND A.CVE_GPO_EMPRESA   = B.CVE_GPO_EMPRESA
                    AND A.CVE_EMPRESA       = B.CVE_EMPRESA
                    AND A.ID_PRESTAMO       = B.ID_PRESTAMO
                    AND B.NUM_PAGO_AMORTIZACION < vlNumAmortProrrateo
                  GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO
                  UNION ALL
                 SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO, 
                        ROUND(SUM(IMP_NETO *-1) / vlImpAmortizacion * vlSaldoProrrateo,2) AS IMP_DEUDA
                   FROM SIM_PRESTAMO_GPO_DET A, V_SIM_TABLA_AMORT_CONCEPTO B
                  WHERE A.CVE_GPO_EMPRESA       = pCveGpoEmpresa 
                    AND A.CVE_EMPRESA           = pCveEmpresa
                    AND A.ID_PRESTAMO_GRUPO     = pIdPrestamo
                    AND A.CVE_GPO_EMPRESA       = B.CVE_GPO_EMPRESA
                    AND A.CVE_EMPRESA           = B.CVE_EMPRESA
                    AND A.ID_PRESTAMO           = B.ID_PRESTAMO
                    AND B.NUM_PAGO_AMORTIZACION = vlNumAmortProrrateo
                  GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO) A, SIM_PRESTAMO B, RS_GRAL_PERSONA C
          WHERE A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA AND
                A.CVE_EMPRESA     = B.CVE_EMPRESA     AND
                A.ID_PRESTAMO     = B.ID_PRESTAMO     AND
                B.CVE_GPO_EMPRESA = C.CVE_GPO_EMPRESA AND
                B.CVE_EMPRESA     = C.CVE_EMPRESA     AND
                B.ID_CLIENTE      = C.ID_PERSONA
          GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.ID_CLIENTE, C.NOM_COMPLETO;

    BEGIN
       -- Valida que el credito sea grupal
       BEGIN
          SELECT cVerdadero
            INTO vlBEsGrupo
            FROM SIM_PRESTAMO_GRUPO
           WHERE CVE_GPO_EMPRESA   = pCveGpoEmpresa
             AND CVE_EMPRESA       = pCveEmpresa
             AND ID_PRESTAMO_GRUPO = pIdPrestamo;
             
          EXCEPTION WHEN NO_DATA_FOUND THEN vlBEsGrupo := cFalso;
             
      END;      
      
      IF vlBEsGrupo = cFalso THEN
         pTxRespuesta := 'El credito no es un credito grupal';
         RETURN NULL;
      END IF;
      
      -- Actualiza la informacion del credito a la fecha valor solicitada
      vgResultado := fActualizaInformacionCredito(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pFValor, pTxRespuesta);

      IF vgResultado < 0 THEN
         pTxRespuesta := 'El credito no se pudo actualizar';
         RETURN NULL;
      END IF;
      
      -- Determina lo siguiente:
      --          Amortizaciones que pueden cubrirse completamente con el pago
      --          Sobrante
      --          Amortizacion en la que se prorrateara el pago
      
      -- Inicializa saldo
      vlSaldo           := pImpPago;
      vlSaldoProrrateo  := 0;
      vlImpAmortizacion := 0;
      
      -- Inicializa la amortizacion que se prorratea a un numero muy grande
      vlNumAmortProrrateo := 99999;
      
      -- Determina que amortizaciones se alcanzan a cubrir con el pago
      FOR vlAmortizaciones IN curAmortizaciones LOOP
          vlSaldo := vlSaldo - vlAmortizaciones.IMP_DEUDA;
          
          IF vlSaldo < 0 THEN
             vlNumAmortProrrateo := vlAmortizaciones.NUM_PAGO_AMORTIZACION;
             vlSaldoProrrateo    := vlSaldo + vlAmortizaciones.IMP_DEUDA;
             EXIT;
          END IF;
      END LOOP;
      
      -- Calcula el importe de la amortizacion a prorratear
      SELECT SUM(IMP_NETO * -1)
        INTO vlImpAmortizacion
        FROM SIM_PRESTAMO_GPO_DET A, V_SIM_TABLA_AMORT_CONCEPTO B
       WHERE A.CVE_GPO_EMPRESA       = pCveGpoEmpresa 
         AND A.CVE_EMPRESA           = pCveEmpresa
         AND A.ID_PRESTAMO_GRUPO     = pIdPrestamo
         AND A.CVE_GPO_EMPRESA       = B.CVE_GPO_EMPRESA
         AND A.CVE_EMPRESA           = B.CVE_EMPRESA
         AND A.ID_PRESTAMO           = B.ID_PRESTAMO
         AND B.NUM_PAGO_AMORTIZACION = vlNumAmortProrrateo;
      
      -- Despliega el importe para cada participante del credito y calcula el valor de la suma de las proporciones
      vlImpProrrateado := 0; 
      
      FOR vlProporcion IN curProporcion LOOP
          -- Despliega la informacion
          --DBMS_OUTPUT.PUT_LINE('Prestamo : ' || vlProporcion.ID_PRESTAMO || ' Importe : ' || vlProporcion.IMP_DEUDA || ' Id Cliente: ' || vlProporcion.ID_CLIENTE || ' Nombre: ' || vlProporcion.NOM_COMPLETO);
                               
          vlImpProrrateado := vlImpProrrateado + vlProporcion.IMP_DEUDA;
      END LOOP;
      
      -- Recupera el valor que permite variar la suma de las proporciones
      SELECT NVL(IMP_VAR_PROPORCION,0)
        INTO vlImpVariaProporcion
        FROM SIM_PARAMETRO_GLOBAL
       WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
             CVE_EMPRESA     = pCveEmpresa;
        
      -- Determina el importe a ajustar en la proporcion de acuerdo al parametro
      vlImpAjuste := 0;
      
      IF (ABS(pImpPago) - ABS(vlImpProrrateado)) > vlImpVariaProporcion THEN
         vlImpAjuste := pImpPago - vlImpProrrateado;
      END IF;
      
      --DBMS_OUTPUT.PUT_LINE('Ajuste: ' || vlImpAjuste);
      
      OPEN vlCurSalida FOR
         SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.ID_CLIENTE, C.NOM_COMPLETO, 
                RANK() OVER (PARTITION BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.ID_CLIENTE ORDER BY SUM(IMP_DEUDA) DESC) AS ID_ORDEN,
                CASE WHEN RANK() OVER (PARTITION BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.ID_CLIENTE ORDER BY SUM(IMP_DEUDA) DESC) = 1
                     THEN SUM(IMP_DEUDA) + vlImpAjuste
                     ELSE SUM(IMP_DEUDA)
                END AS IMP_DEUDA
           FROM (SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO, ROUND(SUM(IMP_NETO *-1),2) AS IMP_DEUDA
                   FROM SIM_PRESTAMO_GPO_DET A, V_SIM_TABLA_AMORT_CONCEPTO B
                  WHERE A.CVE_GPO_EMPRESA   = pCveGpoEmpresa 
                    AND A.CVE_EMPRESA       = pCveEmpresa
                    AND A.ID_PRESTAMO_GRUPO = pIdPrestamo
                    AND A.CVE_GPO_EMPRESA   = B.CVE_GPO_EMPRESA
                    AND A.CVE_EMPRESA       = B.CVE_EMPRESA
                    AND A.ID_PRESTAMO       = B.ID_PRESTAMO
                    AND B.NUM_PAGO_AMORTIZACION < vlNumAmortProrrateo
                  group by A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO
                  UNION ALL
                 SELECT A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO, 
                        ROUND(SUM(IMP_NETO *-1) / vlImpAmortizacion * vlSaldoProrrateo,2) AS IMP_DEUDA
                   FROM SIM_PRESTAMO_GPO_DET A, V_SIM_TABLA_AMORT_CONCEPTO B
                  WHERE A.CVE_GPO_EMPRESA       = pCveGpoEmpresa 
                    AND A.CVE_EMPRESA           = pCveEmpresa
                    AND A.ID_PRESTAMO_GRUPO     = pIdPrestamo
                    AND A.CVE_GPO_EMPRESA       = B.CVE_GPO_EMPRESA
                    AND A.CVE_EMPRESA           = B.CVE_EMPRESA
                    AND A.ID_PRESTAMO           = B.ID_PRESTAMO
                    AND B.NUM_PAGO_AMORTIZACION = vlNumAmortProrrateo
                  GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, B.ID_PRESTAMO) A, SIM_PRESTAMO B, RS_GRAL_PERSONA C
          WHERE A.CVE_GPO_EMPRESA = B.CVE_GPO_EMPRESA AND
                A.CVE_EMPRESA     = B.CVE_EMPRESA     AND
                A.ID_PRESTAMO     = B.ID_PRESTAMO     AND
                B.CVE_GPO_EMPRESA = C.CVE_GPO_EMPRESA AND
                B.CVE_EMPRESA     = C.CVE_EMPRESA     AND
                B.ID_CLIENTE      = C.ID_PERSONA
          GROUP BY A.CVE_GPO_EMPRESA, A.CVE_EMPRESA, A.ID_PRESTAMO, B.ID_CLIENTE, C.NOM_COMPLETO;
      RETURN vlCurSalida;
      
    END fCalculaProporcion;
    
    -- Funcion utilizada para registrar el pago total de un credito individual en caso de que muera la persona
    FUNCTION fRegistraMovtoDefuncion(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                     pIdPrestamo      IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                     pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                     pFValor          IN PFIN_PRE_MOVIMIENTO.F_OPERACION%TYPE,
                                     pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER
       -- Cursor que devuelve los conceptos que deben liquidarse
    IS
       vlCveOperacion   PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE := cPagoDefuncion;
       vlImpDeuda       PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
       vlIdCuenta       SIM_PRESTAMO.ID_CUENTA_REFERENCIA%TYPE;
       vlIdPreMovto     PFIN_PRE_MOVIMIENTO.ID_PRE_MOVIMIENTO%TYPE;
       vlIdMovimiento   PFIN_PRE_MOVIMIENTO.ID_MOVIMIENTO%TYPE;
    BEGIN
       -- Valida que sea un credito individual ya que solo puede morirse un individuo
       IF fExistePresamoIndividual(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo) <> cVerdadero OR
          fEsPrestamoGrupal(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo)        =  cVerdadero THEN
          pTxRespuesta := 'El credito no existe o es un credito grupal';
          RETURN -1;
       END IF;
       
       -- Actualiza la informacion del credito
        vgResultado := fActualizaInformacionCredito(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pFValor, pTxRespuesta);
      
       -- Recupera el saldo total del credito
       SELECT SUM(IMP_NETO) * -1
         INTO vlImpDeuda
         FROM V_SIM_TABLA_AMORT_CONCEPTO 
        WHERE CVE_GPO_EMPRESA       = pCveGpoEmpresa AND
              CVE_EMPRESA           = pCveEmpresa    AND
              ID_PRESTAMO           = pIdPrestamo;

       IF vlImpDeuda <= 0 THEN
          pTxRespuesta := 'El credito no tiene adeudos';
          RETURN -1;
       END IF;
       
       -- Recupera la cuenta asociada al credito
       vlIdCuenta := fObtieneCuenta(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, pTxrespuesta);

       DBMS_OUTPUT.PUT_LINE('CUENTA:' || vlIdCuenta);
       
       IF vlIdCuenta <= 0 THEN
          RETURN -1;
       END IF;
       
       -- Se obtiene el folio de grupo para las transacciones
       SELECT SQ02_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vgFolioGrupo FROM DUAL;

        -- Se obtiene el id del premovimiento
       SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

       -- Se genera el premovimiento
       PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, vlIdCuenta, pIdPrestamo,
                                    cDivisaPeso, cAbonoAjuste, vlImpDeuda, 'AJUSTE', 'AJUSTE', 'Ajuste por defuncion',
                                    vgFolioGrupo, pCveUsuario, pFValor, 0, pTxrespuesta);            

       IF pTxrespuesta IS NOT NULL THEN 
          RETURN 1; 
       END IF;
            
       PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, cImpBruto, vlImpDeuda, 'Ajuste por defuncion', pTxrespuesta);

       -- Se procesa el premovimiento
       vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pcvegpoempresa, pcveempresa, vlIdPreMovto, 'PV', NULL, cFalso, ptxrespuesta);
       
       DBMS_OUTPUT.PUT_LINE('ACTUALIZO PREMOVTO:' || vlIdPreMovto);

       -- Ejecuta el pago del credito utilizando la clave de operacion de defuncion
       pAplicaPagoCredito(pCveGpoEmpresa, pCveEmpresa, pIdPrestamo, vgFolioGrupo, pCveUsuario, pFValor, vlCveOperacion, pTxrespuesta);

       IF pTxrespuesta IS NOT NULL THEN 
          ROLLBACK;
          RETURN 1; 
       END IF;
           
       DBMS_OUTPUT.PUT_LINE('Aplico el credito');
       
       -- Actualiza la situacion del prestamo
       UPDATE SIM_PRESTAMO
          SET ID_ETAPA_PRESTAMO = cEtapaLiqXDefuncion
        WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
              CVE_EMPRESA     = pCveEmpresa    AND
              ID_PRESTAMO     = pIdPrestamo;

       DBMS_OUTPUT.PUT_LINE('Actualizo el prestamo');
       
       RETURN 0;
    END fRegistraMovtoDefuncion;
    
    -- Funcion utilizada para registrar los diferentes tipos de pagos extraordinarios
    FUNCTION fRegistraMovtoExtraordinario(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                          pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                          pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                          pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                          pArrayConceptos  IN TT_MOVTO_AJUSTE,
                                          pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER
    IS
       vlCveAfectaCredito      PFIN_CAT_OPERACION.CVE_AFECTA_CREDITO%TYPE;
    BEGIN
       -- Recupera informacion del la clave de operacion
       BEGIN
          SELECT CVE_AFECTA_CREDITO
            INTO vlCveAfectaCredito
            FROM PFIN_CAT_OPERACION
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
                 CVE_EMPRESA     = pCveEmpresa    AND
                 CVE_OPERACION   = pCveOperacion;
           
          EXCEPTION
              WHEN NO_DATA_FOUND THEN vlCveAfectaCredito := cNoAplica;
       END;
       
       -- Valida que el movimiento afecte el credito y llama la funcion de cargo o abono de acuerdo a la bandera
       CASE
           WHEN vlCveAfectaCredito = cDecrementa THEN
                vgResultado := fRegistraMovtoExtraPago(pCveGpoEmpresa, pCveEmpresa, pCveOperacion, pCveUsuario, pArrayConceptos, pTxRespuesta);
           WHEN vlCveAfectaCredito = cIncrementa  THEN
                vgResultado := fRegistraMovtoExtraCobro(pCveGpoEmpresa, pCveEmpresa, pCveOperacion, pCveUsuario, pArrayConceptos, pTxRespuesta);
           ELSE pTxRespuesta := 'La clave de operacion no existe o no esta configurada para este tipo de movimiento';
       END CASE;

       RETURN vgResultado;
    END fRegistraMovtoExtraordinario;
  
    -- Funcion utilizada para registrar los diferentes tipos de pagos extraordinarios
    FUNCTION fRegistraMovtoExtraPago(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                     pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                     pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                     pArrayConceptos  IN TT_MOVTO_AJUSTE,
                                     pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER
    IS
       vlContador     NUMBER;
       vlIdPrestamo   PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE;
       vlCveConcepto  PFIN_PRE_MOVIMIENTO_DET.CVE_CONCEPTO%TYPE;
       vlImpConcepto  PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
       vlImpPagoAmort PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
       vlImpPago      PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
       vlIdCuenta     SIM_PRESTAMO.ID_CUENTA_REFERENCIA%TYPE;
       vlIdPreMovto   PFIN_PRE_MOVIMIENTO.ID_PRE_MOVIMIENTO%TYPE;
       vlIdMovimiento PFIN_PRE_MOVIMIENTO.ID_MOVIMIENTO%TYPE;
       vlFValor       PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE := vgFechaSistema;

       CURSOR curConceptos IS
          SELECT ID_PRESTAMO, CVE_CONCEPTO, IMP_CONCEPTO
            FROM SIM_TEMP_CONCEPTO;
            
       CURSOR curConceptoXAmort (pIdPrestamo  IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                 pCveConcepto IN PFIN_PRE_MOVIMIENTO_DET.CVE_CONCEPTO%TYPE) IS
          SELECT NUM_PAGO_AMORTIZACION, IMP_NETO * -1 AS IMP_DEBE
            FROM V_SIM_TABLA_AMORT_CONCEPTO
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
                 CVE_EMPRESA     = pCveEmpresa    AND
                 ID_PRESTAMO     = pIdPrestamo    AND
                 CVE_CONCEPTO    = pCveConcepto   AND
                 IMP_NETO        < 0
           ORDER BY NUM_PAGO_AMORTIZACION;
           
       CURSOR curPrestamos IS
          SELECT DISTINCT ID_PRESTAMO
            FROM SIM_TEMP_CONCEPTO;

       CURSOR curMovtoAjuste IS
          SELECT ID_PRESTAMO, SUM(IMP_CONCEPTO) AS IMP_AJUSTE
            FROM SIM_TEMP_AMORT_CONCEPTO
           GROUP BY ID_PRESTAMO;
           
       CURSOR curAjusteXAmort (pIdPrestamo  IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE) IS
          SELECT ID_PRESTAMO, NUM_PAGO_AMORTIZACION, SUM(IMP_CONCEPTO) AS IMP_AJUSTE
            FROM SIM_TEMP_AMORT_CONCEPTO
           WHERE ID_PRESTAMO = pIdPrestamo
           GROUP BY ID_PRESTAMO, NUM_PAGO_AMORTIZACION;           

       CURSOR curAjusteXAmortConcepto (pIdPrestamo          IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                       pNumPagoAmortizacion IN PFIN_PRE_MOVIMIENTO.NUM_PAGO_AMORTIZACION%TYPE) IS
          SELECT ID_PRESTAMO, NUM_PAGO_AMORTIZACION, CVE_CONCEPTO, SUM(IMP_CONCEPTO) AS IMP_AJUSTE
            FROM SIM_TEMP_AMORT_CONCEPTO
           WHERE ID_PRESTAMO           = pIdPrestamo AND
                 NUM_PAGO_AMORTIZACION = pNumPagoAmortizacion
           GROUP BY ID_PRESTAMO, NUM_PAGO_AMORTIZACION, CVE_CONCEPTO;
           
    BEGIN

       -- Recupera el arreglo de prestamos, conceptos e importes y los inserta en una tabla temporal
       FOR vlContador IN 1 .. pArrayConceptos.COUNT LOOP
          -- Recupera el arreglo de datos
          vlIdPrestamo  := pArrayConceptos(vlContador).ID_PRESTAMO;
          vlCveConcepto := pArrayConceptos(vlContador).CVE_CONCEPTO;
          vlImpConcepto := pArrayConceptos(vlContador).IMP_CONCEPTO;

          DBMS_OUTPUT.PUT_LINE('Iteracion: ' || vlContador || ' Prestamo: ' || vlIdPrestamo || ' Concepto: ' || vlCveConcepto || ' Importe: ' || vlImpConcepto);

          -- Carga los datos a una tabla temporal
          IF vlImpConcepto <> 0 THEN
             INSERT INTO SIM_TEMP_CONCEPTO 
                        (ID_PRESTAMO, CVE_CONCEPTO, IMP_CONCEPTO) 
                 VALUES (vlIdPrestamo, vlCveConcepto, vlImpConcepto);
          END IF;
       END LOOP;
       
       -- Actualiza la informacion de los creditos que se estan ajustando
       FOR vlBufPrestamos IN curPrestamos LOOP
           vgResultado := fActualizaInformacionCredito(pCveGpoEmpresa, pCveEmpresa, vlBufPrestamos.ID_PRESTAMO, vlFValor, pTxRespuesta);
       END LOOP;      
       
       -- Determinar en que amortizaciones debe aplicarse el concepto
       FOR vlBufConcepto IN curConceptos LOOP
           vlImpPago := vlBufConcepto.IMP_CONCEPTO;

           DBMS_OUTPUT.PUT_LINE('Calculando pago por amortizacion para el concepto: ' || vlBufConcepto.CVE_CONCEPTO || ' Importe: ' || vlImpPago);
           
           FOR vlBufConceptoXAmort IN curConceptoXAmort(vlBufConcepto.ID_PRESTAMO, vlBufConcepto.CVE_CONCEPTO) LOOP
               IF vlImpPago = 0 THEN
                  EXIT;
               END IF;
               
               IF vlBufConceptoXAmort.IMP_DEBE < vlImpPago THEN
                  vlImpPagoAmort := vlBufConceptoXAmort.IMP_DEBE;
               ELSE 
                  vlImpPagoAmort := vlImpPago;
               END IF;

               DBMS_OUTPUT.PUT_LINE('Inserta pago para la amortizacion Prestamo/Amortizacion/Concepto/Importe: ' ||
                                    vlBufConcepto.ID_PRESTAMO || '/' || vlBufConceptoXAmort.NUM_PAGO_AMORTIZACION || '/' || 
                                    vlBufConcepto.CVE_CONCEPTO || '/' || vlImpPagoAmort);
               
               -- Inserta el pago de la amortizacion
               INSERT INTO SIM_TEMP_AMORT_CONCEPTO
                           (ID_PRESTAMO, NUM_PAGO_AMORTIZACION, CVE_CONCEPTO, IMP_CONCEPTO) 
                    VALUES (vlBufConcepto.ID_PRESTAMO, vlBufConceptoXAmort.NUM_PAGO_AMORTIZACION,
                            vlBufConcepto.CVE_CONCEPTO, vlImpPagoAmort);

               -- Resta el importe pagado
               vlImpPago := vlImpPago - vlImpPagoAmort;
           END LOOP;
         
       END LOOP;
       
       -- Se obtiene el folio de grupo para las transacciones
       SELECT SQ02_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vgFolioGrupo FROM DUAL;
       
       -- Inserta cada uno de los ajustes por cada prestamo
       FOR vlBufMovtoAjuste IN curMovtoAjuste LOOP
           -- Recupera la cuenta asociada al credito
           vlIdCuenta := fObtieneCuenta(pCveGpoEmpresa, pCveEmpresa, vlBufMovtoAjuste.ID_PRESTAMO, pTxrespuesta);

           DBMS_OUTPUT.PUT_LINE('CUENTA:' || vlIdCuenta);
       
           IF vlIdCuenta <= 0 THEN
              RETURN -1;
           END IF;
         
           -- Se obtiene el id del premovimiento
           SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

           -- Se genera el premovimiento del ajuste
           PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, vlIdCuenta, 
                                        vlBufMovtoAjuste.ID_PRESTAMO, cDivisaPeso, cAbonoAjuste, 
                                        vlBufMovtoAjuste.IMP_AJUSTE, 'AJUSTE', 'AJUSTE', 'Abono Ajuste Extraordinario',
                                        vgFolioGrupo, pCveUsuario, vlFValor, 0, pTxrespuesta);

           IF pTxrespuesta IS NOT NULL THEN 
              DBMS_OUTPUT.PUT_LINE('Respuesta Premovto Ajuste:' || pTxrespuesta);

              RETURN 1; 
           END IF;
            
           PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, cImpBruto, vlBufMovtoAjuste.IMP_AJUSTE, 
                                           'Abono Ajuste Extraordinario', pTxrespuesta);

           -- Se procesa el premovimiento
           vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pcvegpoempresa, pcveempresa, vlIdPreMovto, 'PV', NULL, cFalso, ptxrespuesta);
       
           DBMS_OUTPUT.PUT_LINE('ACTUALIZO PREMOVTO:' || vlIdPreMovto);
           
           -- ****************************************************************************************
           -- Inserta un pago extraordinario por cada amortizacion
           -- ****************************************************************************************
           FOR vlBufAjusteXAmort IN curAjusteXAmort(vlBufMovtoAjuste.ID_PRESTAMO) LOOP
               -- Se obtiene el id del premovimiento
               SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

               -- Se genera el premovimiento del movimiento extraordinario
               PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, vlIdCuenta, 
                                            vlBufMovtoAjuste.ID_PRESTAMO, cDivisaPeso, pCveOperacion, 
                                            vlBufAjusteXAmort.IMP_AJUSTE, 'AJUSTE', 'AJUSTE', 'Ajuste Extraordinario',
                                            vgFolioGrupo, pCveUsuario, vlFValor, vlBufAjusteXAmort.NUM_PAGO_AMORTIZACION, pTxrespuesta);            

              IF pTxrespuesta IS NOT NULL THEN 
                 DBMS_OUTPUT.PUT_LINE('Respuesta Premovto:' || pTxrespuesta);
                 RETURN 1; 
              END IF;
            
              -- Genera los detalles de los conceptos
              FOR vlBufAjusteXAmortConcepto IN curAjusteXAmortConcepto(vlBufMovtoAjuste.ID_PRESTAMO,
                                               vlBufAjusteXAmort.NUM_PAGO_AMORTIZACION)             LOOP
                  PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vlBufAjusteXAmortConcepto.CVE_CONCEPTO,
                                                  vlBufAjusteXAmortConcepto.IMP_AJUSTE, 'Ajuste Extraordinario', pTxrespuesta);
              END LOOP;
              
              -- Se procesa el premovimiento
              vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pcvegpoempresa, pcveempresa, vlIdPreMovto, 'PV', NULL, cFalso, ptxrespuesta);
       
              DBMS_OUTPUT.PUT_LINE('ACTUALIZO PREMOVTO:' || vlIdPreMovto);
              
              -- Actualiza la informacion de la tabla de amortizacion y de los accesorios con el movimiento generado
              pActualizaTablaAmortizacion(pCveGpoEmpresa, pCveEmpresa, vlIdMovimiento, pTxRespuesta);
              
              DBMS_OUTPUT.PUT_LINE('Respuesta Actualiza Credito:' || pTxrespuesta);
           END LOOP;
       END LOOP;

       pTxRespuesta := 'Movimiento aplicado con exito';

       RETURN 0;
    END fRegistraMovtoExtraPago;

    -- Funcion utilizada para registrar los diferentes tipos de cobros extraordinarios
    FUNCTION fRegistraMovtoExtraCobro(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                      pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                      pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                      pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                      pArrayConceptos  IN TT_MOVTO_AJUSTE,
                                      pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER
    IS
       vlContador     NUMBER;
       vlIdPrestamo   PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE;
       vlCveConcepto  PFIN_PRE_MOVIMIENTO_DET.CVE_CONCEPTO%TYPE;
       vlImpConcepto  PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
       vlImpPagoAmort PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
       vlImpPago      PFIN_PRE_MOVIMIENTO.IMP_NETO%TYPE;
       vlIdCuenta     SIM_PRESTAMO.ID_CUENTA_REFERENCIA%TYPE;
       vlIdPreMovto   PFIN_PRE_MOVIMIENTO.ID_PRE_MOVIMIENTO%TYPE;
       vlIdMovimiento PFIN_PRE_MOVIMIENTO.ID_MOVIMIENTO%TYPE;
       vlFValor       PFIN_PRE_MOVIMIENTO.F_APLICACION%TYPE := vgFechaSistema;

       CURSOR curConceptos IS
          SELECT ID_PRESTAMO, CVE_CONCEPTO, IMP_CONCEPTO
            FROM SIM_TEMP_CONCEPTO;
            
       CURSOR curAmortizacion (pIdPrestamo  IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE) IS
          SELECT NUM_PAGO_AMORTIZACION, SUM(IMP_NETO) * -1 AS IMP_DEBE
            FROM V_SIM_TABLA_AMORT_CONCEPTO
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa AND
                 CVE_EMPRESA     = pCveEmpresa    AND
                 ID_PRESTAMO     = pIdPrestamo
           GROUP BY NUM_PAGO_AMORTIZACION
           HAVING SUM(IMP_NETO) < 0
           ORDER BY NUM_PAGO_AMORTIZACION;
           
       CURSOR curPrestamos IS
          SELECT DISTINCT ID_PRESTAMO
            FROM SIM_TEMP_CONCEPTO;

       CURSOR curMovtoAjuste IS
          SELECT ID_PRESTAMO, SUM(IMP_CONCEPTO) AS IMP_AJUSTE
            FROM SIM_TEMP_AMORT_CONCEPTO
           GROUP BY ID_PRESTAMO;
           
       CURSOR curAjusteXAmort (pIdPrestamo  IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE) IS
          SELECT ID_PRESTAMO, NUM_PAGO_AMORTIZACION, SUM(IMP_CONCEPTO) AS IMP_AJUSTE
            FROM SIM_TEMP_AMORT_CONCEPTO
           WHERE ID_PRESTAMO = pIdPrestamo
           GROUP BY ID_PRESTAMO, NUM_PAGO_AMORTIZACION;           

       CURSOR curAjusteXAmortConcepto (pIdPrestamo          IN PFIN_PRE_MOVIMIENTO.ID_PRESTAMO%TYPE,
                                       pNumPagoAmortizacion IN PFIN_PRE_MOVIMIENTO.NUM_PAGO_AMORTIZACION%TYPE) IS
          SELECT ID_PRESTAMO, NUM_PAGO_AMORTIZACION, CVE_CONCEPTO, SUM(IMP_CONCEPTO) AS IMP_AJUSTE
            FROM SIM_TEMP_AMORT_CONCEPTO
           WHERE ID_PRESTAMO           = pIdPrestamo AND
                 NUM_PAGO_AMORTIZACION = pNumPagoAmortizacion
           GROUP BY ID_PRESTAMO, NUM_PAGO_AMORTIZACION, CVE_CONCEPTO;
           
    BEGIN

       -- Recupera el arreglo de prestamos, conceptos e importes y los inserta en una tabla temporal
       FOR vlContador IN 1 .. pArrayConceptos.COUNT LOOP
          -- Recupera el arreglo de datos
          vlIdPrestamo  := pArrayConceptos(vlContador).ID_PRESTAMO;
          vlCveConcepto := pArrayConceptos(vlContador).CVE_CONCEPTO;
          vlImpConcepto := pArrayConceptos(vlContador).IMP_CONCEPTO;

          DBMS_OUTPUT.PUT_LINE('Iteracion: ' || vlContador || ' Prestamo: ' || vlIdPrestamo || ' Concepto: ' || vlCveConcepto || ' Importe: ' || vlImpConcepto);

          -- Carga los datos a una tabla temporal
          IF vlImpConcepto <> 0 THEN
             INSERT INTO SIM_TEMP_CONCEPTO 
                        (ID_PRESTAMO, CVE_CONCEPTO, IMP_CONCEPTO) 
                 VALUES (vlIdPrestamo, vlCveConcepto, vlImpConcepto);
          END IF;
       END LOOP;
       
       -- Actualiza la informacion de los creditos que se estan ajustando
       FOR vlBufPrestamos IN curPrestamos LOOP
           vgResultado := fActualizaInformacionCredito(pCveGpoEmpresa, pCveEmpresa, vlBufPrestamos.ID_PRESTAMO, vlFValor, pTxRespuesta);
       END LOOP;      
       
       -- Determinar en que amortizaciones debe aplicarse el concepto
       FOR vlBufConcepto IN curConceptos LOOP
           vlImpPago := vlBufConcepto.IMP_CONCEPTO;

           DBMS_OUTPUT.PUT_LINE('Calculando pago por amortizacion para el concepto: ' || vlBufConcepto.CVE_CONCEPTO || ' Importe: ' || vlImpPago);
           
           FOR vlBufAmortizacion IN curAmortizacion(vlBufConcepto.ID_PRESTAMO) LOOP
               IF vlImpPago = 0 THEN
                  EXIT;
               END IF;
               
               vlImpPagoAmort := vlImpPago;
               
               DBMS_OUTPUT.PUT_LINE('Inserta pago para la amortizacion Prestamo/Amortizacion/Concepto/Importe: ' ||
                                    vlBufConcepto.ID_PRESTAMO || '/' || vlBufAmortizacion.NUM_PAGO_AMORTIZACION || '/' || 
                                    vlBufConcepto.CVE_CONCEPTO || '/' || vlImpPagoAmort);
               
               -- Inserta el pago de la amortizacion
               INSERT INTO SIM_TEMP_AMORT_CONCEPTO
                           (ID_PRESTAMO, NUM_PAGO_AMORTIZACION, CVE_CONCEPTO, IMP_CONCEPTO) 
                    VALUES (vlBufConcepto.ID_PRESTAMO, vlBufAmortizacion.NUM_PAGO_AMORTIZACION,
                            vlBufConcepto.CVE_CONCEPTO, vlImpPagoAmort);

               -- Resta el importe pagado
               vlImpPago := vlImpPago - vlImpPagoAmort;
           END LOOP;
         
       END LOOP;

       -- Se obtiene el folio de grupo para las transacciones
       SELECT SQ02_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vgFolioGrupo FROM DUAL;
       
       -- Inserta cada uno de los ajustes por cada prestamo
       FOR vlBufMovtoAjuste IN curMovtoAjuste LOOP
           -- Recupera la cuenta asociada al credito
           vlIdCuenta := fObtieneCuenta(pCveGpoEmpresa, pCveEmpresa, vlBufMovtoAjuste.ID_PRESTAMO, pTxrespuesta);

           DBMS_OUTPUT.PUT_LINE('CUENTA:' || vlIdCuenta);
       
           IF vlIdCuenta <= 0 THEN
              RETURN -1;
           END IF;
         
           -- Se obtiene el id del premovimiento
           SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

           -- Se genera el premovimiento del ajuste
           PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, vlIdCuenta, 
                                        vlBufMovtoAjuste.ID_PRESTAMO, cDivisaPeso, cCargoAjuste, 
                                        vlBufMovtoAjuste.IMP_AJUSTE, 'AJUSTE', 'AJUSTE', 'Cargo Ajuste Extraordinario',
                                        vgFolioGrupo, pCveUsuario, vlFValor, 0, pTxrespuesta);            

           IF pTxrespuesta IS NOT NULL THEN 
              DBMS_OUTPUT.PUT_LINE('Respuesta Premovto Ajuste:' || pTxrespuesta);

              RETURN 1; 
           END IF;
            
           PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, cImpBruto, vlBufMovtoAjuste.IMP_AJUSTE, 
                                           'Abono Ajuste Extraordinario', pTxrespuesta);

           -- Se procesa el premovimiento
           vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pcvegpoempresa, pcveempresa, vlIdPreMovto, 'PV', NULL, cFalso, ptxrespuesta);
       
           DBMS_OUTPUT.PUT_LINE('ACTUALIZO PREMOVTO:' || vlIdPreMovto);
           
           -- ****************************************************************************************
           -- Inserta un pago extraordinario por cada amortizacion
           -- ****************************************************************************************
           FOR vlBufAjusteXAmort IN curAjusteXAmort(vlBufMovtoAjuste.ID_PRESTAMO) LOOP
               -- Se obtiene el id del premovimiento
               SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

               -- Se genera el premovimiento del movimiento extraordinario
               PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, vlIdCuenta, 
                                            vlBufMovtoAjuste.ID_PRESTAMO, cDivisaPeso, pCveOperacion, 
                                            vlBufAjusteXAmort.IMP_AJUSTE, 'AJUSTE', 'AJUSTE', 'Ajuste Extraordinario',
                                            vgFolioGrupo, pCveUsuario, vlFValor, vlBufAjusteXAmort.NUM_PAGO_AMORTIZACION, pTxrespuesta);            

              IF pTxrespuesta IS NOT NULL THEN 
                 DBMS_OUTPUT.PUT_LINE('Respuesta Premovto:' || pTxrespuesta);
                 RETURN 1; 
              END IF;
            
              -- Genera los detalles de los conceptos
              FOR vlBufAjusteXAmortConcepto IN curAjusteXAmortConcepto(vlBufMovtoAjuste.ID_PRESTAMO,
                                               vlBufAjusteXAmort.NUM_PAGO_AMORTIZACION)             LOOP
                  PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vlBufAjusteXAmortConcepto.CVE_CONCEPTO,
                                                  vlBufAjusteXAmortConcepto.IMP_AJUSTE, 'Ajuste Extraordinario', pTxrespuesta);
              END LOOP;
              
              -- Se procesa el premovimiento
              vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pcvegpoempresa, pcveempresa, vlIdPreMovto, 'PV', NULL, cFalso, ptxrespuesta);
       
              DBMS_OUTPUT.PUT_LINE('ACTUALIZO PREMOVTO:' || vlIdPreMovto);
              
              -- Actualiza la informacion de la tabla de amortizacion y de los accesorios con el movimiento generado
              pActualizaTablaAmortXCargo(pCveGpoEmpresa, pCveEmpresa, vlIdMovimiento, pTxRespuesta);
              
              DBMS_OUTPUT.PUT_LINE('Respuesta Actualiza Credito:' || pTxrespuesta);
           END LOOP;
       END LOOP;

       pTxRespuesta := 'Movimiento aplicado con exito';

       RETURN 0;
    END fRegistraMovtoExtraCobro;

    -- Funcion utilizada para probar los movimientos extraordinarios
    FUNCTION TestMovtoExtraordinario(pCveGpoEmpresa   IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                                     pCveEmpresa      IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                                     pCveOperacion    IN PFIN_PRE_MOVIMIENTO.CVE_OPERACION%TYPE,
                                     pCveUsuario      IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                                     pTxRespuesta     OUT VARCHAR2)
    RETURN NUMBER
    IS
       PARRAYCONCEPTOS TT_MOVTO_AJUSTE;
       MOVIMIENTO1 T_MOVTO_AJUSTE;
       MOVIMIENTO2 T_MOVTO_AJUSTE;
       MOVIMIENTO3 T_MOVTO_AJUSTE;
       MOVIMIENTO4 T_MOVTO_AJUSTE;
    BEGIN
       -- Modify the code to initialize the variable
       -- PARRAYCONCEPTOS := NULL;
       -- Arreglo que se envia de Java
       -- [[1872, CAPITA, 10], [1873, CAPITA, 10], [1874, CAPITA, 10], [1875, CAPITA, 10]]
       MOVIMIENTO1 := T_MOVTO_AJUSTE(1203,'CAPITA',1000);
       MOVIMIENTO2 := T_MOVTO_AJUSTE(1203,'INTERE',300);
       MOVIMIENTO3 := T_MOVTO_AJUSTE(1203,'INTEXT',8);
       MOVIMIENTO4 := T_MOVTO_AJUSTE(1203,'IVAINT',25);
       PARRAYCONCEPTOS := TT_MOVTO_AJUSTE(MOVIMIENTO1,MOVIMIENTO2,MOVIMIENTO3,MOVIMIENTO4);

       vgResultado := fRegistraMovtoExtraordinario(pCveGpoEmpresa, pCveEmpresa, pCveOperacion, pCveUsuario, PARRAYCONCEPTOS, pTxRespuesta);      

       DBMS_OUTPUT.PUT_LINE('PTXRESPUESTA = ' || PTXRESPUESTA);
       DBMS_OUTPUT.PUT_LINE('vgResultado = ' || vgResultado);

       RETURN 0;
    END TestMovtoExtraordinario;
    
    -- Funcion utilizada para cancelar el ultimo pago que se haya aplicado al credito
    FUNCTION fCancelaPago(pCveGpoEmpresa    IN PFIN_PRE_MOVIMIENTO.CVE_GPO_EMPRESA%TYPE,
                          pCveEmpresa       IN PFIN_PRE_MOVIMIENTO.CVE_EMPRESA%TYPE,
                          pIdMovimientoPago IN PFIN_PRE_MOVIMIENTO.ID_MOVIMIENTO%TYPE,
                          pCveUsuario       IN PFIN_PRE_MOVIMIENTO.CVE_USUARIO%TYPE,
                          pTxRespuesta      OUT VARCHAR2)
    RETURN NUMBER
    IS
       vlBufMovimiento        PFIN_MOVIMIENTO%ROWTYPE;
       vlMovtosPosteriores    NUMBER;
       vlIdPreMovto           NUMBER;
       vlIdMovimiento         NUMBER;
        
       CURSOR curPrestamos IS
          SELECT DISTINCT ID_PRESTAMO, F_APLICACION
            FROM PFIN_MOVIMIENTO
           WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa           AND
                 CVE_EMPRESA                   = pCveEmpresa              AND
                 ID_GRUPO                      = vlBufMovimiento.ID_GRUPO AND
                 NVL(ID_TRANSACCION_CANCELA,0) = 0                        AND
                 SIT_MOVIMIENTO               <> cSitCancelada            AND
                 CVE_OPERACION                 = cPagoPrestamo;
       
       CURSOR curPagosPrestamo IS
          SELECT *
            FROM PFIN_MOVIMIENTO
           WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa           AND
                 CVE_EMPRESA                   = pCveEmpresa              AND
                 ID_GRUPO                      = vlBufMovimiento.ID_GRUPO AND
                 NVL(ID_TRANSACCION_CANCELA,0) = 0                        AND
                 SIT_MOVIMIENTO               <> cSitCancelada            AND
                 CVE_OPERACION                 = cPagoPrestamo;
                 
       CURSOR curConceptos (pIdMovimiento IN PFIN_MOVIMIENTO.ID_MOVIMIENTO%TYPE) IS
          SELECT CVE_CONCEPTO, IMP_CONCEPTO
            FROM PFIN_MOVIMIENTO_DET
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa           AND
                 CVE_EMPRESA     = pCveEmpresa              AND
                 ID_MOVIMIENTO   = pIdMovimiento;
                 
       CURSOR curDepositos IS
          SELECT *
            FROM PFIN_MOVIMIENTO
           WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa           AND
                 CVE_EMPRESA                   = pCveEmpresa              AND
                 ID_GRUPO                      = vlBufMovimiento.ID_GRUPO AND
                 NVL(ID_TRANSACCION_CANCELA,0) = 0                        AND
                 SIT_MOVIMIENTO               <> cSitCancelada            AND
                 CVE_OPERACION                 = cDepositoTesoreria;                 
    BEGIN
       -- Valida que exista la transaccion original
       --        Debe existir
       --        Debe ser un pago
       --        No debe estar cancelada
       --        Debe excluir a las transacciones canceladas por un ajuste
       BEGIN
          SELECT *
            INTO vlBufMovimiento
            FROM PFIN_MOVIMIENTO
           WHERE CVE_GPO_EMPRESA               = pCveGpoEmpresa    AND
                 CVE_EMPRESA                   = pCveEmpresa       AND
                 ID_MOVIMIENTO                 = pIdMovimientoPago AND
                 NVL(ID_TRANSACCION_CANCELA,0) = 0                 AND
                 NVL(ID_GRUPO,0)               <> 0                AND
                 CVE_OPERACION                 = cPagoPrestamo;
           
          EXCEPTION 
             WHEN NO_DATA_FOUND THEN
                  pTxRespuesta := 'No existe el movimiento o no es un movimiento que pueda cancelarse o el grupo del movimiento es cero';
                  RETURN -1;
       END;     
       
       -- Valida que la fecha valor no sea menor a un pago previo
       BEGIN
          SELECT COUNT(1)
            INTO vlMovtosPosteriores
            FROM PFIN_MOVIMIENTO
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa
             AND CVE_EMPRESA     = pCveEmpresa
             AND ID_PRESTAMO     = vlBufMovimiento.ID_PRESTAMO
             AND SIT_MOVIMIENTO <> cSitCancelada
             AND NVL(ID_TRANSACCION_CANCELA,0) = 0
             AND NVL(F_APLICACION,F_LIQUIDACION) > vlBufMovimiento.F_APLICACION;
             
          EXCEPTION 
              WHEN NO_DATA_FOUND THEN vlMovtosPosteriores := 0;
       END;
       
       IF vlMovtosPosteriores > 0 THEN
          pTxrespuesta := 'Existen movimientos con fecha valor posterior a este movimiento';
          RETURN -1;
       END IF;

       -- Recupera el grupo
       SELECT SQ02_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vgFolioGrupo FROM DUAL;
       
       -- Genera los movimientos de ajuste por cancelacion
       FOR vlBufAjuste IN curDepositos LOOP
           -- Se obtiene el id del premovimiento
           SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

           -- Se genera el premovimiento del ajuste
           PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, 
                                        vlBufAjuste.ID_CUENTA, vlBufAjuste.ID_PRESTAMO, cDivisaPeso, cCargoAjuste, 
                                        vlBufAjuste.IMP_NETO, 'AJUSTE', 'AJUSTE', 'Cargo Ajuste Extraordinario',
                                        vgFolioGrupo, pCveUsuario, vlBufAjuste.F_APLICACION, 0, pTxrespuesta);            

           IF pTxrespuesta IS NOT NULL THEN 
              DBMS_OUTPUT.PUT_LINE('Respuesta Premovto Ajuste:' || pTxrespuesta);
              RETURN -1; 
           END IF;
            
           PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, cImpBruto, vlBufAjuste.IMP_NETO, 
                                           'Abono Ajuste Extraordinario', pTxrespuesta);

           -- Se procesa el premovimiento
           vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, 'PV', NULL, cFalso, pTxRespuesta);
       END LOOP;
       
       -- Recupera el grupo de las transacciones para generar la cancelacion de cada uno de los pagos del prestamo
       FOR vlBufPagos IN curPagosPrestamo LOOP
          -- Genera la cancelacion del credito con la informacion de la transaccion
          
          -- Se obtiene el id del premovimiento
          SELECT SQ01_PFIN_PRE_MOVIMIENTO.NEXTVAL INTO vlIdPreMovto FROM DUAL;

          -- Se genera el premovimiento del movimiento extraordinario
          PKG_PROCESOS.pGeneraPreMovto(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vgFechaSistema, 
                                       vlBufPagos.ID_CUENTA, vlBufPagos.ID_PRESTAMO, cDivisaPeso, cCancelaPago, 
                                       vlBufPagos.IMP_NETO, 'AJUSTE', 'AJUSTE', 'Ajuste Extraordinario', vgFolioGrupo,
                                       pCveUsuario, vlBufPagos.F_APLICACION, vlBufPagos.NUM_PAGO_AMORTIZACION, pTxrespuesta);            

          IF pTxrespuesta IS NOT NULL THEN 
             DBMS_OUTPUT.PUT_LINE('Respuesta Premovto:' || pTxrespuesta);
             RETURN -1; 
          END IF;
            
          -- Crea el detalle con los mismo conceptos que el pago del credito
          FOR vlBufConceptos IN curConceptos(vlBufPagos.ID_MOVIMIENTO) LOOP
              PKG_PROCESOS.pGeneraPreMovtoDet(pCveGpoEmpresa, pCveEmpresa, vlIdPreMovto, vlBufConceptos.CVE_CONCEPTO,
                                              vlBufConceptos.IMP_CONCEPTO, 'Ajuste Extraordinario', pTxrespuesta);
          END LOOP;
              
          -- Se procesa el premovimiento
          vlIdMovimiento := PKG_PROCESADOR_FINANCIERO.pprocesamovimiento(pcvegpoempresa, pcveempresa, vlIdPreMovto, 'PV', NULL, cFalso, ptxrespuesta);
          
          -- Actualiza la informacion de la tabla de amortizacion y de los accesorios con el movimiento generado
          pActualizaTablaAmortizacion(pCveGpoEmpresa, pCveEmpresa, vlIdMovimiento, pTxRespuesta);
          
          -- Actualiza la transaccion original
          UPDATE PFIN_MOVIMIENTO
             SET ID_TRANSACCION_CANCELA = vlIdMovimiento
           WHERE CVE_GPO_EMPRESA = pCveGpoEmpresa    AND
                 CVE_EMPRESA     = pCveEmpresa       AND
                 ID_MOVIMIENTO   = vlBufPagos.ID_MOVIMIENTO;
       END LOOP;

       -- Actualiza la informacion de los creditos involucrados
       FOR vlBufPrestamos IN curPrestamos LOOP
           vgResultado := fActualizaInformacionCredito(pCveGpoEmpresa, pCveEmpresa, vlBufPrestamos.ID_PRESTAMO, vlBufPrestamos.F_APLICACION, pTxRespuesta);
       END LOOP;
                        
       pTxRespuesta := 'Movimiento aplicado con exito';
       
       RETURN 0;
    END fCancelaPago;
    
/*
Incidencia 36: No esta asignando el recargo a un integrante cuando el grupo tiene deuda
*/
    
BEGIN
   -- Se asigna la fecha del sistema a la variable global
   vgFechaSistema := PKG_PROCESOS.DameFechaSistema('SIM', 'CREDICONFIA');
   
END PKG_CREDITO;
/
