# DiCELab_16_storage_required


#Optimal storage sizing for grid level energy storage to tackle intermittent renewable energy sources 


This repository comprises of the code I wrote as part of my research project at the Distributed Control of Energy Systems Lab at University of Florida under the guidance of Dr. Prabir Barooah.


##Instructions

In order for most of the MATLAB files in the repository to run they require a accompanying excel datasheet from which to extract the data and perform the analysis. 

For example: 
```
if ispc
    Netload_365 = load_data('C:\Users\Sai\Dropbox\Sai - Research Work\Excel sheet Backup/Netload.xlsx','2015');
end

```
For the code to work download the excel sheets and add the path of the excel file you want to work on along with the sheet name to the **load_data** function at the beginning of the code.
