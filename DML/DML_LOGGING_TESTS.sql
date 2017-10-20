SET SERVEROUTPUT ON
DECLARE

  V_LOG_LEVEL           PARAMS.VALUE%TYPE;
  V_PROC_NAME           LOGS.PROC_NAME%TYPE;
  V_COUNTER             NUMBER;
  V_TEST_NUMBER         VARCHAR2(2);

BEGIN

  --Delete previous test output
  DELETE 
    FROM LOGS
   WHERE MSG LIKE 'T% - V_LOG_LEVEL set to %; will print'
      OR MSG = 'Error test code 49714';
      
  COMMIT;

  V_TEST_NUMBER := 'T1';
  DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER|| ' - Set the Log Level in the PARAM table to 4: Must log everything with LOG_TYPE INFO, WARNING, ERROR and FATAL');
  V_LOG_LEVEL := '4';

  UPDATE PARAMS
     SET VALUE = V_LOG_LEVEL
   WHERE PARAM = 'LogLevel'
     AND (END_DTM IS NULL OR END_DTM > SYSDATE);

  COMMIT;

  LOG_PKG.LOG_PR ('DEBUG', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('INFO', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('WARNING', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('ERROR', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('FATAL', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);

  --Assert result
  SELECT COUNT(1)
    INTO V_COUNTER
    FROM LOGS
   WHERE MSG = V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print';

  IF V_COUNTER = 4 THEN
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - OK - 4 RECORDS');
  ELSE
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - NOK - '||V_COUNTER||' RECORD(S)');
  END IF;

  V_TEST_NUMBER := 'T2';
  DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER|| ' - Set the Log Level in the PARAM table to 5: Must log everything with LOG_TYPE DEBUG, INFO, WARNING, ERROR and FATAL');
  V_LOG_LEVEL := '5';

  UPDATE PARAMS
     SET VALUE = V_LOG_LEVEL
   WHERE PARAM = 'LogLevel'
     AND (END_DTM IS NULL OR END_DTM > SYSDATE);

  COMMIT;

  LOG_PKG.LOG_PR ('DEBUG', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('INFO', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('WARNING', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('ERROR', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('FATAL', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);

  --Assert result
  SELECT COUNT(1)
    INTO V_COUNTER
    FROM LOGS
   WHERE MSG = V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print';

  IF V_COUNTER = 5 THEN
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - OK - 5 RECORDS');
  ELSE
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - NOK - '||V_COUNTER||' RECORD(S)');
  END IF;

  V_TEST_NUMBER := 'T3';
  DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER|| ' - Set the Log Level in the PARAM table to 2: Must log only LOG_TYPE ERROR and FATAL');
  V_LOG_LEVEL := '2';

  UPDATE PARAMS
     SET VALUE = V_LOG_LEVEL
   WHERE PARAM = 'LogLevel'
     AND (END_DTM IS NULL OR END_DTM > SYSDATE);

  COMMIT;

  LOG_PKG.LOG_PR ('DEBUG', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('INFO', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('WARNING', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('ERROR', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('FATAL', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);

  --Assert result
  SELECT COUNT(1)
    INTO V_COUNTER
    FROM LOGS
   WHERE MSG = V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print';

  IF V_COUNTER = 2 THEN
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - OK - 2 RECORDS');
  ELSE
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - NOK - '||V_COUNTER||' RECORD(S)');
  END IF;

  V_TEST_NUMBER := 'T4';
  DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER|| ' - Set the Log Level in the PARAM table to 0: No log log should be generated');
  V_LOG_LEVEL := '0';

  UPDATE PARAMS
     SET VALUE = V_LOG_LEVEL
   WHERE PARAM = 'LogLevel'
     AND (END_DTM IS NULL OR END_DTM > SYSDATE);

  COMMIT;

  LOG_PKG.LOG_PR ('DEBUG', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('INFO', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('WARNING', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('ERROR', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);
  LOG_PKG.LOG_PR ('FATAL', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print', V_PROC_NAME, NULL, NULL, NULL);

  --Assert result
  SELECT COUNT(1)
    INTO V_COUNTER
    FROM LOGS
   WHERE MSG = V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print';

  IF V_COUNTER = 0 THEN
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - OK - 0 RECORDS');
  ELSE
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - NOK - '||V_COUNTER||' RECORD(S)');
  END IF;

  V_TEST_NUMBER := 'T5';
  DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER|| ' - Set the Log Level in the PARAM table to 2: Must log only LOG_TYPE ERROR and FATAL + Print customized error message');
  V_LOG_LEVEL := '2';

  UPDATE PARAMS
     SET VALUE = V_LOG_LEVEL
   WHERE PARAM = 'LogLevel'
     AND (END_DTM IS NULL OR END_DTM > SYSDATE);

  COMMIT;

  LOG_PKG.LOG_PR ('ERROR', 49714, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will not print and print the customized error message instead', V_PROC_NAME, 49714, NULL, NULL);
  LOG_PKG.LOG_PR ('ERROR', NULL, V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print', V_PROC_NAME, NULL, NULL, NULL);

  --Assert result
  SELECT COUNT(1)
    INTO V_COUNTER
    FROM LOGS
   WHERE (MSG = 'Error test code 49714' OR MSG = V_TEST_NUMBER||' - V_LOG_LEVEL set to '||V_LOG_LEVEL||'; will print');

  IF V_COUNTER = 2 THEN
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - OK - 2 RECORDS');
  ELSE
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - NOK - '||V_COUNTER||' RECORD(S)');
  END IF;

  V_TEST_NUMBER := 'T6';
  DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER|| ' - Table was created with partition for a previous month; the current inserts (with the current date) should force the creation of a new table partition if it doens exist already; check if its writting in the correct partition');

  --Assert result
  SELECT COUNT(1)
    INTO V_COUNTER
    FROM ALL_TAB_PARTITIONS
   WHERE TABLE_NAME = 'LOGS'
     AND PARTITION_POSITION = 1 + MONTHS_BETWEEN(TRUNC(SYSDATE,'MM'), TO_DATE('01-09-2017','DD-MM-YYYY'));
     
  IF V_COUNTER = 1 THEN
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - OK - 1 RECORDS');
  ELSE
    DBMS_OUTPUT.PUT_LINE(V_TEST_NUMBER||' - NOK - '||V_COUNTER||' RECORD(S)');
  END IF;

END;
/
