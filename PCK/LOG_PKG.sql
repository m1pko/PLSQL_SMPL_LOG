CREATE OR REPLACE PACKAGE LOG_PKG
AS

  ROLLBACK_EXCEPTION EXCEPTION;
   
  G_USER                VARCHAR2 (30) := SYS_CONTEXT ('userenv', 'current_schema');

  C_DEBUG               CONSTANT VARCHAR2(5) := 'DEBUG';
  C_INFO                CONSTANT VARCHAR2(4) := 'INFO';
  C_WARNING             CONSTANT VARCHAR2(8) := 'WARNING';
  C_ERROR               CONSTANT VARCHAR2(5) := 'ERROR';
  C_FATAL               CONSTANT VARCHAR2(5) := 'FALTAL';

  PROCEDURE LOG_PR (I_LOG_TYPE    IN LOGS.LOG_TYPE%TYPE,
                    I_ERROR_CODE  IN LOGS.ERROR_CODE%TYPE,
                    I_MSG         IN LOGS.MSG%TYPE,
                    I_PROC_NAME   IN LOGS.PROC_NAME%TYPE,
                    I_PARAM1      IN VARCHAR2 DEFAULT NULL,
                    I_PARAM2      IN VARCHAR2 DEFAULT NULL,
                    I_PARAM3      IN VARCHAR2 DEFAULT NULL);

  PROCEDURE LOGS_HK_PR;

END LOG_PKG;
/

CREATE OR REPLACE PACKAGE BODY LOG_PKG
AS

-- ------------------------------------------------------------------------------------------------
-- NAME: WHO_CALLED_ME
--
-- PURPOSE: Obtain the calling unit and line number.
--          Procedure obtained from http://tkyte.blogspot.com/2009/10/httpasktomoraclecomtkytewhocalledme.html
--
-- DATE       USER            TAG DESCRIPTION                                      REVISION HISTORY
-- ---------- --------------- --- -----------------------------------------------------------------
-- 18-10-2017 MIGUEL BARBA    1. CREATED PROCEDURE.
-- ------------------------------------------------------------------------------------------------
  PROCEDURE WHO_CALLED_ME (OWNER OUT VARCHAR2, NAME OUT VARCHAR2, LINENO OUT NUMBER, CALLER_T OUT VARCHAR2)
  AS
    C_REGEXP CONSTANT   VARCHAR2 (100) := '^[^ ]+ +([0-9]+) +([A-Za-z0-9\ \_]*) +(([A-Za-z0-9\_]+)\.)?([A-Za-z0-9\_]+)$';
    CALL_STACK          VARCHAR2 (4096) DEFAULT DBMS_UTILITY.FORMAT_CALL_STACK;
    N                   NUMBER;
    FOUND_STACK         BOOLEAN DEFAULT FALSE;
    LINE                VARCHAR2 (255);
    CNT                 NUMBER := 0;
  BEGIN

    LOOP

      N := INSTR (CALL_STACK, CHR (10));
      EXIT WHEN (CNT = 4 OR N IS NULL OR N = 0);

      LINE := SUBSTR (CALL_STACK, 1, N - 1);
      CALL_STACK := SUBSTR (CALL_STACK, N + 1);


      IF (NOT FOUND_STACK) THEN
        IF (LINE LIKE '%handle%number%name%') THEN
          FOUND_STACK  := TRUE;
        END IF;
      ELSE
        CNT  := CNT + 1;

        -- CNT = 1 is ME
        -- CNT = 2 is MY Caller
        -- CNT = 3 is Their Caller
        IF ((CNT = 3 OR CNT = 4) AND NVL (REGEXP_REPLACE (LINE, C_REGEXP, '\2'), 'trigger') not like '%LOG_PR%') THEN

          SELECT REGEXP_REPLACE (LINE, C_REGEXP, '\1') A, NVL (REGEXP_REPLACE (LINE, C_REGEXP, '\2'), 'trigger') B, REGEXP_REPLACE (LINE, C_REGEXP, '\4') C, REGEXP_REPLACE (LINE, C_REGEXP, '\5')
            INTO LINENO, CALLER_T, OWNER, NAME
            FROM DUAL;

        END IF;

      END IF;
    END LOOP;

  END WHO_CALLED_ME;


-- ******************************************************************************
-- NAME: LOG_PR (Overload Procedure)
-- PURPOSE: LOGS MESSAGES ON LOG TABLE. IT's an independent transaction so log messages are not
--          lost if an error occurs during process execution.
--          The log table is LOGS.
--
-- DATE       USER             TAG DESCRIPTION                            REVISION HISTORY
-- ---------- ---------------  --- -------------------------------------------------------
-- 18-10-2017 MIGUEL BARBA     1.  CREATED PROCEDURE.
-- --------------------------------------------------------------------------------------
  PROCEDURE LOG_PR (
    I_LOG_TYPE    IN LOGS.LOG_TYPE%TYPE,
    I_ERROR_CODE  IN LOGS.ERROR_CODE%TYPE,
    I_MSG         IN LOGS.MSG%TYPE,
    I_PROC_NAME   IN LOGS.PROC_NAME%TYPE,
    I_PARAM1      IN VARCHAR2 DEFAULT NULL,
    I_PARAM2      IN VARCHAR2 DEFAULT NULL,
    I_PARAM3      IN VARCHAR2 DEFAULT NULL)
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    V_LOG_ID          NUMBER;
    V_MSG             LOGS.MSG%TYPE                   := I_MSG;
    V_LOG_TYPE        LOGS.LOG_TYPE%TYPE              := I_LOG_TYPE;
    V_PROC_NAME       LOGS.PROC_NAME%TYPE             := I_PROC_NAME;
    V_ERROR_CODE      ERROR_CODE.ERROR_CODE%TYPE      := I_ERROR_CODE;
    V_LINE_NUMBER     NUMBER;
    V_ERROR_DESC      ERROR_CODE.DESCRIPTION%TYPE;
    V_COUNT           NUMBER                          := 0;
    V_LOG_LEVEL       NUMBER;
    V_TRANSL_LOG_TYPE NUMBER;

  BEGIN

    SELECT TO_NUMBER(TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF2'))||LOG_ID_SEQ.NEXTVAL
      INTO V_LOG_ID
      FROM DUAL;

    BEGIN

      SELECT TO_NUMBER(VALUE,99)
        INTO V_LOG_LEVEL
        FROM PARAMS
       WHERE PARAM = 'LogLevel'
         AND (END_DTM IS NULL OR END_DTM > SYSDATE);

      SELECT CASE
               WHEN V_LOG_TYPE = 'DEBUG' THEN 5
               WHEN V_LOG_TYPE = 'INFO' THEN 4
               WHEN V_LOG_TYPE = 'WARNING' THEN 3
               WHEN V_LOG_TYPE = 'ERROR' THEN 2
               WHEN V_LOG_TYPE = 'FATAL' THEN 1
               ELSE 4
             END
        INTO V_TRANSL_LOG_TYPE
        FROM DUAL;

    EXCEPTION
      WHEN OTHERS THEN
        V_LOG_LEVEL := 4;
        V_TRANSL_LOG_TYPE := 4;
    END;

    DECLARE
       V_OWNER        VARCHAR2 (30);
       V_NAME         VARCHAR2 (30);
       V_LINENO       NUMBER;
       V_TYPE         VARCHAR2 (30);
    BEGIN
       WHO_CALLED_ME (V_OWNER, V_NAME, V_LINENO, V_TYPE);
       V_LINE_NUMBER  := V_LINENO;
    END;

    SELECT COUNT (1)
      INTO V_COUNT
      FROM ERRORCODES
     WHERE ERROR_CODE = ABS(V_ERROR_CODE);

    IF (V_COUNT > 0) THEN
      
      -- Procura o erro na tabela MGC_ERROR_CODE e devolve a respectiva descricao
      IF ((I_ERROR_CODE != NULL) OR (I_ERROR_CODE != 0)) THEN

        BEGIN

          SELECT REPLACE (REPLACE (REPLACE (DESCRIPTION, '%1', I_PARAM1), '%2', I_PARAM2), '%3', I_PARAM3)
            INTO V_ERROR_DESC
            FROM ERRORCODES
           WHERE ERROR_CODE = ABS (V_ERROR_CODE);

        EXCEPTION
          WHEN OTHERS THEN
            V_ERROR_DESC  := V_MSG;
        END;

      ELSE

        V_ERROR_DESC  := V_MSG;

      END IF;

      --V_LOG_LEVEL = 0 means no log is written 
      IF (V_LOG_LEVEL > 0 AND  V_LOG_LEVEL >= V_TRANSL_LOG_TYPE) THEN

        INSERT INTO LOGS (LOG_ID, PROC_NAME, LOG_DTM, LOG_TYPE, ERROR_CODE, MSG, DB_USER, LINE_NUMBER)
        VALUES (V_LOG_ID, V_PROC_NAME, SYSDATE, V_LOG_TYPE, V_ERROR_CODE, V_ERROR_DESC, G_USER, V_LINE_NUMBER);

      END IF;

    ELSE

      --V_LOG_LEVEL = 0 means no log is written
      IF (V_LOG_LEVEL > 0 AND  V_LOG_LEVEL >= V_TRANSL_LOG_TYPE) THEN

        INSERT INTO LOGS (LOG_ID, PROC_NAME, LOG_DTM, LOG_TYPE, ERROR_CODE, MSG, DB_USER, LINE_NUMBER)
        VALUES (V_LOG_ID, V_PROC_NAME, SYSDATE, V_LOG_TYPE, V_ERROR_CODE, V_MSG, G_USER, V_LINE_NUMBER);

      END IF;

    END IF;

    COMMIT;
  
  END LOG_PR;

-- ------------------------------------------------------------------------------------------------
-- NAME: LOGS_HK_PR
--
-- PURPOSE: Performs HK tasks over the log table by deleting the previous N months 
--          The N value may be configured in the PARAMS table
--
-- DATE       USER            TAG DESCRIPTION                                      REVISION HISTORY
-- ---------- --------------- --- -----------------------------------------------------------------
-- 20-10-2017 MIGUEL BARBA    1. CREATED PROCEDURE.
-- ------------------------------------------------------------------------------------------------
  PROCEDURE LOGS_HK_PR
  AS
    V_PROCEDURE_NAME    VARCHAR2(30);
    V_SYSDATE_TIMESTAMP DATE := SYSDATE;
    V_HK_REF_DATE       DATE;
    V_LOOK_BACK_MONTHS  NUMBER;
    V_ERROR_CODE        NUMBER;
    V_MSG               LOGS.MSG%TYPE;
  BEGIN

    V_PROCEDURE_NAME := 'LOGS_HK_PR';
    
    SELECT TO_NUMBER(VALUE,99)
      INTO V_LOOK_BACK_MONTHS
      FROM PARAMS
     WHERE PARAM = 'HKLookBackMonths'
       AND (END_DTM IS NULL OR END_DTM > SYSDATE);

    V_HK_REF_DATE := ADD_MONTHS(V_SYSDATE_TIMESTAMP, -V_LOOK_BACK_MONTHS);

    LOG_PR (C_INFO, NULL, 'Will delete all logs previous to '||V_HK_REF_DATE, V_PROCEDURE_NAME, NULL, NULL, NULL);

    DELETE 
      FROM LOGS
     WHERE LOG_DTM < V_SYSDATE_TIMESTAMP;

    COMMIT;

    LOG_PR (C_INFO, NULL, SQL%ROWCOUNT||' rows(s) deleted previous to '||V_HK_REF_DATE , V_PROCEDURE_NAME, NULL, NULL, NULL);

  EXCEPTION
    WHEN OTHERS THEN

      ROLLBACK;
      V_ERROR_CODE := 40000;
      V_MSG := 'An error occurred while trying to delete records from LOGS table.';
      LOG_PKG.LOG_PR (C_ERROR, V_ERROR_CODE, V_MSG, V_PROCEDURE_NAME, V_ERROR_CODE, V_HK_REF_DATE, NULL);

  END LOGS_HK_PR;

END LOG_PKG;
/
