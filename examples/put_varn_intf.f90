!
!   Copyright (C) 2013, Northwestern University
!   See COPYRIGHT notice in top-level directory.
!
! $Id$

! This example shows how to use a single call of nfmpi_put_varn_int_all() to
! write a sequence of requests with arbitrary array indices and lengths.
! Using nfmpi_put_varn_int_all() can achieve the same effect of HDF5 writing
! a sequence of selected file locations through the following 2 APIs.
!
!   H5Sselect_elements(fid, H5S_SELECT_SET, NUMP, (const hssize_t **)coord);
!   H5Dwrite(dataset, H5T_NATIVE_INT, mid, fid, H5P_DEFAULT, val); 
!
! Note that in nfmpi_put_varn_int_all(), users can write more than one element
! starting at each selected location.
!
! The compile and run commands are given below, together with an ncmpidump of
! the output file.
!
!    % mpif90 -g -o put_varn_intf put_varn_intf.f90 -lpnetcdf
!    % mpiexec -l -n 4 put_varn_intf testfile.nc
!    % ncmpidump testfile.nc
!    netcdf testfile {
!    // file format: CDF-5 (big variables)
!    dimensions:
!             X = 4 ;
!             Y = 10 ;
!    variables:
!             int var(Y, X) ;
!    data:
!
!     var =
!      2, 2, 1, 1,
!      2, 2, 0, 0,
!      1, 1, 0, 0,
!      1, 1, 3, 3,
!      3, 3, 2, 2,
!      0, 0, 1, 1,
!      0, 0, 1, 1,
!      2, 2, 0, 0,
!      3, 3, 3, 3,
!      3, 3, 3, 3 ;
!    }
!
!    Note the above dump is in C order
!
      subroutine check(err, message)
          use mpi
          use pnetcdf
          implicit none
          integer err
          character(len=*) message

          ! It is a good idea to check returned value for possible error
          if (err .NE. NF_NOERR) then
              write(6,*) trim(message), trim(nfmpi_strerror(err))
              call MPI_Abort(MPI_COMM_WORLD, -1, err)
          end if
      end subroutine check

      program main
          use mpi
          use pnetcdf
          implicit none

          integer NDIMS
          integer(kind=MPI_OFFSET_KIND) NX, NY
          PARAMETER(NDIMS=2, NX=4, NY=10)

          character(LEN=128) filename
          integer i, j, argc, IARGC, err, nprocs, rank
          integer cmode, ncid, varid, dimid(NDIMS), num_reqs

          integer(kind=MPI_OFFSET_KIND) w_len, w_req_len
          integer(kind=MPI_OFFSET_KIND), allocatable :: starts(:,:)
          integer(kind=MPI_OFFSET_KIND), allocatable :: counts(:,:)
          integer, allocatable :: buffer(:)

          call MPI_Init(err)
          call MPI_Comm_rank(MPI_COMM_WORLD, rank, err)
          call MPI_Comm_size(MPI_COMM_WORLD, nprocs, err)

          ! take filename from command-line argument if there is any
          argc = IARGC()
          if (argc .GE. 1) then
              call getarg(1, filename)
          else
              filename  = 'testfile.nc'
          endif

          ! create file, truncate it if exists
          cmode = IOR(NF_CLOBBER, NF_64BIT_DATA)
          err = nfmpi_create(MPI_COMM_WORLD, filename, cmode, &
                              MPI_INFO_NULL, ncid)
          call check(err, 'In nfmpi_create: ')

          ! define dimensions x and y
          err = nfmpi_def_dim(ncid, "X", NX, dimid(1))
          call check(err, 'In nfmpi_def_dim X: ')
          err = nfmpi_def_dim(ncid, "Y", NY, dimid(2))
          call check(err, 'In nfmpi_def_dim Y: ')

          ! define a 2D variable of integer type
          err = nfmpi_def_var(ncid, "var", NF_INT, NDIMS, dimid, varid)
          call check(err, 'In nfmpi_def_var: ')

          ! do not forget to exit define mode
          err = nfmpi_enddef(ncid)
          call check(err, 'In nfmpi_enddef: ')

          ! now we are in data mode

          ! pick arbitrary numbers of requests for 4 processes
          num_reqs = 1
          if (rank .EQ. 0) then
              num_reqs = 3
          elseif (rank .EQ. 1) then
              num_reqs = 3;
          elseif (rank .EQ. 2) then
              num_reqs = 3;
          elseif (rank .EQ. 3) then
              num_reqs = 3;
          endif

          ! Note that in Fortran, array indices start with 1
          ALLOCATE(starts(NDIMS, num_reqs))
          ALLOCATE(counts(NDIMS, num_reqs))

          ! assign arbitrary starts and counts
          if (rank .EQ. 0) then
              ! rank 0 is writing the followings: ("-" means skip)
              !        -  -  -  -  -  0  0  -  -  - 
              !        -  -  -  -  -  0  0  -  -  - 
              !        -  0  0  -  -  -  -  0  -  - 
              !        -  0  0  -  -  -  -  0  -  - 
              ! Note this is in Fortran order
              starts(1, 1) = 1
              starts(2, 1) = 6
              counts(1, 1) = 2
              counts(2, 1) = 2
              starts(1, 2) = 3
              starts(2, 2) = 2
              counts(1, 2) = 2
              counts(2, 2) = 2
              starts(1, 3) = 3
              starts(2, 3) = 8
              counts(1, 3) = 2
              counts(2, 3) = 1
          elseif (rank .EQ. 1) then
              ! rank 1 is writing the followings: ("-" means skip)
              !        -  -  1  1  -  -  -  -  -  - 
              !        -  -  1  1  -  -  -  -  -  - 
              !        1  -  -  -  -  1  1  -  -  - 
              !        1  -  -  -  -  1  1  -  -  - 
              ! Note this is in Fortran order
              starts(1, 1) = 1
              starts(2, 1) = 3
              counts(1, 1) = 2
              counts(2, 1) = 2
              starts(1, 2) = 3
              starts(2, 2) = 1
              counts(1, 2) = 2
              counts(2, 2) = 1
              starts(1, 3) = 3
              starts(2, 3) = 6
              counts(1, 3) = 2
              counts(2, 3) = 2
          elseif (rank .EQ. 2) then
              ! rank 2 is writing the followings: ("-" means skip)
              !        2  2  -  -  -  -  -  2  -  - 
              !        2  2  -  -  -  -  -  2  -  - 
              !        -  -  -  -  2  -  -  -  -  - 
              !        -  -  -  -  2  -  -  -  -  - 
              ! Note this is in Fortran order
              starts(1, 1) = 1
              starts(2, 1) = 1
              counts(1, 1) = 2
              counts(2, 1) = 2
              starts(1, 2) = 1
              starts(2, 2) = 8
              counts(1, 2) = 2
              counts(2, 2) = 1
              starts(1, 3) = 3
              starts(2, 3) = 5
              counts(1, 3) = 2
              counts(2, 3) = 1
          elseif (rank .EQ. 3) then
              ! rank 3 is writing the followings: ("-" means skip)
              !        -  -  -  -  3  -  -  -  3  3 
              !        -  -  -  -  3  -  -  -  3  3 
              !        -  -  -  3  -  -  -  -  3  3 
              !        -  -  -  3  -  -  -  -  3  3 
              ! Note this is in Fortran order
              starts(1, 1) = 1
              starts(2, 1) = 5
              counts(1, 1) = 2
              counts(2, 1) = 1
              starts(1, 2) = 1
              starts(2, 2) = 9
              counts(1, 2) = 4
              counts(2, 2) = 2
              starts(1, 3) = 3
              starts(2, 3) = 4
              counts(1, 3) = 2
              counts(2, 3) = 1
          endif
 
          ! w_len is total write length for this process
          w_len = 0
          do i=1, num_reqs
             w_req_len = 1
             do j=1, NDIMS
                w_req_len = w_req_len * counts(j, i)
             enddo
             w_len = w_len + w_req_len;
          enddo
          ALLOCATE(buffer(w_len))

          ! initialize buffer contents
          buffer = rank;

          err = nfmpi_put_varn_int_all(ncid, varid, num_reqs, starts, &
                                       counts, buffer)
          call check(err, 'In nfmpi_put_varn_int_all: ')

          ! close the file
          err = nfmpi_close(ncid)
          call check(err, 'In nfmpi_close: ')

          DEALLOCATE(buffer);
          DEALLOCATE(starts);
          DEALLOCATE(counts);

          call MPI_Finalize(err)
      end program main
