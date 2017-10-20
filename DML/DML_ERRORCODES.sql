DELETE
  FROM ERRORCODES;

COMMIT;

INSERT INTO ERRORCODES (ERROR_CODE, DESCRIPTION, CREATE_DTM, LAST_UPDATE_DTM)
VALUES (49714, 'Error test code %1', SYSDATE, NULL);

INSERT INTO ERRORCODES (ERROR_CODE, DESCRIPTION, CREATE_DTM, LAST_UPDATE_DTM)
VALUES (40000, 'ORA-%1 - An error occurred while trying to delete records form LOGS table previous to %2.', SYSDATE, NULL);

COMMIT;