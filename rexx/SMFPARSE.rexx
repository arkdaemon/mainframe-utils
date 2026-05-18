/* REXX - Parse SMF 119 subtype 6 records and output CSV with
/* interface bytes in/out and rates per sec/min/hour/day          */

/* Parameters:
/* - target_sid: Optional LPAR name to filter records (e.g., SYS1)
/*   If not provided, process all LPARs.                          */

ARG target_sid .

/* Set numeric digits for large number handling                   */
NUMERIC DIGITS 20

/* Function to get unsigned 64-bit value from 8 bytes             */
get_unsigned8: PROCEDURE
  ARG bytes
  val = C2D(bytes)
  IF val < 0 THEN val = val + (2 ** 64)
  RETURN val

/* Main script starts here                                        */
/* Assume SMFIN and OUTDD are allocated in JCL                    */

/* Write CSV header to output                                     */
QUEUE '"LPAR","RecordDate","RecordTime","Interface",',
      '"DurationSec","InboundBytes","OutboundBytes",',
      '"InPerSec","OutPerSec","InPerMin","OutPerMin",',
      '"InPerHour","OutPerHour","InPerDay","OutPerDay"'
ADDRESS TSO "EXECIO "QUEUED()" DISKW OUTDD ("

/* Loop to read each record from SMFIN                            */
DO FOREVER
  /* Read one record into stem rec.                               */
  "EXECIO 1 DISKR SMFIN (STEM rec."
  IF RC \= 0 THEN LEAVE  /* End of file, exit loop               */
  rec = rec.1  /* Get the record content                       */
  
  /* Validate record length                                       */
  rlen = C2D(SUBSTR(rec,1,2))
  IF rlen \= LENGTH(rec) THEN ITERATE
  
  /* Check record type (must be 119)                              */
  rty = C2D(SUBSTR(rec,6,1))  /* offset 5                     */
  IF rty \= 119 THEN ITERATE
  
  /* Check subtype (must be 6)                                    */
  sty = C2D(SUBSTR(rec,23,2))  /* offset 22                    */
  IF sty \= 6 THEN ITERATE
  
  /* Extract system ID (LPAR name)                                */
  sid = STRIP(SUBSTR(rec,15,4))  /* offset 14                  */
  
  /* Filter by target_sid if provided                             */
  IF target_sid \= '' & sid \= target_sid THEN ITERATE
  
  /* Extract packed date and time                                 */
  dte = SUBSTR(rec,11,4)
  tme = C2D(SUBSTR(rec,7,4))
  
  /* Parse date from packed format                                */
  hex_dte = C2X(dte)
  c = X2D(SUBSTR(hex_dte,2,1))
  yy = X2D(SUBSTR(hex_dte,3,2))
  ddd = X2D(SUBSTR(hex_dte,5,3))
  year = 1900 + c * 100 + yy
  
  leap = 0
  IF year // 4 = 0 & (year // 100 \= 0 | year // 400 = 0),
     THEN leap = 1
  month_days = '31 '||(28 + leap)||' 31 30 31 30 31 31 30 31 30 31'
  
  day_of_year = ddd
  DO m = 1 TO 12
    md = WORD(month_days, m)
    IF day_of_year <= md THEN DO
      month = m
      day = day_of_year
      LEAVE
    END
    day_of_year = day_of_year - md
  END
  
  date_str = RIGHT(year,4,'0')||'-'||RIGHT(month,2,'0')||'-'||RIGHT(day,2,'0')
  
  /* Parse time into HH:MM:SS                                     */
  seconds = tme / 100
  hours = TRUNC(seconds / 3600)
  mins = TRUNC((seconds // 3600) / 60)
  secs = TRUNC(seconds // 60)
  time_str = RIGHT(hours,2,'0')||':'||RIGHT(mins,2,'0')||':'||RIGHT(secs,2,'0')
  
  /* Parse self-defining section                                  */
  s1_off = C2D(SUBSTR(rec,37,4))
  s1_len = C2D(SUBSTR(rec,41,2))
  s1_num = C2D(SUBSTR(rec,43,2))
  
  curr_pos = s1_off + 1
  DO int = 1 TO s1_num
    duration_us = get_unsigned8(SUBSTR(rec, curr_pos, 8))
    if_name = STRIP(SUBSTR(rec, curr_pos + 25, 16))
    in_bytes = get_unsigned8(SUBSTR(rec, curr_pos + 89, 8))
    out_bytes = get_unsigned8(SUBSTR(rec, curr_pos + 133, 8))
    
    duration_sec = duration_us / 1000000
    IF duration_sec = 0 THEN duration_sec = 1
    
    in_per_sec = in_bytes / duration_sec
    out_per_sec = out_bytes / duration_sec
    
    in_per_min = in_per_sec * 60
    out_per_min = out_per_sec * 60
    in_per_hour = in_per_min * 60
    out_per_hour = out_per_min * 60
    in_per_day = in_per_hour * 24
    out_per_day = out_per_hour * 24
    
    QUEUE '"'sid'","'date_str'","'time_str'","'if_name'","',
          duration_sec'","'in_bytes'","'out_bytes'","',
          in_per_sec'","'out_per_sec'","'in_per_min'","',
          out_per_min'","'in_per_hour'","'out_per_hour'","',
          in_per_day'","'out_per_day'"'
    
    curr_pos = curr_pos + s1_len
  END
  
  "EXECIO "QUEUED()" DISKW OUTDD ("
END

/* Close datasets                                                 */
"EXECIO 0 DISKR SMFIN (FINIS"
"EXECIO 0 DISKW OUTDD (FINIS"

EXIT 0