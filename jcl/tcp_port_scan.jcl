//TCPPSCAN JOB (ACCT),'TCP PORT SCAN',MSGCLASS=X,CLASS=A,
//             NOTIFY=&SYSUID
//*---------------------------------------------------------------
//* TCP PORT SCAN UTILITY
//* Runs rexx/tcp_port_scan.rexx from the mainframe-utils repo
//*
//* Input CSV format : host,service,IP,port
//* Output CSV format: host,service,ip,port,status
//*
//STEP01   EXEC PGM=IKJEFT01,REGION=0M
//SYSTSPRT DD SYSOUT=*
//SYSTSIN  DD *
   %TCPPSCAN
/*
//INDD     DD DSN=YOUR.INPUT.CSV.DATASET,DISP=SHR
//OUTDD    DD DSN=&SYSUID..TCP.PORTSCAN.OUTPUT,
//            DISP=(NEW,CATLG,DELETE),
//            SPACE=(TRK,(20,10),RLSE),
//            DCB=(RECFM=VB,LRECL=512,BLKSIZE=0)
//SYSEXEC  DD DSN=YOUR.REXX.LIBRARY,DISP=SHR
/*