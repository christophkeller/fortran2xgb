# fortran2xgb
Call XGBoost from Fortran

First crack at calling XGBoost from Fortran. The idea is to train an XGBoost model in Python, then save that model to disk and later call it from Fortran. The Fortran wrappers that invoke the XGBoost C functions are in fortran_api.F90. A Fortran test application that calls the Fortran wrappers is given in xgboost_test.F90.

# requirements
A python version of XGBoost is required (https://github.com/dmlc/xgboost/tree/master/python-package/xgboost) and needs to be pointed at properly in the GNUmakefile. All tests done with version 0.82.

# example
1. Create dummy xgbooster model and save to file (bst.bin):

 python xgb_train.py

2. Compile and execute Fortran code:

 make
