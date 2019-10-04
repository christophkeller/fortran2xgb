program xgboost_test
! Simple test interface that calls XGBoost from Fortran invoking the C bindings defined in fortran_api.F90.
! This uses the Python wrapper as a guide (https://github.com/dmlc/xgboost/blob/master/python-package/xgboost/core.py)
 
 use iso_c_binding
 use fortran_api
 implicit none

 integer :: rc
 character(len=255) :: fname
 type(c_ptr)        :: xgb, dmtrx
 integer(c_int64_t) :: dmtrx_len 
 integer(c_int64_t) :: nrow, ncol 
 real*4             :: arr(1,5)

! xgb   = c_null_ptr
! dmtrx = c_null_ptr
 write(*,*) 'Starting XGBoost program'
 arr(:,:) = 1.0
 nrow = 1
 ncol = 5
 ! Create XGDMatrix - this seems required in order to create a booster object below
 rc = XGDMatrixCreateFromMat_f(arr, nrow, ncol, -999.0, dmtrx)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! now create XGBooster object. Content will be loaded into it next
 dmtrx_len = 0
 rc = XGBoosterCreate_f(dmtrx,dmtrx_len,xgb)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'dmtrx_len: ',dmtrx_len
 write(*,*) c_associated(xgb)
 ! load XGBooster model from binary file
 !fname = 'bst.bin'//c_null_char
 fname = 'bst.bin'
 rc = XGBoosterLoadModel_f(xgb,fname)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) c_associated(xgb)
 ! Save model to txt file
 rc = XGBoosterSaveModel_f(xgb,'test.txt')
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! Release model
 rc = XGBoosterFree_f(xgb)
 write(*,*) 'Model freed, return code: ',rc
 write(*,*) 'All done'

end program

