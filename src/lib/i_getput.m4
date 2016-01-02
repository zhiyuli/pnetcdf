dnl Process this m4 file to produce 'C' language file.
dnl
dnl If you see this line, you can ignore the next one.
/* Do not edit this file. It is produced from the corresponding .m4 source */
dnl
/*
 *  Copyright (C) 2003, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 */
/* $Id$ */

#if HAVE_CONFIG_H
# include "ncconfig.h"
#endif

#include <stdio.h>
#include <unistd.h>
#ifdef HAVE_STDLIB_H
#include <stdlib.h>
#endif
#include <assert.h>

#include <string.h> /* memcpy() */
#include <mpi.h>

#include "nc.h"
#include "ncx.h"
#include "ncmpidtype.h"
#include "macro.h"


define(`CollIndep',   `ifelse(`$1',`_all', `COLL_IO', `INDEP_IO')')dnl
define(`ReadWrite',   `ifelse(`$1', `get', `READ_REQ', `WRITE_REQ')')dnl
define(`BufConst',    `ifelse(`$1', `put', `const')')dnl

dnl
dnl VAR_FLEXIBLE
dnl
define(`VAR_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_var() >----------------------------------------------------*/
int
ncmpi_i$1_var(int                ncid,
              int                varid,
              BufConst($1) void *buf,
              MPI_Offset         bufcount,
              MPI_Datatype       buftype,
              int               *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *start, *count;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, NULL, NULL, bufcount, API_VAR,
                                 0, 1, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    GET_FULL_DIMENSIONS(start, count)

    /* i$1_var is a special case of i$1_varm */
    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, bufcount, buftype, reqid,
                                 ReadWrite($1), 0, 0);
    if (varp->ndims > 0) NCI_Free(start);
    return status;
}
')dnl

VAR_FLEXIBLE(put)
VAR_FLEXIBLE(get)

dnl
dnl VAR
dnl
define(`VAR',dnl
`dnl
/*----< ncmpi_i$1_var_$2() >-------------------------------------------------*/
int
ncmpi_i$1_var_$2(int              ncid,
                 int              varid,
                 BufConst($1) $3 *buf,
                 int             *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *start, *count;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, NULL, NULL, 0, API_VAR,
                                 0, 0, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    GET_FULL_DIMENSIONS(start, count)

    /* i$1_var is a special case of i$1_varm */
    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, -1, $4, reqid,
                                 ReadWrite($1), 0, 0);
    if (varp->ndims > 0) NCI_Free(start);
    return status;
}
')dnl

VAR(put, text,      char,               MPI_CHAR)
VAR(put, schar,     schar,              MPI_SIGNED_CHAR)
VAR(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR(put, short,     short,              MPI_SHORT)
VAR(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR(put, int,       int,                MPI_INT)
VAR(put, uint,      uint,               MPI_UNSIGNED)
VAR(put, long,      long,               MPI_LONG)
VAR(put, float,     float,              MPI_FLOAT)
VAR(put, double,    double,             MPI_DOUBLE)
VAR(put, longlong,  long long,          MPI_LONG_LONG_INT)
VAR(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VAR(get, text,      char,               MPI_CHAR)
VAR(get, schar,     schar,              MPI_SIGNED_CHAR)
VAR(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR(get, short,     short,              MPI_SHORT)
VAR(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR(get, int,       int,                MPI_INT)
VAR(get, uint,      uint,               MPI_UNSIGNED)
VAR(get, long,      long,               MPI_LONG)
VAR(get, float,     float,              MPI_FLOAT)
VAR(get, double,    double,             MPI_DOUBLE)
VAR(get, longlong,  long long,          MPI_LONG_LONG_INT)
VAR(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


dnl
dnl VAR1_FLEXIBLE
dnl
define(`VAR1_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_var1() >---------------------------------------------------*/
int
ncmpi_i$1_var1(int                ncid,
               int                varid,
               const MPI_Offset  *start,
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *count;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, NULL, bufcount, API_VAR1,
                                 0, 1, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    GET_ONE_COUNT(count)

    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, bufcount, buftype, reqid,
                                 ReadWrite($1), 0, 0);
    if (varp->ndims > 0) NCI_Free(count);
    return status;
}
')dnl

VAR1_FLEXIBLE(put)
VAR1_FLEXIBLE(get)

dnl
dnl VAR1
dnl
define(`VAR1',dnl
`dnl
/*----< ncmpi_i$1_var1_$2() >------------------------------------------------*/
int
ncmpi_i$1_var1_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int         status;
    NC         *ncp;
    NC_var     *varp=NULL;
    MPI_Offset *count;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, NULL, 0, API_VAR1,
                                 0, 0, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    GET_ONE_COUNT(count)

    status = ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                                 (void*)buf, -1, $4, reqid, ReadWrite($1), 0,
                                 0);
    if (varp->ndims > 0) NCI_Free(count);
    return status;
}
')dnl

VAR1(put, text,      char,               MPI_CHAR)
VAR1(put, schar,     schar,              MPI_SIGNED_CHAR)
VAR1(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR1(put, short,     short,              MPI_SHORT)
VAR1(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR1(put, int,       int,                MPI_INT)
VAR1(put, uint,      uint,               MPI_UNSIGNED)
VAR1(put, long,      long,               MPI_LONG)
VAR1(put, float,     float,              MPI_FLOAT)
VAR1(put, double,    double,             MPI_DOUBLE)
VAR1(put, longlong,  long long,          MPI_LONG_LONG_INT)
VAR1(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VAR1(get, text,      char,               MPI_CHAR)
VAR1(get, schar,     schar,              MPI_SIGNED_CHAR)
VAR1(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VAR1(get, short,     short,              MPI_SHORT)
VAR1(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VAR1(get, int,       int,                MPI_INT)
VAR1(get, uint,      uint,               MPI_UNSIGNED)
VAR1(get, long,      long,               MPI_LONG)
VAR1(get, float,     float,              MPI_FLOAT)
VAR1(get, double,    double,             MPI_DOUBLE)
VAR1(get, longlong,  long long,          MPI_LONG_LONG_INT)
VAR1(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


dnl
dnl VARA_FLEXIBLE
dnl
define(`VARA_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_vara() >---------------------------------------------------*/
int
ncmpi_i$1_vara(int                ncid,
               int                varid,
               const MPI_Offset  *start,
               const MPI_Offset  *count,
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, count, bufcount, API_VARA,
                                 0, 1, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                               (void*)buf, bufcount, buftype, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARA_FLEXIBLE(put)
VARA_FLEXIBLE(get)

dnl
dnl VARA
dnl
define(`VARA',dnl
`dnl
/*----< ncmpi_i$1_vara_$1() >------------------------------------------------*/
int
ncmpi_i$1_vara_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, count, 0, API_VARA,
                                 0, 0, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, NULL, NULL,
                               (void*)buf, -1, $4, reqid, ReadWrite($1), 0, 0);
}
')dnl

VARA(put, text,      char,               MPI_CHAR)
VARA(put, schar,     schar,              MPI_SIGNED_CHAR)
VARA(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARA(put, short,     short,              MPI_SHORT)
VARA(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARA(put, int,       int,                MPI_INT)
VARA(put, uint,      uint,               MPI_UNSIGNED)
VARA(put, long,      long,               MPI_LONG)
VARA(put, float,     float,              MPI_FLOAT)
VARA(put, double,    double,             MPI_DOUBLE)
VARA(put, longlong,  long long,          MPI_LONG_LONG_INT)
VARA(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARA(get, text,      char,               MPI_CHAR)
VARA(get, schar,     schar,              MPI_SIGNED_CHAR)
VARA(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARA(get, short,     short,              MPI_SHORT)
VARA(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARA(get, int,       int,                MPI_INT)
VARA(get, uint,      uint,               MPI_UNSIGNED)
VARA(get, long,      long,               MPI_LONG)
VARA(get, float,     float,              MPI_FLOAT)
VARA(get, double,    double,             MPI_DOUBLE)
VARA(get, longlong,  long long,          MPI_LONG_LONG_INT)
VARA(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


dnl
dnl VARS_FLEXIBLE
dnl
define(`VARS_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_vars() >---------------------------------------------------*/
int
ncmpi_i$1_vars(int                ncid,
               int                varid,
               const MPI_Offset   start[],
               const MPI_Offset   count[],
               const MPI_Offset   stride[],
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, count, bufcount, API_VARS,
                                 0, 1, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, NULL,
                               (void*)buf, bufcount, buftype, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARS_FLEXIBLE(put)
VARS_FLEXIBLE(get)

dnl
dnl VARS
dnl
define(`VARS',dnl
`dnl
/*----< ncmpi_i$1_vars_$2() >------------------------------------------------*/
int
ncmpi_i$1_vars_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  const MPI_Offset  stride[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, count, 0, API_VARS,
                                 0, 0, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, NULL,
                               (void*)buf, -1, $4, reqid, ReadWrite($1), 0, 0);
}
')dnl

VARS(put, text,      char,               MPI_CHAR)
VARS(put, schar,     schar,              MPI_SIGNED_CHAR)
VARS(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARS(put, short,     short,              MPI_SHORT)
VARS(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARS(put, int,       int,                MPI_INT)
VARS(put, uint,      uint,               MPI_UNSIGNED)
VARS(put, long,      long,               MPI_LONG)
VARS(put, float,     float,              MPI_FLOAT)
VARS(put, double,    double,             MPI_DOUBLE)
VARS(put, longlong,  long long,          MPI_LONG_LONG_INT)
VARS(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARS(get, text,      char,               MPI_CHAR)
VARS(get, schar,     schar,              MPI_SIGNED_CHAR)
VARS(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARS(get, short,     short,              MPI_SHORT)
VARS(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARS(get, int,       int,                MPI_INT)
VARS(get, uint,      uint,               MPI_UNSIGNED)
VARS(get, long,      long,               MPI_LONG)
VARS(get, float,     float,              MPI_FLOAT)
VARS(get, double,    double,             MPI_DOUBLE)
VARS(get, longlong,  long long,          MPI_LONG_LONG_INT)
VARS(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)


/* buffer layers:

        User Level              buf     (user defined buffer of MPI_Datatype)
        MPI Datatype Level      cbuf    (contiguous buffer of ptype)
        NetCDF XDR Level        xbuf    (XDR I/O buffer)
*/

static int
pack_request(NC *ncp, NC_var *varp, NC_req *req,
             const MPI_Offset start[], const MPI_Offset count[],
             const MPI_Offset stride[]);

dnl
dnl VARM_FLEXIBLE
dnl
define(`VARM_FLEXIBLE',dnl
`dnl
/*----< ncmpi_i$1_varm() >---------------------------------------------------*/
int
ncmpi_i$1_varm(int                ncid,
               int                varid,
               const MPI_Offset   start[],
               const MPI_Offset   count[],
               const MPI_Offset   stride[],
               const MPI_Offset   imap[],
               BufConst($1) void *buf,
               MPI_Offset         bufcount,
               MPI_Datatype       buftype,
               int               *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, count, bufcount, API_VARM,
                                 0, 1, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, imap,
                               (void*)buf, bufcount, buftype, reqid,
                               ReadWrite($1), 0, 0);
}
')dnl

VARM_FLEXIBLE(put)
VARM_FLEXIBLE(get)

dnl
dnl VARM
dnl
define(`VARM',dnl
`dnl
/*----< ncmpi_i$1_varm_$2() >------------------------------------------------*/
int
ncmpi_i$1_varm_$2(int               ncid,
                  int               varid,
                  const MPI_Offset  start[],
                  const MPI_Offset  count[],
                  const MPI_Offset  stride[],
                  const MPI_Offset  imap[],
                  BufConst($1) $3  *buf,
                  int              *reqid)
{
    int     status;
    NC     *ncp;
    NC_var *varp=NULL;

    if (reqid != NULL) *reqid = NC_REQ_NULL;
    status = ncmpii_sanity_check(ncid, varid, start, count, 0, API_VARM,
                                 0, 0, ReadWrite($1), NONBLOCKING_IO, &ncp, &varp);
    if (status != NC_NOERR) return status;

    return ncmpii_igetput_varm(ncp, varp, start, count, stride, imap,
                               (void*)buf, -1, $4, reqid, ReadWrite($1), 0, 0);
}
')dnl

VARM(put, text,      char,               MPI_CHAR)
VARM(put, schar,     schar,              MPI_SIGNED_CHAR)
VARM(put, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARM(put, short,     short,              MPI_SHORT)
VARM(put, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARM(put, int,       int,                MPI_INT)
VARM(put, uint,      uint,               MPI_UNSIGNED)
VARM(put, long,      long,               MPI_LONG)
VARM(put, float,     float,              MPI_FLOAT)
VARM(put, double,    double,             MPI_DOUBLE)
VARM(put, longlong,  long long,          MPI_LONG_LONG_INT)
VARM(put, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

VARM(get, text,      char,               MPI_CHAR)
VARM(get, schar,     schar,              MPI_SIGNED_CHAR)
VARM(get, uchar,     uchar,              MPI_UNSIGNED_CHAR)
VARM(get, short,     short,              MPI_SHORT)
VARM(get, ushort,    ushort,             MPI_UNSIGNED_SHORT)
VARM(get, int,       int,                MPI_INT)
VARM(get, uint,      uint,               MPI_UNSIGNED)
VARM(get, long,      long,               MPI_LONG)
VARM(get, float,     float,              MPI_FLOAT)
VARM(get, double,    double,             MPI_DOUBLE)
VARM(get, longlong,  long long,          MPI_LONG_LONG_INT)
VARM(get, ulonglong, unsigned long long, MPI_UNSIGNED_LONG_LONG)

/*----< ncmpii_abuf_malloc() >------------------------------------------------*/
/* allocate memory space from the attached buffer pool */
static int
ncmpii_abuf_malloc(NC *ncp, MPI_Offset nbytes, void **buf, int *abuf_index)
{
    /* extend the table size if more entries are needed */
    if (ncp->abuf->tail + 1 == ncp->abuf->table_size) {
        ncp->abuf->table_size += NC_ABUF_DEFAULT_TABLE_SIZE;
        ncp->abuf->occupy_table = (NC_buf_status*)
                   NCI_Realloc(ncp->abuf->occupy_table,
                               (size_t)ncp->abuf->table_size * sizeof(NC_buf_status));
    }
    /* mark the new entry is used and store the requested buffer size */
    ncp->abuf->occupy_table[ncp->abuf->tail].is_used  = 1;
    ncp->abuf->occupy_table[ncp->abuf->tail].req_size = nbytes;
    *abuf_index = ncp->abuf->tail;

    *buf = (char*)ncp->abuf->buf + ncp->abuf->size_used;
    ncp->abuf->size_used += nbytes;
    ncp->abuf->tail++;

    return NC_NOERR;
}

/*----< ncmpii_igetput_varm() >-----------------------------------------------*/
int
ncmpii_igetput_varm(NC               *ncp,
                    NC_var           *varp,
                    const MPI_Offset  start[],
                    const MPI_Offset  count[],
                    const MPI_Offset  stride[],
                    const MPI_Offset  imap[],
                    void             *buf,      /* user buffer */
                    MPI_Offset        bufcount,
                    MPI_Datatype      buftype,
                    int              *reqid,    /* out, can be NULL */
                    int               rw_flag,
                    int               use_abuf,    /* if use attached buffer */
                    int               isSameGroup) /* if part of a varn group */
{
    void *xbuf=NULL, *cbuf=NULL, *lbuf=NULL;
    int err=NC_NOERR, status=NC_NOERR, warning=NC_NOERR;
    int i, abuf_index=-1, el_size, buftype_is_contig;
    int need_convert, need_swap, need_swap_back_buf=0;
    MPI_Offset bnelems=0, nbytes;
    MPI_Datatype ptype, imaptype=MPI_DATATYPE_NULL;
    NC_req *req;

    /* check NC_ECHAR error and calculate the followings:
     * ptype: element data type (MPI primitive type) in buftype
     * bufcount: If it is -1, then this is called from a high-level API and in
     * this case buftype will be an MPI primitive data type. If not, then this
     * is called from a flexible API. In that case, we recalculate bufcount to
     * match with count[].
     * bnelems: number of ptypes in user buffer
     * nbytes: number of bytes (in external data representation) to read/write
     * from/to the file
     * el_size: size of ptype
     * buftype_is_contig: whether buftype is contiguous
     */
    err = ncmpii_calc_datatype_elems(ncp, varp, start, count, stride, rw_flag,
                                     buftype, &ptype, &bufcount, &bnelems,
                                     &nbytes, &el_size, &buftype_is_contig);
    if (err == NC_EIOMISMATCH) DEBUG_ASSIGN_ERROR(warning, err)
    else if (err != NC_NOERR) return err;

    if (bnelems == 0) {
        /* zero-length request, mark this as a NULL request */
        if (!isSameGroup && reqid != NULL)
            /* only if this is not part of a group request */
            *reqid = NC_REQ_NULL;
        return ((warning != NC_NOERR) ? warning : NC_NOERR);
    }

    /* for bput call, check if the remaining buffer space is sufficient
     * to accommodate this request
     */
    if (rw_flag == WRITE_REQ && use_abuf &&
        ncp->abuf->size_allocated - ncp->abuf->size_used < nbytes)
        DEBUG_RETURN_ERROR(NC_EINSUFFBUF)

    /* check if type conversion and Endianness byte swap is needed */
    need_convert = ncmpii_need_convert(varp->type, ptype);
    need_swap    = ncmpii_need_swap(varp->type, ptype);

    /* check whether this is a true varm call, if yes, imaptype will be a
     * newly created MPI derived data type, otherwise MPI_DATATYPE_NULL
     */
    err = ncmpii_create_imaptype(varp, count, imap, bnelems, el_size, ptype,
                                 &imaptype);
    if (err != NC_NOERR) return err;

    if (rw_flag == WRITE_REQ) { /* pack request to xbuf */
        int position, abuf_allocated=0;
        MPI_Offset outsize=bnelems*el_size;
        /* assert(bnelems > 0); */
        if (outsize != (int)outsize) DEBUG_RETURN_ERROR(NC_EINTOVERFLOW)

        /* attached buffer allocation logic
         * if (use_abuf)
         *     if contig && no imap && no convert
         *         buf   ==   lbuf   ==   cbuf    ==     xbuf memcpy-> abuf
         *                                               abuf
         *     if contig && no imap &&    convert
         *         buf   ==   lbuf   ==   cbuf convert-> xbuf == abuf
         *                                               abuf
         *     if contig &&    imap && no convert
         *         buf   ==   lbuf pack-> cbuf    ==     xbuf == abuf
         *                                abuf
         *     if contig &&    imap &&    convert
         *         buf   ==   lbuf pack-> cbuf convert-> xbuf == abuf
         *                                               abuf
         *  if noncontig && no imap && no convert
         *         buf pack-> lbuf   ==   cbuf    ==     xbuf == abuf
         *                    abuf
         *  if noncontig && no imap &&    convert
         *         buf pack-> lbuf   ==   cbuf convert-> xbuf == abuf
         *                                               abuf
         *  if noncontig &&    imap && no convert
         *         buf pack-> lbuf pack-> cbuf    ==     xbuf == abuf
         *                                abuf
         *  if noncontig &&    imap &&    convert
         *         buf pack-> lbuf pack-> cbuf convert-> xbuf == abuf
         *                                               abuf
         */

        /* Step 1: pack buf into a contiguous buffer, lbuf, if buftype is
         * not contiguous
         */
        if (!buftype_is_contig) { /* buftype is not contiguous */
            /* allocate lbuf */
            if (use_abuf && imaptype == MPI_DATATYPE_NULL && !need_convert) {
                status = ncmpii_abuf_malloc(ncp, nbytes, &lbuf, &abuf_index);
                if (status != NC_NOERR) return status;
                abuf_allocated = 1;
            }
            else lbuf = NCI_Malloc((size_t)outsize);

            if (bufcount != (int)bufcount) DEBUG_RETURN_ERROR(NC_EINTOVERFLOW)

            /* pack buf into lbuf using buftype */
            position = 0;
            MPI_Pack(buf, (int)bufcount, buftype, lbuf, (int)outsize,
                     &position, MPI_COMM_SELF);
        }
        else /* for contiguous case, we reuse buf */
            lbuf = buf;

        /* Step 2: pack lbuf to cbuf if imap is non-contiguous */
        if (imaptype != MPI_DATATYPE_NULL) { /* true varm */
            /* allocate cbuf */
            if (use_abuf && !need_convert) {
                assert(abuf_allocated == 0);
                status = ncmpii_abuf_malloc(ncp, nbytes, &cbuf, &abuf_index);
                if (status != NC_NOERR) {
                    if (lbuf != buf) NCI_Free(lbuf);
                    return status;
                }
                abuf_allocated = 1;
            }
            else cbuf = NCI_Malloc((size_t)outsize);

            /* pack lbuf to cbuf using imaptype */
            position = 0;
            MPI_Pack(lbuf, 1, imaptype, cbuf, (int)outsize, &position,
                     MPI_COMM_SELF);
            MPI_Type_free(&imaptype);
        }
        else /* not a true varm call: reuse lbuf */
            cbuf = lbuf;

        /* lbuf is no longer needed */
        if (lbuf != buf && lbuf != cbuf) NCI_Free(lbuf);

        /* Step 3: type-convert and byte-swap cbuf to xbuf, and xbuf will be
         * used in MPI write function to write to file
         */

        /* when user buf type != nc var type defined in file */
        if (need_convert) {
            if (use_abuf) { /* use attached buffer to allocate xbuf */
                assert(abuf_allocated == 0);
                status = ncmpii_abuf_malloc(ncp, nbytes, &xbuf, &abuf_index);
                if (status != NC_NOERR) {
                    if (cbuf != buf) NCI_Free(cbuf);
                    return status;
                }
                abuf_allocated = 1;
            }
            else xbuf = NCI_Malloc((size_t)nbytes);

            /* datatype conversion + byte-swap from cbuf to xbuf */
            DATATYPE_PUT_CONVERT(varp->type, xbuf, cbuf, bnelems, ptype, status)
            /* NC_ERANGE can be caused by a subset of buf that is out of range
             * of the external data type, it is not considered a fatal error.
             * The request must continue to finish.
             */
            if (status != NC_NOERR && status != NC_ERANGE) {
                if (cbuf != buf)  NCI_Free(cbuf);
                if (xbuf != NULL) NCI_Free(xbuf);
                return status;
            }
        }
        else {
            if (use_abuf && buftype_is_contig && imaptype == MPI_DATATYPE_NULL){
                assert(abuf_allocated == 0);
                status = ncmpii_abuf_malloc(ncp, nbytes, &xbuf, &abuf_index);
                if (status != NC_NOERR) {
                    if (cbuf != buf) NCI_Free(cbuf);
                    return status;
                }
                memcpy(xbuf, cbuf, (size_t)nbytes);
            }
            else xbuf = cbuf;

            if (need_swap) {
#ifdef DISABLE_IN_PLACE_SWAP
                if (xbuf == buf) {
#else
                if (xbuf == buf && nbytes <= NC_BYTE_SWAP_BUFFER_SIZE) {
#endif
                    /* allocate xbuf and copy buf to xbuf, before byte-swap */
                    xbuf = NCI_Malloc((size_t)nbytes);
                    memcpy(xbuf, buf, (size_t)nbytes);
                }
                /* perform array in-place byte swap on xbuf */
                ncmpii_in_swapn(xbuf, bnelems, ncmpix_len_nctype(varp->type));

                if (xbuf == buf) need_swap_back_buf = 1;
                /* user buf needs to be swapped back to its original contents */
            }
        }
        /* cbuf is no longer needed */
        if (cbuf != buf && cbuf != xbuf) NCI_Free(cbuf);
    }
    else { /* rw_flag == READ_REQ */
        /* Type conversion and byte swap for read are done at wait call, we
         * need bnelems to reverse the steps as done in write case
         */
        if (buftype_is_contig && imaptype == MPI_DATATYPE_NULL && !need_convert)
            xbuf = buf;  /* there is no buffered read (bget_var, etc.) */
        else
            xbuf = NCI_Malloc((size_t)nbytes);
    }

    /* allocate a new request object to store the write info */
    req = (NC_req*) NCI_Malloc(sizeof(NC_req));

    req->buf                = buf;
    req->xbuf               = xbuf;
    req->bnelems            = bnelems;
    req->bufcount           = bufcount;
    req->ptype              = ptype;
    req->buftype_is_contig  = buftype_is_contig;
    req->need_swap_back_buf = need_swap_back_buf;
    req->imaptype           = imaptype;
    req->rw_flag            = rw_flag;
    req->abuf_index         = abuf_index;
    req->tmpBuf             = NULL;
    req->userBuf            = NULL;

    /* only when read and buftype is not contiguous, we duplicate buftype for
     * later in the wait call to unpack buffer based on buftype
     */
    if (rw_flag == READ_REQ && !buftype_is_contig)
        MPI_Type_dup(buftype, &req->buftype);
    else
        req->buftype = MPI_DATATYPE_NULL;

    pack_request(ncp, varp, req, start, count, stride);

    /* add the new request to the internal request array (or linked list) */
    if (ncp->head == NULL) {
        req->id   = 0;
        ncp->head = req;
        ncp->tail = ncp->head;
    }
    else { /* add to the tail */
        if (!isSameGroup)
            req->id = ncp->tail->id + 1;
        else if (reqid != NULL)
            req->id = *reqid;
        ncp->tail->next = req;
        ncp->tail = req;
    }
    for (i=0; i<req->num_subreqs; i++)
        req->subreqs[i].id = req->id;

    /* return the request ID */
    if (reqid != NULL) *reqid = req->id;

    return ((warning != NC_NOERR) ? warning : status);
}

/*----< pack_request() >------------------------------------------------------*/
/* if this request is for a record variable, then we break this request into
 * sub-requests, each for a record
 */
static int
pack_request(NC               *ncp,
             NC_var           *varp,
             NC_req           *req,
             const MPI_Offset  start[],
             const MPI_Offset  count[],
             const MPI_Offset  stride[])
{
    int     i, j;
    size_t  dims_chunk;
    NC_req *subreqs;

    dims_chunk       = (size_t)varp->ndims * SIZEOF_MPI_OFFSET;

    req->varp        = varp;
    req->next        = NULL;
    req->subreqs     = NULL;
    req->num_subreqs = 0;

    if (stride != NULL)
        req->start = (MPI_Offset*) NCI_Malloc(dims_chunk*3);
    else
        req->start = (MPI_Offset*) NCI_Malloc(dims_chunk*2);

    req->count = req->start + varp->ndims;

    if (stride != NULL)
        req->stride = req->count + varp->ndims;
    else
        req->stride = NULL;

    for (i=0; i<varp->ndims; i++) {
        req->start[i] = start[i];
        req->count[i] = count[i];
        if (stride != NULL)
            req->stride[i] = stride[i];
    }

#ifdef _DISALLOW_POST_NONBLOCKING_API_IN_DEFINE_MODE
    /* move the offset calculation to wait time (ncmpii_wait_getput),
     * such that posting a nonblocking request can be done in define
     * mode
     */

    /* get the starting file offset for this request */
    ncmpii_get_offset(ncp, varp, start, NULL, NULL, req->rw_flag,
                      &req->offset_start);

    /* get the ending file offset for this request */
    ncmpii_get_offset(ncp, varp, start, count, stride, req->rw_flag,
                      &req->offset_end);
    req->offset_end += varp->xsz - 1;
#endif

    /* check if this is a record variable. if yes, split the request into
     * subrequests, one subrequest for a record access. Hereinafter,
     * treat each request as a non-record variable request
     */

    /* check if this access is within one record, if yes, no need to create
       subrequests */
    if (IS_RECVAR(varp) && req->count[0] > 1) {
        MPI_Offset rec_bufcount = 1;
        for (i=1; i<varp->ndims; i++)
            rec_bufcount *= req->count[i];

        subreqs = (NC_req*) NCI_Malloc((size_t)req->count[0]*sizeof(NC_req));
        for (i=0; i<req->count[0]; i++) {
            MPI_Offset span;
            subreqs[i] = *req; /* inherit most attributes from req */

            /* each sub-request contains <= one record size */
            if (stride != NULL)
                subreqs[i].start = (MPI_Offset*) NCI_Malloc(dims_chunk*3);
            else
                subreqs[i].start = (MPI_Offset*) NCI_Malloc(dims_chunk*2);

            subreqs[i].count = subreqs[i].start + varp->ndims;

            if (stride != NULL) {
                subreqs[i].stride = subreqs[i].count + varp->ndims;
                subreqs[i].start[0] = req->start[0] + stride[0] * i;
                subreqs[i].stride[0] = req->stride[0];
            } else {
                subreqs[i].stride = NULL;
                subreqs[i].start[0] = req->start[0] + i;
            }

            subreqs[i].count[0] = 1;
            subreqs[i].bnelems = 1;
            for (j=1; j<varp->ndims; j++) {
                subreqs[i].start[j]  = req->start[j];
                subreqs[i].count[j]  = req->count[j];
                subreqs[i].bnelems  *= subreqs[i].count[j];
                if (stride != NULL)
                    subreqs[i].stride[j] = req->stride[j];
            }

#ifdef _DISALLOW_POST_NONBLOCKING_API_IN_DEFINE_MODE
            /* move the offset calculation to wait time (ncmpii_wait_getput),
             * such that posting a nonblocking request can be done in define
             * mode
             */
            ncmpii_get_offset(ncp, varp, subreqs[i].start, NULL, NULL,
                              subreqs[i].rw_flag, &subreqs[i].offset_start);
            ncmpii_get_offset(ncp, varp, subreqs[i].start,
                              subreqs[i].count, subreqs[i].stride,
                              subreqs[i].rw_flag, &subreqs[i].offset_end);
            subreqs[i].offset_end += varp->xsz - 1;
#endif
            span                = i*rec_bufcount*varp->xsz;
            subreqs[i].buf      = (char*)(req->buf)  + span;
            /* xbuf cannot be NULL    assert(req->xbuf != NULL); */
            subreqs[i].xbuf     = (char*)(req->xbuf) + span;
            subreqs[i].bufcount = rec_bufcount;
        }
        req->num_subreqs = (int)req->count[0];
        req->subreqs     = subreqs;

        if (req->count[0] != (int)req->count[0])
            DEBUG_RETURN_ERROR(NC_EINTOVERFLOW)
    }

    return NC_NOERR;
}

