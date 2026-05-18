/* REXX - TCP Reachability Checker for z/OS                     */
/*                                                              */
/* Input:  INDD  = sequential dataset in CSV format             */
/*         each line:  host,service,IP,port                     */
/*                                                              */
/* Output: OUTDD = sequential dataset in CSV format             */
/*         each line:  host,service,ip,port,status              */
/*         status = "reachable" or "not-reachable"              */
/*                                                              */
/* Runs under TSO batch (IKJEFT01) with INDD/OUTDD DD statements. */
/* Uses the native z/OS Communications Server REXX SOCKET API.  */

say '*** TCP Connectivity Checker starting ***'

/* ------------------------------------------------------------- */
/* 1. Initialize the REXX socket interface (required on z/OS)    */
/* ------------------------------------------------------------- */
subtaskid = 'TCPCHK'                     /* any unique name */
parse value Socket('Initialize', subtaskid) with initrc .
if initrc \= '0' then do
   say 'ERROR: Socket Initialize failed rc='initrc
   exit 8
end

/* ------------------------------------------------------------- */
/* 2. Read the entire INDD dataset                               */
/* ------------------------------------------------------------- */
"EXECIO * DISKR INDD (STEM indata. FINIS"
if rc \= 0 then do
   say 'ERROR: EXECIO read of INDD failed rc='rc
   call TerminateSockets
   exit 8
end

say indata.0 'records read from INDD'

/* ------------------------------------------------------------- */
/* 3. Process each line and build output stem                    */
/* ------------------------------------------------------------- */
outdata.0 = 0
outdata.1 = 'host,service,ip,port,status'   /* helpful header */
outdata.0 = 1

do i = 1 to indata.0
   line = strip(indata.i)
   if line = '' | left(line,1) = '#' then iterate   /* skip blanks/comments */

   /* Simple CSV parse (assumes no embedded commas in fields) */
   parse var line host ',' service ',' ip ',' port
   host    = strip(host)
   service = strip(service)
   ip      = strip(ip)
   port    = strip(port)

   if ip = '' | port = '' | datatype(port,'W') = 0 then
      status = 'invalid'
   else
      status = TestTCP(ip, port)

   outrec = host || ',' || service || ',' || ip || ',' || port || ',' || status

   outdata.0 = outdata.0 + 1
   outdata.outdata.0 = outrec
end

/* ------------------------------------------------------------- */
/* 4. Write the OUTDD dataset                                    */
/* ------------------------------------------------------------- */
"EXECIO * DISKW OUTDD (STEM outdata. FINIS"
if rc \= 0 then
   say 'WARNING: EXECIO write to OUTDD failed rc='rc
else
   say (outdata.0 - 1) 'records written to OUTDD (including header)'

/* ------------------------------------------------------------- */
/* 5. Clean up                                                   */
/* ------------------------------------------------------------- */
call TerminateSockets
say '*** TCP Connectivity Checker finished ***'
exit 0

/* ============================================================ */
/* Subroutine: simple TCP connect test (just SYN handshake)    */
/* ============================================================ */
TestTCP:
   procedure
   parse arg tip, tport
   /* Create a TCP socket (defaults to AF_INET / SOCK_STREAM) */
   parse value Socket('Socket') with rc sd
   if rc \= '0' then return 'not-reachable'

   /* Build sockaddr string */
   name = 'AF_INET' tport tip

   /* Attempt connect */
   parse value Socket('Connect', sd, name) with rc .
   if rc = '0' then
      status = 'reachable'
   else
      status = 'not-reachable'

   /* Always close the socket */
   parse value Socket('Close', sd) with rc_close .

   return status

/* ============================================================ */
/* Subroutine: terminate socket interface                       */
/* ============================================================ */
TerminateSockets:
   parse value Socket('Terminate') with termrc .
   if termrc \= '0' then
      say 'Warning: Socket Terminate rc='termrc
   return