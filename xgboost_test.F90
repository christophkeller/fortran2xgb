program xgboost_test
! Simple interface showing an example on how to call XGBoost from Fortran 
! by invoking the C bindings defined in fortran_api.F90.
! 
! As an example, this reads a pre-saved booster object from file 'bst.bin' 
! and then makes a prediction using a vector of all ones as input. The booster
! object is assumed to take 5 input arguments and produce one target value. 
! The booster model can be trained in python and then written to binary file, 
! as e.g. shown in xgb_train.py. 
!
! History:
! 2019-10-09 - christoph.a.keller@nasa.gov - Initial version
! ----------------------------------------------------------------------------
 use iso_c_binding
 use xgb_fortran_api
 implicit none

!--- Local variables
 integer                    :: rc
 integer(c_int64_t)         :: nrow, ncol
 ! for booster object 
 character(len=255)         :: fname_bst
 integer(c_int64_t)         :: dmtrx_len
 type(c_ptr)                :: bst
 ! for XGDMatrix object
 type(c_ptr)                :: dmtrx 
 integer(c_int64_t)         :: dm_nrow, dm_ncol
 integer(c_int)             :: silent
 real(c_float), allocatable :: carr(:)
 character(len=255)         :: fname
 ! for prediction
 integer(c_int)             :: option_mask, ntree_limit
 type(c_ptr)                :: cpred
 integer(c_int64_t)         :: pred_len 
 real(c_float), pointer     :: pred(:)

!--- Parameter
 ! missing value 
 real(c_float), parameter :: miss = -999.0
 ! debug flag
 logical, parameter       :: debug    = .false.
 logical, parameter       :: fulltest = .true.

!--- Settings
 ! Dimension of input array. We assume it's 1x5 (1 prediction, 5 input variables)
 fname_bst = 'xgbin/bst_from_py.bin'
 nrow      = 1
 ncol      = 5
 ! Array to hold input values
 allocate(carr(ncol))
 carr(:) = 0.0
 ! Settings for prediction 
 option_mask = 0
 ntree_limit = 0
 ! Silent flag for reading/writing
 silent = 0

!--- Starts here
 write(*,*) 'Starting XGBoost program'

!--- Load booster object
 ! Create (dummy) XGDMatrix - this is required in order to create the booster object below
 rc = XGDMatrixCreateFromMat_f(carr, nrow, ncol, miss, dmtrx)
 if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! Check XGDMatrix dimensions
 ! number of rows/cols in dmtrx
 rc = XGDMatrixNumRow_f(dmtrx, dm_nrow) 
 if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! number of rows/cols in dmtrx
 rc = XGDMatrixNumCol_f(dmtrx, dm_ncol) 
 if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 write(*,*) 'Numbers of rows, cols of DMatrix object: ',dm_nrow,dm_ncol

 ! now create XGBooster object. Content will be loaded into it next
 dmtrx_len = 0
 rc = XGBoosterCreate_f(dmtrx,dmtrx_len,bst)
 if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! load XGBooster model from binary file
 write(*,*) 'Reading '//trim(fname_bst)
 rc = XGBoosterLoadModel_f(bst,fname_bst)
 if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! To save model to binary file
 if ( fulltest ) then
    rc = XGBoosterSaveModel_f(bst,'xgbin/bst_from_f90.bin')
    if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 endif

!--- Make prediction with all ones 
 ! Create XGDMatrix with all ones
 carr(:) = 1.0
 rc = XGDMatrixCreateFromMat_f(carr, nrow, ncol, miss, dmtrx)
 if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! Make prediction. The result will be stored in c pointer cpred 
 rc = XGBoosterPredict_f(bst,dmtrx,option_mask,ntree_limit,pred_len,cpred)
 if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
 ! Link to fortran pointer pred 
 call c_f_pointer(cpred, pred, [pred_len])
 write(*,*) 'Prediction with all ones: ',pred

!--- Additional example code for DMatrix 
 if ( fulltest ) then
    ! 1. Save XGDMatrix defined above to binary file. This can then
    ! be reloaded, e.g. using XGDMatrixCreateFromFile_f or from
    ! Python, e.g.: dmtrx = xgboost.DMatrix('mtrx_ones_from_f90.bin')
    fname = 'xgbin/mtrx_ones_from_f90.bin'
    rc = XGDMatrixSaveBinary_f(dmtrx, fname, silent)
    if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
    ! 2. Load XGDMatrix from binary file 
    rc = XGDMatrixCreateFromFile_f(fname, silent, dmtrx)
    if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
    ! 3. Make prediction with this matrix - should give same result as above 
    rc = XGBoosterPredict_f(bst,dmtrx,option_mask,ntree_limit,pred_len,cpred)
    if(debug) write(*,*) __FILE__,__LINE__,'Return code: ',rc
    call c_f_pointer(cpred, pred, [pred_len])
    write(*,*) 'Prediction with data from file: ',pred
 endif

!--- Cleanup
 rc = XGBoosterFree_f(bst)
 if(debug) write(*,*) __FILE__,__LINE__,'Model freed, return code: ',rc
 if (allocated (carr) ) deallocate(carr)
 if (associated(pred) ) nullify(pred)
 write(*,*) 'All done'

end program

