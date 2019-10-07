module fortran_api
! contains the Fortran interfaces for the XGBoost C functions
 use iso_c_binding
 implicit none

interface
  integer(kind=c_int) function XGBoosterLoadModel_c(handle, fname) bind(C, name="XGBoosterLoadModel")
   use iso_c_binding, only: c_int, c_char, c_ptr
   type(c_ptr), value :: handle ! BoosterHandle
   !character(kind=c_char) :: fname(*)
   character(len=1, kind=c_char), dimension(*) :: fname
  end function
end interface

interface
  integer(c_int) function XGBoosterSaveModel_c(handle, fname) bind(C, name="XGBoosterSaveModel")
   use iso_c_binding, only: c_int, c_ptr, c_char
   type(c_ptr), value :: handle ! BoosterHandle
   character(len=1, kind=c_char), dimension(*) :: fname
  end function
end interface

interface
  integer(kind=c_int) function XGDMatrixSaveBinary_c(handle, fname, silent) bind(C, name="XGDMatrixSaveBinary")
   use iso_c_binding, only: c_int, c_char, c_ptr
   type(c_ptr), value :: handle ! DMatrixHandle 
   character(len=1, kind=c_char), dimension(*) :: fname
   integer(kind=c_int), value :: silent
  end function
end interface

interface
  integer(kind=c_int) function XGDMatrixCreateFromFile_c(fname, silent, handle) bind(C, name="XGDMatrixCreateFromFile")
   use iso_c_binding, only: c_int, c_char, c_ptr
   character(len=1, kind=c_char), dimension(*) :: fname
   integer(kind=c_int), value :: silent
   type(c_ptr)        :: handle ! DMatrixHandle 
  end function
end interface

interface
  integer(c_int) function XGBoosterPredict_f(handle, dmat, option_mask, ntree_limit, length, prediction) &
        bind(C, name="XGBoosterPredict")
   use iso_c_binding, only: c_int, c_ptr, c_int64_t, c_float

   type(c_ptr), value          :: handle ! BoosterHandle
   type(c_ptr), value          :: dmat   ! DMatrixHandle
   integer(c_int64_t), value   :: option_mask  ! option mask
   integer(c_int64_t), value   :: ntree_limit  ! limit number of trees in the prediction
   integer(c_int64_t)          :: length
   real(c_float)               :: prediction(*)
  end function
end interface

interface
   integer(c_int) function XGBoosterCreate_f(dmats, len, out) &
         bind(c, name="XGBoosterCreate")
      use iso_c_binding, only: c_int, c_ptr, c_int64_t

      type(c_ptr), value        :: dmats ! DMatrixHandle
      integer(c_int64_t), value :: len
      type(c_ptr) :: out ! BoosterHandle*
   end function
end interface

interface
   integer(c_int) function XGDMatrixCreateFromMat_f(data, nrow, ncol, missing, out) &
         bind(c, name="XGDMatrixCreateFromMat")
      use iso_c_binding, only: c_int, c_ptr, c_float, c_int64_t 

      !type(c_ptr), value :: data ! float*
      real(c_float)        :: data(*)
      integer(c_int64_t), value :: nrow
      integer(c_int64_t), value :: ncol
      real(c_float), value :: missing
      type(c_ptr) :: out ! DMatrixHandle*
   end function
end interface

interface
   integer(c_int) function XGDMatrixNumRow_f(handle, out) &
         bind(c, name="XGDMatrixNumRow")
      use iso_c_binding, only: c_int, c_ptr, c_int64_t

      type(c_ptr), value :: handle ! DMatrixHandle
      integer(c_int64_t) :: out ! bst_ulong*
   end function
end interface

interface
   integer(c_int) function XGDMatrixNumCol_f(handle, out) &
         bind(c, name="XGDMatrixNumCol")
      use iso_c_binding, only: c_int, c_ptr, c_int64_t

      type(c_ptr), value :: handle ! DMatrixHandle
      integer(c_int64_t) :: out ! bst_ulong*
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
   type(c_ptr) :: handle ! BoosterHandle
   character(len=*) :: fname
   character(len=:),allocatable :: cname
   !!allocate(character(len=len_trim(fname)+1)::cname)
   cname = trim(fname)//c_null_char
   rc = XGBoosterLoadModel_c(handle, cname)
  end function

  integer(kind=c_int) function XGBoosterSaveModel_f(handle, fname) result(rc) 
   use iso_c_binding, only: c_int, c_char, c_ptr, c_null_char
   type(c_ptr) :: handle ! BoosterHandle
   character(len=*) :: fname
   character(len=:),allocatable :: cname
   cname = trim(fname)//c_null_char
   !write(*,*) trim(cname)
   !write(*,*) c_associated(handle)
   rc = XGBoosterSaveModel_c(handle, cname)
  end function

  integer(kind=c_int) function XGDMatrixSaveBinary_f(handle, fname, silent) result(rc)
   use iso_c_binding, only: c_int, c_char, c_ptr, c_null_char
   type(c_ptr) :: handle ! DMatrixHandle
   character(len=*) :: fname
   integer(kind=c_int) :: silent
   character(len=:),allocatable :: cname
   cname = trim(fname)//c_null_char
   rc = XGDMatrixSaveBinary_c(handle, cname, silent)
  end function

  integer(kind=c_int) function XGDMatrixCreateFromFile_f(fname, silent, handle) result(rc)
   use iso_c_binding, only: c_int, c_char, c_ptr, c_null_char
   character(len=*) :: fname
   integer(kind=c_int) :: silent
   type(c_ptr) :: handle ! DMatrixHandle 
   character(len=:),allocatable :: cname
   cname = trim(fname)//c_null_char
   rc = XGDMatrixCreateFromFile_c(cname, silent, handle)
  end function

!  integer(kind=c_int) function XGBoosterPredict_f(handle, dmat, option_mask, ntree_limit, length, prediction) result(rc)
!   use iso_c_binding
!   type(c_ptr) :: handle
!   type(c_ptr) :: dmat
!   rc = XGBoosterPredict_c(handle, dmat, option_mask, ntree_limit, length, prediction)
!  end function

end module
