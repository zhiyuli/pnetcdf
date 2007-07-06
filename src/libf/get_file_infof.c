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
#define nfmpi_get_file_info_ NFMPI_GET_FILE_INFO
#elif defined(F77_NAME_LOWER_2USCORE)
#define nfmpi_get_file_info_ nfmpi_get_file_info__
#elif !defined(F77_NAME_LOWER_USCORE)
#define nfmpi_get_file_info_ nfmpi_get_file_info
/* Else leave name alone */
#endif


/* Prototypes for the Fortran interfaces */
#include "mpifnetcdf.h"
FORTRAN_API int FORT_CALL nfmpi_get_file_info_ ( int *v1, MPI_Fint *v2 ){
    int ierr;
    ierr = ncmpi_get_file_info( *v1, (fixme][)(v2) );
    return ierr;
}
