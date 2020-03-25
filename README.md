# Gaussian Processes for Cyclic Voltammetry
This repositiroy contains the reproducible code for the paper "Active Knwoledged Extraction from Cyclic Voltammetry".
The repositiroy is arranged as follows:
```
gpcv : contains the functions required to perform various computations on the CV curves
ext : Contains dependency packages with appropriate licenses
helpers : Contains various helper functions used in the repositiroy
docs : Documents such as presentations, tutorials etc.
```

Along with the code, we provide pre-computed data for CV responses from EC mechanism kinetic zone diagram.
This data is accesible in `gpcv/data` as .mat files.

There are two demos detailing the experiments results in the paper:
```
demos/demo_active_learning_cvcomb
demos/demo_cvaas
```

Along with our BMS oracle, we implemented other comparitive oracles in `gpcv/CatalyticLabelOracle`.
Here's a sample usage of the same for different methods:
```matlab
load([pwd '\CatalyticGP\cvdata\gridkzd.mat'])
load([pwd '\CatalyticGP\cvdata\traindata_kzd.mat'])
ref_sshape = input_x(:,121);
i = 20
obj = CatalyticLabelOracle(input_x(:,i),xtr_kzd(:,2),xtr_kzd(:,1),ref_sshape);
```
Compute a Foot of the wave analysis score that computes if the curve is linear in the FOWA space using an R-square value
```matlab
[fowa_label(i),fowa_score(i)] = obj.FOWAFit();
```
Compute a similairty search score that compare a given CV curve to the reference in `ref_sshape` using a n-dimensional distance. 
```matlab
[ss_label, ss_score]= obj.SimilaritySearch();
```
Compute the BMS score presented in the paper using:
```matlab
[bms_label, bms_score]= obj.BayesianModelSelection();
```