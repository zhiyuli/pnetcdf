/*
 *  Copyright (C) 2016, Northwestern University and Argonne National Laboratory
 *  See COPYRIGHT notice in top-level directory.
 *
 *  $Id$
 */

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 * This program is only active when macro ERANGE_FILL is defined.
 * It tests whether the data elemensts is "filled" with "filled values" when
 * their contents (to be read or written) cause NC_ERANGE error.
 *
 * The compile and run commands are given below.
 *
 *    % mpicc -g -o erange_fill.c erange_fill -lpnetcdf
 *
 *    % mpiexec -l -n 1 erange_fill erange_fill.nc
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h> /* basename() */
#include <pnetcdf.h>

#include <testutils.h>

#define LEN 10

#define ERR {if(err!=NC_NOERR){printf("Error at %s line %d: %s\n",__func__,__LINE__, ncmpi_strerror(err)); nerrs++;}}

#define ERR_EXPECT(expect) { \
    if (err != expect) { \
        printf("Error at %s line %d: expect %s but got %s\n", \
               __func__,__LINE__,nc_err_code_name(NC_ERANGE),nc_err_code_name(err)); \
        nerrs++; \
    } \
}

include(`foreach.m4')dnl
include(`utils.m4')dnl

#define text char

#ifndef schar
#define schar signed char
#endif
#ifndef uchar
#define uchar unsigned char
#endif
#ifndef ushort
#define ushort unsigned short
#endif
#ifndef uint
#define uint unsigned int
#endif
#ifndef longlong
#define longlong long long
#endif
#ifndef ulonglong
#define ulonglong unsigned long long
#endif

define(`ITYPE_SIZE',`ifelse(
`$1', `text',      `1',dnl
`$1', `schar',     `1',dnl
`$1', `uchar',     `1',dnl
`$1', `short',     `2',dnl
`$1', `ushort',    `2',dnl
`$1', `int',       `4',dnl
`$1', `long',      `4',dnl
`$1', `uint',      `4',dnl
`$1', `float',     `4',dnl
`$1', `double',    `8',dnl
`$1', `longlong',  `8',dnl
`$1', `ulonglong', `8')')dnl

static
int test_default_fill_mode(char* filename) {
    int err, nerrs=0, ncid, old_mode;
    MPI_Info info=MPI_INFO_NULL;
    MPI_Comm comm=MPI_COMM_WORLD;

    /* create a new file */
    err = ncmpi_create(comm, filename, NC_CLOBBER, info, &ncid); ERR
    err = ncmpi_set_fill(ncid, NC_FILL, &old_mode); ERR
    if (old_mode == NC_FILL) {
        printf("Error at %s line %d: expected NC_NOFILL but got NC_FILL\n",__func__,__LINE__);
        nerrs++;
    }
    err = ncmpi_close(ncid); ERR
    return nerrs;
}

define(`TEST_DEFAULT_FILL',dnl
`dnl
static
int test_default_fill_$1(char* filename) {
    int i, err, nerrs=0, ncid, dimid, omode, varid;
    $1 buf[LEN];
    MPI_Info info=MPI_INFO_NULL;
    MPI_Comm comm=MPI_COMM_WORLD;

    /* create a new file */
    err = ncmpi_create(comm, filename, NC_CLOBBER, info, &ncid); ERR
    err = ncmpi_set_fill(ncid, NC_FILL, NULL); ERR
    err = ncmpi_def_dim(ncid, "X", LEN, &dimid); ERR
    err = ncmpi_def_var(ncid, "var", NC_TYPE($1), 1, &dimid, &varid); ERR
    err = ncmpi_close(ncid); ERR

    /* reopen the file and check the contents of variable */
    omode = NC_NOWRITE;
    err = ncmpi_open(comm, filename, omode, info, &ncid); ERR
    err = ncmpi_inq_varid(ncid, "var", &varid); ERR
    err = GET_VAR($1)(ncid, varid, buf); ERR
    for (i=0; i<LEN; i++) {
        if (buf[i] != NC_FILL_VALUE($1)) {
            printf("Error at %s line %d: expect buf[%d]=IFMT($1) but got IFMT($1)\n",
                   __func__,__LINE__,i,($1)NC_FILL_VALUE($1),buf[i]);
            nerrs++;
        }
    }
    err = ncmpi_close(ncid); ERR
    return nerrs;
}
')dnl

foreach(`itype', (ITYPE_LIST), `TEST_DEFAULT_FILL(itype)')

define(`TEST_USER_FILL',dnl
`dnl
static
int test_user_fill_$1(char* filename, $1 fillv) {
    int i, err, nerrs=0, ncid, dimid, omode, varid;
    $1 buf[LEN];
    MPI_Info info=MPI_INFO_NULL;
    MPI_Comm comm=MPI_COMM_WORLD;

    /* create a new file */
    err = ncmpi_create(comm, filename, NC_CLOBBER, info, &ncid); ERR
    err = ncmpi_def_dim(ncid, "X", LEN, &dimid); ERR
    err = ncmpi_def_var(ncid, "var", NC_TYPE($1), 1, &dimid, &varid); ERR
    err = ncmpi_put_att(ncid, varid, "_FillValue", NC_TYPE($1), 1, &fillv); ERR
    err = ncmpi_close(ncid); ERR

    /* reopen the file and check the contents of variable */
    omode = NC_NOWRITE;
    err = ncmpi_open(comm, filename, omode, info, &ncid); ERR
    err = ncmpi_inq_varid(ncid, "var", &varid); ERR
    err = GET_VAR($1)(ncid, varid, buf); ERR
    for (i=0; i<LEN; i++) {
        if (memcmp(&buf[i], &fillv, ITYPE_SIZE($1))) {
            printf("Error at %s line %d: expect buf[%d]=IFMT($1) but got IFMT($1)\n",
                   __func__,__LINE__,i,($1)fillv,buf[i]);
            nerrs++;
        }
    }
    err = ncmpi_close(ncid); ERR
    return nerrs;
}
')dnl

foreach(`itype', (ITYPE_LIST), `TEST_USER_FILL(itype)')

define(`TEST_ERANGE_PUT',dnl
`dnl
static
int test_erange_put_$1_$2(char* filename) {
    int i, err, nerrs=0, ncid, dimid, omode, varid, cdf;
    $1 buf[LEN];
    MPI_Info info=MPI_INFO_NULL;
    MPI_Comm comm=MPI_COMM_WORLD;

    /* create a new file */
    err = ncmpi_create(comm, filename, NC_CLOBBER, info, &ncid); ERR
    err = ncmpi_set_fill(ncid, NC_FILL, NULL); ERR
    err = ncmpi_def_dim(ncid, "X", LEN, &dimid); ERR
    err = ncmpi_def_var(ncid, "var", NC_TYPE($1), 1, &dimid, &varid); ERR
    err = ncmpi_enddef(ncid); ERR

    err = ncmpi_inq_format(ncid, &cdf); ERR

    /* put data with ERANGE values */
    $2 wbuf[LEN];
    for (i=0; i<LEN; i++) wbuf[i] = ($2) ifelse(index(`$1',`u'), 0, `-1', `XTYPE_MAX($2)');
    err = PUT_VAR($2)(ncid, varid, wbuf);
    ifelse(`$1',`schar',`ifelse(`$2',`uchar',`if (cdf == NC_FORMAT_CDF2) ERR',`ERR_EXPECT(NC_ERANGE)')',`ERR_EXPECT(NC_ERANGE)')

    err = ncmpi_close(ncid); ERR

    /* reopen the file and check the contents of variable */
    omode = NC_NOWRITE;
    err = ncmpi_open(comm, filename, omode, info, &ncid); ERR
    err = ncmpi_inq_varid(ncid, "var", &varid); ERR
    err = GET_VAR($1)(ncid, varid, buf); ERR
    for (i=0; i<LEN; i++) {
        $1 expect = ($1)NC_FILL_VALUE($1);
        ifelse(`$1',`schar',`ifelse(`$2',`uchar',`if (cdf != NC_FORMAT_CDF5) expect = ($1)wbuf[i];')')
        if (buf[i] != expect) {
            printf("Error at %s line %d: expect buf[%d]=IFMT($1) but got IFMT($1)\n",
                   __func__,__LINE__,i,expect,buf[i]);
            nerrs++;
        }
    }
    err = ncmpi_close(ncid); ERR
    return nerrs;
}
')dnl

foreach(`itype',(uchar,short,ushort,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_PUT(schar, itype)')
foreach(`itype',(schar,short,ushort,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_PUT(uchar, itype)')
foreach(`itype',(ushort,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_PUT(short, itype)')
foreach(`itype',(short,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_PUT(ushort, itype)')
foreach(`itype',(uint,float,double,longlong,ulonglong),`TEST_ERANGE_PUT(int, itype)')
foreach(`itype',(int,float,double,longlong,ulonglong),`TEST_ERANGE_PUT(uint, itype)')
TEST_ERANGE_PUT(float, double)

define(`TEST_ERANGE_GET',dnl
`dnl
static
int test_erange_get_$1_$2(char* filename) {
    int i, err, nerrs=0, ncid, dimid, omode, varid, cdf;
    $1 wbuf[LEN];
    MPI_Info info=MPI_INFO_NULL;
    MPI_Comm comm=MPI_COMM_WORLD;

    /* create a new file */
    err = ncmpi_create(comm, filename, NC_CLOBBER, info, &ncid); ERR
    err = ncmpi_def_dim(ncid, "X", LEN, &dimid); ERR
    err = ncmpi_def_var(ncid, "var", NC_TYPE($1), 1, &dimid, &varid); ERR
    err = ncmpi_enddef(ncid); ERR

    err = ncmpi_inq_format(ncid, &cdf); ERR

    /* write MAX values */
    for (i=0; i<LEN; i++)
        wbuf[i] = ($1) ifelse(index(`$1',`u'), 0,`XTYPE_MAX($1)',`ifelse(index(`$2',`u'), 0,`-1', `XTYPE_MAX($1)')');
    err = PUT_VAR($1)(ncid, varid, wbuf); ERR
    err = ncmpi_close(ncid); ERR

    /* reopen the file and check the contents of variable */
    omode = NC_NOWRITE;
    err = ncmpi_open(comm, filename, omode, info, &ncid); ERR
    err = ncmpi_inq_varid(ncid, "var", &varid); ERR

    /* get data with ERANGE values */
    $2 rbuf[LEN];
    err = GET_VAR($2)(ncid, varid, rbuf);
    ifelse(`$1',`schar',`ifelse(`$2',`uchar',`if (cdf == NC_FORMAT_CDF2) ERR',`ERR_EXPECT(NC_ERANGE)')',`ERR_EXPECT(NC_ERANGE)')

    for (i=0; i<LEN; i++) {
        $2 expect = ($2)NC_FILL_VALUE($2);
        ifelse(`$1',`schar',`ifelse(`$2',`uchar',`if (cdf != NC_FORMAT_CDF5) expect = ($2)wbuf[i];')')
        if (rbuf[i] != expect) {
            printf("Error at %s line %d: expect rbuf[%d]=IFMT($2) but got IFMT($2)\n",
                   __func__,__LINE__,i,expect,rbuf[i]);
            nerrs++;
        }
    }
    err = ncmpi_close(ncid); ERR
    return nerrs;
}
')dnl

foreach(`itype',(uchar,short,ushort,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_GET(itype,schar)')
foreach(`itype',(schar,short,ushort,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_GET(itype,uchar)')
foreach(`itype',(ushort,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_GET(itype,short)')
foreach(`itype',(short,int,uint,float,double,longlong,ulonglong),`TEST_ERANGE_GET(itype,ushort)')
foreach(`itype',(uint,float,double,longlong,ulonglong),`TEST_ERANGE_GET(itype,int)')
foreach(`itype',(int,float,double,longlong,ulonglong),`TEST_ERANGE_GET(itype,uint)')
TEST_ERANGE_GET(double, float)

int main(int argc, char** argv) {
    char filename[256];
    int err, nerrs=0, rank, fillv;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (argc > 2) {
        if (!rank) printf("Usage: %s [filename]\n",argv[0]);
        MPI_Finalize();
        return 0;
    }
    if (argc == 2) snprintf(filename, 256, "%s", argv[1]);
    else           strcpy(filename, "testfile.nc");
    MPI_Bcast(filename, 256, MPI_CHAR, 0, MPI_COMM_WORLD);

    if (rank == 0) {
        char *cmd_str = (char*)malloc(strlen(argv[0]) + 256);
        sprintf(cmd_str, "*** TESTING C   %s for checking for type conflict ", basename(argv[0]));
        printf("%-66s ------ ", cmd_str); fflush(stdout);
        free(cmd_str);
    }

    /*---- CDF-2 format -----------------------------------------------------*/
    /* ncmpi_set_default_format(NC_FORMAT_CLASSIC, NULL); */
    ncmpi_set_default_format(NC_FORMAT_CDF2, NULL);

    nerrs += test_default_fill_mode(filename);

    foreach(`itype', (CDF2_ITYPE_LIST), `
    _CAT(`nerrs += test_default_fill_',itype)'`(filename);')

    fillv=99;
    foreach(`itype', (CDF2_ITYPE_LIST), `
    _CAT(`nerrs += test_user_fill_',itype)'`(filename, (itype)fillv);')

    /* test put ERANGE values */
    foreach(`itype', (uchar,short,int,float,double), `
    _CAT(`nerrs += test_erange_put_schar_',itype)'`(filename);')

    foreach(`itype', (ushort,int,uint,float,double), `
    _CAT(`nerrs += test_erange_put_short_',itype)'`(filename);')

    foreach(`itype', (float,double), `
    _CAT(`nerrs += test_erange_put_int_',itype)'`(filename);')

    nerrs += test_erange_put_float_double(filename);

    /* test get ERANGE values */
    foreach(`itype', (short,int,float,double), `
    _CAT(`nerrs += test_erange_get_',itype)'`_schar(filename);')

    foreach(`itype', (schar,short,int,float,double), `
    _CAT(`nerrs += test_erange_get_',itype)'`_uchar(filename);')

    foreach(`itype', (int,float,double), `
    _CAT(`nerrs += test_erange_get_',itype)'`_short(filename);')

    foreach(`itype', (float,double), `
    _CAT(`nerrs += test_erange_get_',itype)'`_int(filename);')

    nerrs += test_erange_get_double_float(filename);

    /*---- CDF-5 format -----------------------------------------------------*/
    ncmpi_set_default_format(NC_FORMAT_CDF5, NULL);

    nerrs += test_default_fill_mode(filename);

    foreach(`itype', (ITYPE_LIST), `
    _CAT(`nerrs += test_default_fill_',itype)'`(filename);')

    fillv=99;
    foreach(`itype', (ITYPE_LIST), `
    _CAT(`nerrs += test_user_fill_',itype)'`(filename, (itype)fillv);')

    /* test put ERANGE values */
    foreach(`itype', (uchar,short,ushort,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_put_schar_',itype)'`(filename);')

    foreach(`itype', (schar,short,ushort,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_put_uchar_',itype)'`(filename);')

    foreach(`itype', (ushort,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_put_short_',itype)'`(filename);')

    foreach(`itype', (short,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_put_ushort_',itype)'`(filename);')

    foreach(`itype', (uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_put_int_',itype)'`(filename);')

    foreach(`itype', (int,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_put_uint_',itype)'`(filename);')

    nerrs += test_erange_put_float_double(filename);

    /* test get ERANGE values */
    foreach(`itype', (uchar,short,ushort,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_get_',itype)'`_schar(filename);')

    foreach(`itype', (schar,short,ushort,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_get_',itype)'`_uchar(filename);')

    foreach(`itype', (ushort,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_get_',itype)'`_short(filename);')

    foreach(`itype', (short,int,uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_get_',itype)'`_ushort(filename);')

    foreach(`itype', (uint,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_get_',itype)'`_int(filename);')

    foreach(`itype', (int,float,double,longlong,ulonglong), `
    _CAT(`nerrs += test_erange_get_',itype)'`_uint(filename);')

    nerrs += test_erange_get_double_float(filename);

    /* check if PnetCDF freed all internal malloc */
    MPI_Offset malloc_size, sum_size;
    err = ncmpi_inq_malloc_size(&malloc_size);
    if (err == NC_NOERR) {
        MPI_Reduce(&malloc_size, &sum_size, 1, MPI_OFFSET, MPI_SUM, 0, MPI_COMM_WORLD);
        if (rank == 0 && sum_size > 0)
            printf("heap memory allocated by PnetCDF internally has %lld bytes yet to be freed\n",
                   sum_size);
    }

    MPI_Allreduce(MPI_IN_PLACE, &nerrs, 1, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    if (rank == 0) {
        if (nerrs) printf(FAIL_STR,nerrs);
        else       printf(PASS_STR);
    }

    MPI_Finalize();
    return 0;
}

