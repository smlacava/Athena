# ATHENA
***ATHENA*** *(Automatic Toolbox for Handling Efficient/Effortless/Experimental/Effective Neural Analyzes)* is a toolbox which allow 
to automatically extract commonly analyzed measures, used to study neural time series, such as EEG and MEG. 
These measures, which can be connectivity, power or background measures, can be studied through this toolbox, through correlation and 
statistical analysis.

The pipeline followed by this toolbox is easy and repetible.
It is possible to choose between a guided or a batch mode:
- The guide mode drive the user throw all the steps which compose the pipeline, allowing him to change parameters during the study
- The batch mode allow the user to compute the entire study automatically, chosing all the parameters before starting it

The pipelina can be subdivided in 3 main steps:
1) The measure extraction: in this step the  user can choose the measure to extract and its parameters as sampling frequency, cut
   frequencies to define the studied frequency bands, the number of epochs and the time window of each one and the starting time and,
   finally, extract it
2) The epochs averaging: in this step the user can compute the averanging of the measure values of each epoch end subdivide the studied
   subjects in their group (patients or healthy controls)
3) The analysis: in this step,, the user can choose the analysis to compute and their parameters

## Measure extraction
The measures extractably by ATHENA can be divided in:
- Connectivity measures
  - **PLI** (Phase Lag Index)
  - **PLV** (Phase Locking Value)
  - **AEC** (Amplitude Envelope Correlation)
  - **corrected AEC** (Amplitude Envelope Correlation)
- Power measures
  - **relative PSD** (Power Spectral Density) 
- Background measures
  - **Exponent**
  - **Offset**
  
The parameters to choose to extract the measures are:
- **fs**: it is the sampling frequency, it can be automatically chosen if the parameter is present in the time series
- **cf**: it is the list of cut frequencies, they define each studied frequency band which will be define between two of the chosen cut 
      frequencies
- **epochs number**: it is the number of time epochs to study
- **epochs time**: it is the time window of each epoch
- **starting time**: it is the starting time of the first epoch, it is useful to avoid initial noise or altered signal due to preprocessing,
       sources reconstruction, etc.
- **relative band**: it is used to extract the relative PSD as relative band

> The toolbox is still under construction
