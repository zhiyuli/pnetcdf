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
#define nfmpi_put_vars_text_ NFMPI_PUT_VARS_TEXT
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_put_vars_text_ nfmpi_put_vars_text__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_put_vars_text_ nfmpi_put_vars_text
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API void FORT_CALL nfmpi_put_vars_text_ ( int *v1, int *v2, size_t v3[], size_t v4[], size_t v5[], char *v6 FORT_MIXED_LEN(d6), MPI_Fint *ierr FORT_END_LEN(d6) ){
    char *p6;

    {char *p = v6 + d6 - 1;
     int  li;
        while (*p == ' ' && p > v6) p--;
        p++;
        p6 = (char *)malloc( p-v6 + 1 );
        for (li=0; li<(p-v6); li++) { p6[li] = v6[li]; }
        p6[li] = 0; 
    }
    *ierr = ncmpi_put_vars_text( *v1, *v2, (const size_t *)(v3), (const size_t *)(v4), (const size_t *)(v5), p6 );
    free( p6 );
}
