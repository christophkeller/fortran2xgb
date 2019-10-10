.SUFFIXES: .o .f90 .F90 .F .exe .c

.PHONY:
	all clean veryclean

#FC = ifort
FC = gfortran
#FC = nagfor

XGBOOST_LIBDIR = ./xgboost/lib

INCDIR = include

all: runtest

runtest: test.exe
	env LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(XGBOOST_LIBDIR) ./test.exe

test.exe: xgboost_test.o xgb_fortran_api.o
	$(FC) $(FOPTS) $^ -o $@ -L$(XGBOOST_LIBDIR) -lxgboost

xgboost_test.o: xgboost_test.F90 xgb_fortran_api.o

xgb_fortran_api.o: xgb_fortran_api.F90

#FOPTS = -g -traceback
FOPTS = -g -fbacktrace
#FOPTS = -g -C=all

.f90.o:
	$(FC) $(VOPTS) $(FOPTS) $(DOPTS) -c $< -I$(INCDIR)

.F90.o:
	$(FC) $(VOPTS) $(FOPTS) $(DOPTS) -c $< -I$(INCDIR)

.F.o:
	$(FC) $(VOPTS) $(FOPTS) $(DOPTS) -c $< -I$(INCDIR)

.cuf.o:
	$(FC) $(VOPTS) $(FOPTS) $(DOPTS) -c $< -I$(INCDIR)

.c.o:
	$(CC) $(VOPTS) $(COPTS) $(DOPTS) -c $< -I$(INCDIR)

clean:
	rm -f *.o *.mod core.* *.exe

veryclean: clean
	rm -f *.exe input.nml logfile.* mpp_clock.out.*
