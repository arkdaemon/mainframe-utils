# mainframe-utils

Collection of useful **REXX scripts**, **JCL examples**, and tools for **IBM z/OS Mainframe**.

This repository is a growing collection of practical utilities I use on the mainframe.

## 📋 Available Tools

### Proclib Search Order Detector

**Script:** `rexx/detect_proclib_order.rexx`

A REXX script that detects the actual search order of procedure libraries (PROCLIB) used by the system, including user and system proclibs. It can also locate a specific procedure if provided as a parameter.

**Features:**
- Shows the exact order in which proclibs are searched (user PROCLIB first, then IEFPDSI)
- Optionally finds which library a specific procedure (member) is loaded from
- Works in TSO, ISPF, and batch (z/OS 2.4+)
- 80-column friendly for batch execution

**Files:**
- [`rexx/detect_proclib_order.rexx`](rexx/detect_proclib_order.rexx) - Main REXX script
- [`jcl/detect_proclib_order.jcl`](jcl/detect_proclib_order.jcl) - Sample JCL

**How to use:**
1. Submit the JCL or run `%detect_proclib_order` in TSO
2. Optionally: `%detect_proclib_order MYPROC` to locate a specific procedure

---

### TCP Port Scanner / Connectivity Checker

**Script:** `rexx/tcp_port_scan.rexx`

A powerful REXX script that reads a CSV dataset containing hosts and ports, then tests TCP connectivity (simple connect) to each one.

**Features:**
- Uses native z/OS Communications Server REXX Socket API
- Pure TCP SYN connect (no data exchange) - works with any TCP service
- Supports FTP, Telnet, CICS Sockets, Connect:Direct, DB2, etc.
- Input and output in CSV format
- Fast and lightweight

**Files:**
- [`rexx/tcp_port_scan.rexx`](rexx/tcp_port_scan.rexx) - Main REXX script
- [`jcl/tcp_port_scan.jcl`](jcl/tcp_port_scan.jcl) - Ready-to-use JCL example

**How to use:**
1. Customize the JOB card and dataset names in `jcl/tcp_port_scan.jcl`
2. Prepare your input CSV (format: `host,service,IP,port`)
3. Submit the JCL

**Output:** A new CSV with an extra `status` column (`reachable` / `not-reachable`)

---

## Repository Structure

- `/rexx/`     → REXX scripts
- `/jcl/`      → JCL examples
- `/proc/`     → Cataloged procedures (coming soon)

## Contributions & Ideas

Feel free to suggest new scripts or improvements!

---

Made with ❤️ for the Mainframe community.