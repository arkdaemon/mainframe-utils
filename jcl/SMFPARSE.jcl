//SMFJOB   JOB (ACCOUNT),'SMF PARSE',CLASS=A,MSGCLASS=0
//*
//* Sample JCL to run SMFPARSE REXX script
//*
//EXECREXX EXEC PGM=IRXJCL,PARM='SMFPARSE'   /* Optional: PARM='SMFPARSE SYS1' to filter LPAR */
//SYSEXEC  DD DSN=YOUR.REXX.LIB,DISP=SHR     /* PDS with SMFPARSE member */
//SMFIN    DD DSN=YOUR.SMF.DUMP,DISP=SHR     /* Input SMF dump dataset */
//OUTDD    DD DSN=YOUR.OUTPUT.CSV,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(50,10),RLSE),
//            DCB=(RECFM=VB,LRECL=1024,BLKSIZE=0)
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD DUMMY
/*
 Notes:
 - Change YOUR.REXX.LIB and YOUR.SMF.DUMP and YOUR.OUTPUT.CSV as needed.
 - PARM can include LPAR name to filter, e.g. PARM='SMFPARSE SYS1'
 - OUTDD must be allocated in JCL (as requested).
*/