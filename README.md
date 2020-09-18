# Faster than thought: Detecting sub-second activation sequences with sequential fMRI pattern analysis - fMRIPrep data

## Overview

This repository contains pre-processed MRI data based on defaced BIDS-data used in Wittkuhn & Schuck, 2020, *Nature Communications*.
Pre-processing was performed using fMRIPrep, version 1.2.2.

## Dataset structure

- `/code` contains all project-specific code with sub-directories `/docs` for project-specific documentation and `/fmriprep` for the code relevant to run `fMRIPrep` on the input `/bids` dataset
- `/bids` contains the defaced BIDS-converted MRI dataset as an input to fMRIPrep and is included as an independent sub-datatset
- `/tools` contains the relevant fMRIPrep container and the necessary Freesurfer license file in the `fmriprep` sub-directory.
- `/logs` and `/work` are empty directories (held in place by `.gitkeep` file) and contain log files and the (huge) working directory ouput that fMRIPrep produced. They are populated during the execution of `highspeed-fmriprep-cluster.sh` but not committed to this repo because they will not be used further downstream in the analyses.

## Citation

> Wittkuhn, L. and Schuck, N. W. (2020). Faster than thought: Detecting sub-second activation sequences with sequential fMRI pattern analysis. *bioRxiv*. [doi:10.1101/2020.02.15.950667](http://dx.doi.org/10.1101/2020.02.15.950667)

## Contact

Please [create a new issue](https://github.com/lnnrtwttkhn/highspeed-fmriprep/issues/new) if you have questions about the code or data, if there is anything missing, not working or broken.

For all other general questions, you may also write an email to:

- [Lennart Wittkuhn](mailto:wittkuhn@mpib-berlin.mpg.de)
- [Nicolas W. Schuck](mailto:schuck@mpib-berlin.mpg.de)

## License

All of the data are licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0.
Please see the [LICENSE](LICENSE) file and https://creativecommons.org/licenses/by-nc-sa/4.0/ for details.
