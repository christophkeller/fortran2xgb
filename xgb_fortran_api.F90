module xgb_fortran_api
! This module contains Fortran interfaces for the XGBoost C API
! This API does not cover all functions of the XGBoost C API. It
! currently covers functions to read a previously trained XGBoost
! model (e.g. trained in Python) from a binary file, and then make
! a prediction using input values defined either on-the-fly or read
! from binary file.
! See xgboost_test.F90 for an example on how to use it within a
! Fortran program.
!  
! History:
! 2019-10-09 - christoph.a.keller@nasa.gov - Initial version
! ----------------------------------------------------------------------------
 use iso_c_binding
 implicit none

interface
  integer(kind=c_int) function XGBoosterLoadModel_c(handle, fname) bind(C, name="XGBoosterLoadModel")
   use iso_c_binding, only: c_int, c_char, c_ptr
   type(c_ptr), value                          :: handle ! BoosterHandle
   character(len=1, kind=c_char), dimension(*) :: fname
  end function
end interface

interface
  integer(c_int) function XGBoosterSaveModel_c(handle, fname) bind(C, name="XGBoosterSaveModel")
   use iso_c_binding, only: c_int, c_ptr, c_char
   type(c_ptr), value                          :: handle ! BoosterHandle
   character(len=1, kind=c_char), dimension(*) :: fname
  end function
end interface

interface
  integer(kind=c_int) function XGDMatrixSaveBinary_c(handle, fname, silent) bind(C, name="XGDMatrixSaveBinary")
   use iso_c_binding, only: c_int, c_char, c_ptr
   type(c_ptr), value                          :: handle ! DMatrixHandle 
   character(len=1, kind=c_char), dimension(*) :: fname
   integer(kind=c_int), value                  :: silent
  end function
end interface

interface
  integer(kind=c_int) function XGDMatrixCreateFromFile_c(fname, silent, handle) bind(C, name="XGDMatrixCreateFromFile")
   use iso_c_binding, only: c_int, c_char, c_ptr
   character(len=1, kind=c_char), dimension(*) :: fname
   integer(kind=c_int), value                  :: silent
   type(c_ptr)                                 :: handle ! DMatrixHandle 
  end function
end interface

interface
  integer(c_int) function XGBoosterPredict_f(handle, dmat, option_mask, ntree_limit, length, prediction) &
        bind(C, name="XGBoosterPredict")
   use iso_c_binding, only: c_int, c_ptr, c_int64_t, c_float, c_double
   type(c_ptr), value        :: handle       ! BoosterHandle
   type(c_ptr), value        :: dmat         ! DMatrixHandle
   integer(c_int), value     :: option_mask  ! option mask
   integer(c_int), value     :: ntree_limit  ! limit number of trees in the prediction
   integer(c_int64_t)        :: length       ! length of prediction
   type(c_ptr)               :: prediction   ! prediction
  end function
end interface

interface
   integer(c_int) function XGBoosterCreate_f(dmats, len, out) &
         bind(c, name="XGBoosterCreate")
      use iso_c_binding, only: c_int, c_ptr, c_int64_t
      type(c_ptr), value        :: dmats ! DMatrixHandle
      integer(c_int64_t), value :: len
      type(c_ptr)               :: out ! BoosterHandle*
   end function
end interface

interface
   integer(c_int) function XGDMatrixCreateFromMat_f(data, nrow, ncol, missing, out) &
         bind(c, name="XGDMatrixCreateFromMat")
      use iso_c_binding, only: c_int, c_ptr, c_float, c_double, c_int64_t
      real(c_float)             :: data(*)
      integer(c_int64_t), value :: nrow
      integer(c_int64_t), value :: ncol
      real(c_float), value      :: missing
      type(c_ptr)               :: out ! DMatrixHandle*
   end function
end interface

interface
   integer(c_int) function XGDMatrixNumRow_f(handle, out) &
         bind(c, name="XGDMatrixNumRow")
      use iso_c_binding, only: c_int, c_ptr, c_int64_t
      type(c_ptr), value :: handle ! DMatrixHandle
      integer(c_int64_t) :: out    ! bst_ulong*
   end function
end interface

interface
   integer(c_int) function XGDMatrixNumCol_f(handle, out) &
         bind(c, name="XGDMatrixNumCol")
      use iso_c_binding, only: c_int, c_ptr, c_int64_t
      type(c_ptr), value :: handle ! DMatrixHandle
      integer(c_int64_t) :: out    ! bst_ulong*
   end function
end interface

interface
   integer(c_int) function XGBoosterFree_f(handle) bind(c, name="XGBoosterFree")
      use iso_c_binding, only: c_int, c_ptr
      type(c_ptr), value :: handle ! BoosterHandle
   end function
end interface
 
contains
  integer(kind=c_int) function XGBoosterLoadModel_f(handle, fname) result(rc) 
   use iso_c_binding, only: c_int, c_char, c_ptr, c_null_char
   type(c_ptr)                  :: handle ! BoosterHandle
   character(len=*)             :: fname
   character(len=:),allocatable :: cname
   ! starts here
   cname = trim(fname)//c_null_char
   rc = XGBoosterLoadModel_c(handle, cname)
  end function

  integer(kind=c_int) function XGBoosterSaveModel_f(handle, fname) result(rc) 
   use iso_c_binding, only: c_int, c_char, c_ptr, c_null_char
   type(c_ptr)                  :: handle ! BoosterHandle
   character(len=*)             :: fname
   character(len=:),allocatable :: cname
   ! starts here
   cname = trim(fname)//c_null_char
   rc = XGBoosterSaveModel_c(handle, cname)
  end function

  integer(kind=c_int) function XGDMatrixSaveBinary_f(handle, fname, silent) result(rc)
   use iso_c_binding, only: c_int, c_char, c_ptr, c_null_char
   type(c_ptr)                  :: handle ! DMatrixHandle
   character(len=*)             :: fname
   integer(kind=c_int)          :: silent
   character(len=:),allocatable :: cname
   ! starts here
   cname = trim(fname)//c_null_char
   rc = XGDMatrixSaveBinary_c(handle, cname, silent)
  end function

  integer(kind=c_int) function XGDMatrixCreateFromFile_f(fname, silent, handle) result(rc)
   use iso_c_binding, only: c_int, c_char, c_ptr, c_null_char
   character(len=*)             :: fname
   integer(kind=c_int)          :: silent
   type(c_ptr)                  :: handle ! DMatrixHandle 
   character(len=:),allocatable :: cname
   ! starts here
   cname = trim(fname)//c_null_char
   rc = XGDMatrixCreateFromFile_c(cname, silent, handle)
  end function

end module
