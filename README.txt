Requirements
============

The script 'main.mlx' should be run with MATLAB R2020b. Full execution requires
functions from the Image Processing Toolbox and Statistics Toolbox. Ensure that
MATLAB's current working directory is the repository root before attempting
execution.

The datasets required can be downloaded from
http://celltrackingchallenge.net/3d-datasets/. The 'Fluo-C3DH-A549' and
'Fluo-N3DH-CHO' challenge datasets are required to run the script. They were
chosen due to their relative size and runtime. Once downloaded, extract to the
'data/' folder such that the 'data/Fluo-C3DH-A549' and 'data/Fluo-N3DH-CHO'
folders exist. Note that Mac or Linux devices may have permissions issues when
extracting the datasets; it is recommended to extract as root, change ownership
to your user, and recursively give the 'data/' folder 755 permissions.

Fluo-C3DH-A549: http://data.celltrackingchallenge.net/challenge-datasets/Fluo-C3DH-A549.zip
Fluo-N3DH-CHO: http://data.celltrackingchallenge.net/challenge-datasets/Fluo-N3DH-CHO.zip

Code Structure
==============

The script 'main.mlx' calls several functions in the 'src/' and 'lib/' folders.
All code in 'src/' was written from scratch for this project (with the
        exclusion of PST_ND.m, which was mostly provided by course staff.)
Functions in 'lib/' are taken from third-party sources and credit can be found
in the source code comments.

Output Products
===============

This script will generate two GIF images per dataset (four total) in the
current directory. 'tracking_cells_<dataset>.gif' shows the original dataset as
the original 2D slices over time with centroids shown.
'tracking_pst_<dataset>.gif' shows the binarized output of the Phase Strecth
Transform over time with centroids shown. Centroids are shown across all Z
slices as small dots, though detection is done in 3D. The Z index of a given
centroid will be shown as a large circle on the centroid of that given Z slice
in the GIFs (rather than a small dot.)
