BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE LOGS';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

CREATE TABLE LOGS
(
  LOG_ID                NUMBER, 
  PROC_NAME             VARCHAR2(30), 
  LOG_DTM               DATE, 
  LOG_TYPE              VARCHAR2(10), 
  ERROR_CODE            NUMBER, 
  MSG                   VARCHAR2(3000), 
  DB_USER               VARCHAR2(30),
  LINE_NUMBER           NUMBER,
  PRIMARY KEY (LOG_ID),
  CONSTRAINT LOG_TYPE_CONSTRAINT CHECK (LOG_TYPE IN ('INFO', 'DEBUG', 'WARNING', 'ERROR', 'FATAL'))
)
PARTITION BY RANGE (LOG_DTM)
 INTERVAL(NUMTOYMINTERVAL(1, 'MONTH'))
 (PARTITION P201709 VALUES LESS THAN (TO_DATE('01-10-2017', 'DD-MM-YYYY')))
TABLESPACE &TABLESPACE;
/

COMMENT ON TABLE LOGS IS 'Log table';

COMMENT ON COLUMN LOGS.LOG_ID IS 'PK (Timestamp + LOG_ID_SEQ)';
COMMENT ON COLUMN LOGS.PROC_NAME IS 'Function, Procedure or Package being executed';
COMMENT ON COLUMN LOGS.LOG_DTM IS 'Execution date';
COMMENT ON COLUMN LOGS.LOG_TYPE IS 'Type of log: INFO, WARNING, DEBUG, ERROR, FATAL';
COMMENT ON COLUMN LOGS.ERROR_CODE IS 'ORA- or personalized Error Code';
COMMENT ON COLUMN LOGS.MSG IS 'Log message to be presented';
COMMENT ON COLUMN LOGS.LINE_NUMBER IS 'The corresponding line number in the Funtion, Procedure or Package being executed';