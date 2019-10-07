import argparse
import numpy as np
import xgboost as xgb
from sklearn.externals import joblib
from sklearn.metrics import mean_squared_error, r2_score
from math import sqrt

def main(args):
    '''
    Trains a dummy XGBoost model for 5 input features and one target variable. 
    The booster model is saved to disk and then reloaded to do a quick check
    that the loaded model is identical to the originally created one.
    '''
    nrow = 500
    ncol = 5
    x_np = np.random.rand(nrow,ncol)
    y_np = np.random.rand(nrow,1)
    train = xgb.DMatrix(x_np,y_np)
    param = {'booster' : 'gbtree'}
    bst = xgb.train(param,train)
    prediction = bst.predict(train)
    r2  = r2_score(y_np,prediction)
    nrmse = sqrt(mean_squared_error(y_np,prediction))/np.std(y_np)
    nmb   = np.sum(prediction-y_np)/np.sum(y_np)
    print("Backtest scores:")
    print("R2 = "+'{0:.2f}'.format(r2))
    print("NRMSE = "+'{0:.2f}'.format(nrmse))
    print("NMB = "+'{0:.2f}'.format(nmb))
    # save
    bst.save_model(args.bstfile)
    # reload
    bst2 = xgb.Booster()
    bst2.load_model(args.bstfile)
    prediction2 = bst2.predict(train)
    r2 = r2_score(prediction,prediction2)
    nrmse = sqrt(mean_squared_error(prediction,prediction2))/np.std(prediction)
    nmb   = np.sum(prediction2-prediction)/np.sum(prediction)
    print("Backtest validation using saved and reloaded model (compared to original):")
    print("R2 (should be 1.00) = "+'{0:.2f}'.format(r2))
    print("NRMSE (should be 0.00) = "+'{0:.2f}'.format(nrmse))
    print("NMB (should be 0.00) = "+'{0:.2f}'.format(nmb))
    # prediction with all zeros and all ones:
    arr = np.zeros((1,5))
    p = bst.predict(xgb.DMatrix(arr))
    print("Prediction with all zeros:")
    print(p)
    arr[:,:] = 1.0
    mtrx = xgb.DMatrix(arr)
    p = bst.predict(mtrx)
    print("Prediction with all ones:")
    print(p)
    mtrx.save_binary('mtrx_ones_from_py.bin')
    print('matrix with ones saved to mtrx_from_py.bin')
    tmp = xgb.DMatrix('mtrx_ones_from_py.bin')
    p = bst.predict(tmp)
    print("Prediction with ones matrix reloaded:")
    print(p)
    return   
 
def parse_args():
    p = argparse.ArgumentParser(description='Undef certain variables')
    p.add_argument('-f','--bstfile',type=str,help='xgb binary file',default='bst_from_py.bin')
    return p.parse_args()

if __name__ == '__main__':
    main(parse_args())

