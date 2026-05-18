/* REXX */
/* Detect proclib search order and optionally locate a proc */
PARSE UPPER ARG procname
ADDRESS TSO

OUTTRAP 'lines.'
"LISTALC STATUS"
OUTTRAP 'OFF'

/* Parse for PROCLIB and IEFPDSI */
user_proclibs. = ''
user_proclibs.0 = 0
sys_proclibs. = ''
sys_proclibs.0 = 0
in_dd = ''

DO i = 1 TO lines.0
  line = lines.i
  IF LEFT(line,1) \= ' ' THEN DO
    ddword = WORD(line,1)
    IF LENGTH(ddword) = 8 & TRANSLATE(ddword) = ddword THEN DO
      IF ddword = 'PROCLIB' THEN in_dd = 'USER'
      ELSE IF ddword = 'IEFPDSI' THEN in_dd = 'SYS'
      ELSE in_dd = ''
      ITERATE
    END
    ELSE ITERATE
  END
  IF in_dd \= '' THEN DO
    dsname = STRIP(LEFT(line,44))
    IF dsname \= '' THEN DO
      IF in_dd = 'USER' THEN DO
        user_proclibs.0 = user_proclibs.0 + 1
        n = user_proclibs.0
        user_proclibs.n = dsname
      END
      ELSE IF in_dd = 'SYS' THEN DO
        sys_proclibs.0 = sys_proclibs.0 + 1
        n = sys_proclibs.0
        sys_proclibs.n = dsname
      END
    END
  END
END

/* Combine: user then sys */
proclibs.0 = user_proclibs.0 + sys_proclibs.0
DO i = 1 TO user_proclibs.0
  proclibs.i = user_proclibs.i
END
offset = user_proclibs.0
DO i = 1 TO sys_proclibs.0
  proclibs.offset+i = sys_proclibs.i
END

/* Output the search order */
SAY 'Procedure libraries search order:'
IF proclibs.0 = 0 THEN SAY 'No proclibs found.'
ELSE DO i = 1 TO proclibs.0
  SAY i || ': ' || proclibs.i
END

/* If procname given, find where loaded from */
IF procname \= '' THEN DO
  found = 0
  "FREE F(CHKPROC)" /* ignore if not alloc */
  DO i = 1 TO proclibs.0
    dsn = proclibs.i
    "ALLOC F(CHKPROC) DS('"dsn"') SHR REUSE"
    IF RC = 0 THEN DO
      "EXECIO 0 DISKR CHKPROC (FINIS MEMBER("procname")"
      IF RC = 0 THEN DO
        SAY 'Procedure 'procname' found in:'
        SAY '  ' dsn
        found = 1
        LEAVE
      END
    END
  END
  "FREE F(CHKPROC)"
  IF found = 0 THEN
    SAY 'Procedure 'procname' not found in any proclib.'
END

EXIT 0