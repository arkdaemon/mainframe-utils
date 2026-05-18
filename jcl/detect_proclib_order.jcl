//DETECTPR JOB (ACCT),'DETECT PROCLIB ORDER',CLASS=A,MSGCLASS=X,
//             NOTIFY=&SYSUID,REGION=0M
//*
//* REXX script to detect PROCLIB search order (z/OS 2.4+)
//*
//REXX EXEC PGM=IKJEFT01,DYNAMNBR=20
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
%detect_proclib_order
/* To search for a specific procedure, pass it as argument: */
/* %detect_proclib_order MYPROC     */
/*
