# Note: stale repository
This repository is not activetly maintained. The XGBoost - Fortran API has been integrated into the [GEOS QuickChem module](https://github.com/GEOS-ESM/QuickChem). See the [corresponding F90 file](https://github.com/GEOS-ESM/QuickChem/blob/main/Shared/xgb_fortran_api.F90) for a more recent version.

# fortran2xgb
Fortran API for XGBoost

Interface for calling XGBoost from Fortran. The idea is to train an XGBoost model externally, e.g. in Python, then save that model to disk (in the XGBoost internal binary format, e.g. using Booster.save_model() in Python), and later call the model from Fortran to make a prediction.
The Fortran wrappers that invoke the XGBoost C functions are in xgb_fortran_api.F90. A Fortran test application that creates a very simple XGBoost model and then calls the Fortran wrappers is given in xgb_train.py and xgboost_test.F90, respectively.

# Requirements
A Python version of XGBoost is required (https://github.com/dmlc/xgboost/tree/master/python-package/xgboost) and needs to be pointed at properly in the GNUmakefile. All tests done with version 0.82.

# Example
1. Create dummy xgbooster model and save to file (bst_from_py.bin):

 `python xgb_train.py`

2. Compile and execute Fortran code:

 `make`
