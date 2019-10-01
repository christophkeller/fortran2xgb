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
   type(c_ptr) :: handle ! BoosterHandle
   character(len=1, kind=c_char), dimension(*) :: fname
  end function
end interface

interface
   integer(c_int) function XGBoosterCreate_f(dmats, len, out) &
         bind(c, name="XGBoosterCreate")
      use iso_c_binding, only: c_int, c_ptr, c_int64_t

      type(c_ptr) :: dmats ! DMatrixHandle* ????? what are square brackes
      integer(c_int64_t), value :: len
      type(c_ptr) :: out ! BoosterHandle*
   end function
end interface

interface
   integer(c_int) function XGDMatrixCreateFromMat_f(data, nrow, ncol, missing, out) &
         bind(c, name="XGDMatrixCreateFromMat")
      use iso_c_binding, only: c_int, c_ptr, c_float, c_int64_t 

      !type(c_ptr) :: data ! float*
      real(c_float) :: data(*)
      integer(c_int64_t), value :: nrow
      integer(c_int64_t), value :: ncol
      real(c_float), value :: missing
      type(c_ptr) :: out ! DMatrixHandle*
   end function
end interface

interface
   integer(c_int) function XGDMatrixNumRow_f(handle, out) &
         bind(c, name="XGDMatrixNumRow")
      use iso_c_binding, only: c_int, c_ptr

      type(c_ptr) :: handle ! DMatrixHandle
      type(c_ptr) :: out ! bst_ulong*
   end function
end interface

interface
   integer(c_int) function XGBoosterFree_f(handle) &
         bind(c, name="XGBoosterFree")
      use iso_c_binding, only: c_int, c_ptr

      type(c_ptr) :: handle ! BoosterHandle
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
   write(*,*) trim(cname)
   write(*,*) c_associated(handle)
   rc = XGBoosterSaveModel_c(handle, cname)
  end function

end module
