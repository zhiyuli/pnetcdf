/* -*- Mode: C; c-basic-offset:4 ; -*- */
/*  
 *  (C) 2001 by Argonne National Laboratory.
 *      See COPYRIGHT in top-level directory.
 *
 * This file is automatically generated by buildiface -infile=../lib/pnetcdf.h -deffile=defs
 * DO NOT EDIT
 */
#include "mpinetcdf_impl.h"


#ifdef F77_NAME_UPPER
#define nfmpi_inq_attlen_ NFMPI_INQ_ATTLEN
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_inq_attlen_ nfmpi_inq_attlen__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_inq_attlen_ nfmpi_inq_attlen
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API void FORT_CALL nfmpi_inq_attlen_ ( int *v1, int *v2, char *v3 FORT_MIXED_LEN(d3), int *v4, MPI_Fint *ierr FORT_END_LEN(d3) ){
    int l2 = *v2 - 1;
    char *p3;
    size_t l4=0;

    {char *p = v3 + d3 - 1;
     int  li;
        while (*p == ' ' && p > v3) p--;
        p++;
        p3 = (char *)malloc( p-v3 + 1 );
        for (li=0; li<(p-v3); li++) { p3[li] = v3[li]; }
        p3[li] = 0; 
    }
    *ierr = ncmpi_inq_attlen( *v1, l2, p3, &l4 );
    free( p3 );
    if (!*ierr) *v4 = (int)l4;
}
