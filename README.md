PL/SQL SIMPLE LOGGING TOOL

This is simple LOGGING Package, written in Oracle's PL/SQL. It should work fine for 11g and up versions of Oracle Data Bases.

The LOGGING procedure works with a priority level system, much like Java's log4j (or log4j2 if you prefer).

After installing all the code, you'll just need to configure the intended log level in the PARAMS table (PARAM ='LogLevel') and in accordance with following:

	LOG_TYPE	|	LOG_LEVEL

	DEBUG		|	5
	INFO		|   4
	WARNING		|	3
	ERROR 		|	2
	FATAL		|	1
	NO LOGGING 	|	0

The default level is set to 4, i.e. INFO, so you'll have all the LOG_TYPES bellow that level written in the LOGS table. That means that the DEBUG LOG_TYPE will be ignored in this situation. If you rather have no logging at all you'll just need to set the parameter to 0.

The package also includes a simple House Keeping (HK) procedure that will delete records older than specified number of months. This value can be defined in the PARAMS table (PARAM = 'HKLookBackMonths').

Last but not leats you'll have the hability to handle customized error codes, simply by difining them in the ERRORCODES table and setting up to 3 variables to be replaced in order to provide context for the error at hand. For example, the following LOG_PR call, will check the ERRORCODES table for the ERROR_CODE = 49714 and, if found, it will replace the provided message for a customized one:

	LOG_PKG.LOG_PR ('ERROR', 49714, 'Log message', V_PROC_NAME, 49714, NULL, NULL);

The customized message, "Error test code %1", would be used, replacing the '%1' for '49714' wich is matched with the 5th argument of the LOG_PR. If you wish you can use also a %2 and a %3 wich will match with the followinf two arguments, respectively. In this case we would have the folowing message:

 "Error test code 49714"


INSTALATION GUIDE:

You should execute the Oracle SQL scripts in the following order using SQLPlus:

1- SEQ\LOG_ID_SEQ.sql
2- TAB\PARAMS.sql
3- DML\DML_PARAMS.sql
4- TAB\ERRORCODES.sql
5- DML\DML_ERRORCODES.sql
6- TAB\LOGS.sql
7- IDX\LGS_IDX1.sql
8- PCK\LOG_PCK.sql 

Be sure to check for any invalid object on your schema.

TESTING:

The testing script is available in the following directory:

DML\DML_LOGGING_TESTS.sql

It will execute 6 diferent tests:

T1 - Set the Log Level in the PARAM table to 4: Must log everything with LOG_TYPE INFO, WARNING, ERROR and FATAL
T2 - Set the Log Level in the PARAM table to 5: Must log everything with LOG_TYPE DEBUG, INFO, WARNING, ERROR and FATAL
T3 - Set the Log Level in the PARAM table to 2: Must log only LOG_TYPE ERROR and FATAL
T4 - Set the Log Level in the PARAM table to 0: No log log should be generated
T5 - Set the Log Level in the PARAM table to 2: Must log only LOG_TYPE ERROR and FATAL + Print customized error message
T6 - Table was created with partition for a previous month; the current inserts (with the current date) should force the creation of a new table partition if it doens exist already; check if it writting in the correct partition

The expected output should be something similar to this:

	T1 - Set the Log Level in the PARAM table to 4: Must log everything with LOG_TYPE INFO, WARNING, ERROR and FATAL
	T1 - OK - 4 RECORDS
	T2 - Set the Log Level in the PARAM table to 5: Must log everything with LOG_TYPE DEBUG, INFO, WARNING, ERROR and FATAL
	T2 - OK - 5 RECORDS
	T3 - Set the Log Level in the PARAM table to 2: Must log only LOG_TYPE ERROR and FATAL
	T3 - OK - 2 RECORDS
	T4 - Set the Log Level in the PARAM table to 0: No log log should be generated
	T4 - OK - 0 RECORDS
	T5 - Set the Log Level in the PARAM table to 2: Must log only LOG_TYPE ERROR and FATAL + Print customized error message
	T5 - OK - 2 RECORDS
	T6 - Table was created with partition for a previous month; the current inserts (with the current date) should force the creation of a new table partition if it doens exist already; check if it writting in the correct partition
	T6 - OK - 1 RECORDS
