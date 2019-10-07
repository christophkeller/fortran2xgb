program xgboost_test
! Simple test interface that calls XGBoost from Fortran invoking the C bindings defined in fortran_api.F90.
! This uses the Python wrapper as a guide (https://github.com/dmlc/xgboost/blob/master/python-package/xgboost/core.py)
 
 use iso_c_binding
 use fortran_api
 implicit none

 integer :: rc
 character(len=255) :: fname
 type(c_ptr)        :: bst, dmtrx, dmtrx2, dmtrx3, dmtrx4
 integer(c_int64_t) :: dmtrx_len 
 integer(c_int64_t) :: nrow, ncol
 real(c_float)      :: miss
 integer(c_int64_t) :: pred_len 
 integer(c_int64_t) :: option_mask 
 integer(c_int64_t) :: ntree_limit
 integer(c_int64_t) :: dmtrx_nrow 
 integer(c_int64_t) :: dmtrx_ncol 
 integer(c_int)     :: silent
 real*4             :: pred1(1), pred2(1), pred3(1)
 real*4             :: arr(5)

 write(*,*) 'Starting XGBoost program'
 nrow = 1
 ncol = 5
 arr(:) = 1.0
 miss = 1.0
 ! Create XGDMatrix - this seems required in order to create a booster object below
 rc = XGDMatrixCreateFromMat_f(arr, nrow, ncol, miss, dmtrx)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! Check XGDMatrix dimensions
 ! number of rows/cols in dmtrx
 rc = XGDMatrixNumRow_f(dmtrx, dmtrx_nrow) 
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'Numbers of rows: ',dmtrx_nrow
 ! number of rows/cols in dmtrx
 rc = XGDMatrixNumCol_f(dmtrx, dmtrx_ncol) 
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'Numbers of cols: ',dmtrx_ncol

 ! now create XGBooster object. Content will be loaded into it next
 dmtrx_len = 0
 rc = XGBoosterCreate_f(dmtrx,dmtrx_len,bst)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'dmtrx_len: ',dmtrx_len
 write(*,*) c_associated(bst)
 ! load XGBooster model from binary file
 fname = 'bst_from_py.bin'
 rc = XGBoosterLoadModel_f(bst,fname)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) c_associated(bst)
 ! Save model to txt file
 rc = XGBoosterSaveModel_f(bst,'bst_from_f90.bin')
 write(*,*) __FILE__,__LINE__,'Return code: ',rc

 ! Prediction with all zeros 
 option_mask = 0
 ntree_limit = 0
 arr(:) = 0.0
 miss = 0.0
 rc = XGDMatrixCreateFromMat_f(arr, nrow, ncol, miss, dmtrx2)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc

 ! save to binary - loading this file from python gives the expected result
 rc = XGDMatrixSaveBinary_f(dmtrx3, 'mtrx_zeros_from_f90.bin', silent)
 rc = XGBoosterPredict_f(bst,dmtrx2,option_mask,ntree_limit,pred_len,pred1)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'Prediction with all zeros: ',pred_len, pred1(1)

 ! Prediction with all ones 
 arr(:) = 1.0
 miss = 1.0
 rc = XGDMatrixCreateFromMat_f(arr, nrow, ncol, miss, dmtrx3)
 ! save to binary - loading this file from python gives the expected result
 fname = 'mtrx_ones_from_f90.bin'
 rc = XGDMatrixSaveBinary_f(dmtrx3, fname, silent)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc

 rc = XGBoosterPredict_f(bst,dmtrx3,option_mask,ntree_limit,pred_len,pred2)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'Prediction with all ones: ',pred_len, pred2(1)

 ! Try reading from binary file
 silent = 0
 write(*,*) 'Reading matrix from file'
 rc = XGDMatrixCreateFromFile_f('mtrx_ones_from_py.bin',silent,dmtrx4)
 rc = XGDMatrixSaveBinary_f(dmtrx4, 'mtrx_ones_from_py_to_f90.bin', silent)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! number of rows/cols in dmtrx
 rc = XGDMatrixNumRow_f(dmtrx4, dmtrx_nrow) 
 rc = XGDMatrixNumCol_f(dmtrx4, dmtrx_ncol) 
 write(*,*) 'Numbers of rows, cols: ',dmtrx_nrow, dmtrx_ncol

 rc = XGBoosterPredict_f(bst,dmtrx4,option_mask,ntree_limit,pred_len,pred3)
 write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'Prediction with matrix read from file: ',pred_len, pred3(1)

 ! Release model
 rc = XGBoosterFree_f(bst)
 write(*,*) 'Model freed, return code: ',rc
 write(*,*) 'All done'

end program

