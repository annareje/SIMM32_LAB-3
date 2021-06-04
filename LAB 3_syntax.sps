* Encoding: UTF-8.

DATASET ACTIVATE DataSet2.
RECODE Sex ('male'=1) ('female'=0) INTO sex_dummy.
EXECUTE.

RECODE Embarked ('S'=0) ('Q'=1) ('C'=2) INTO embarked_numeric.
EXECUTE.

RECODE SibSp (0=0) (1 thru 8=1) INTO No_spous_sib.
EXECUTE.

CROSSTABS
  /TABLES=Survived BY Pclass embarked_numeric sex_dummy SibSp Parch No_spous_sib Age
  /FORMAT=AVALUE TABLES
  /STATISTICS=CHISQ 
  /CELLS=COUNT ROW 
  /COUNT ROUND CELL.

NOMREG Survived (BASE=FIRST ORDER=ASCENDING) BY sex_dummy embarked_numeric SibSp Parch WITH Age Fare    
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=FIT PARAMETER SUMMARY LRT CPS STEP MFI IC.

RECODE Cabin (MISSING=0) ('ELSE'=1) INTO Has_cabin. 
EXECUTE. 
SORT CASES BY Has_cabin (A). 
SORT CASES BY Has_cabin (D). 
SORT CASES BY Cabin (A). 
SORT CASES BY Cabin (D). 
RECODE SibSp (0=0) (1 thru 8=1) INTO No_spous_sib. 
EXECUTE. 
SORT CASES BY No_spous_sib (A). 
SORT CASES BY SibSp (A). 
SORT CASES BY SibSp (D). 
CROSSTABS 
  /TABLES=Survived BY Pclass embarked_numeric sex_dummy SibSp Parch No_spous_sib Age 
  /FORMAT=AVALUE TABLES 
  /CELLS=COUNT 
  /COUNT ROUND CELL.


LOGISTIC REGRESSION VARIABLES Survived
  /METHOD=ENTER sex_dummy Pclass embarked_numeric Has_spous_sib 
  /PRINT=CI(95)
  /CRITERIA=PIN(0.05) POUT(0.10) ITERATE(20) CUT(0.5).

RECODE Parch (0=1) (ELSE=0) INTO no_parch.
EXECUTE.

RECODE Pclass (1=1) (ELSE=0) INTO First_class.
EXECUTE.

COMPUTE predicted_survival=4.818382  +  ( -2.622 * sex_dummy)  + (0.170207  * embarked_numeric) + 
    (0.553803 * has_cabin) + ( -1.059759  * Pclass) + (-0.043905 * Age) + (-0.354870 * SibSp) + 
    (-0.053298 * Parch).
EXECUTE.
