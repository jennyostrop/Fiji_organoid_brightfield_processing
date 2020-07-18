# Fiji_organoid_brightfield_processing

This repository holds the ImageJ/Fiji script used in the publication "A semi-automated intestinal organoid screening method demonstrates epigenetic control of epithelial maturation" (Ostrop et al. 2020).

The script creates stacks per well/timepoint from the raw data files, performs a simple object segmentation, and creates the Input for the more accurate Ilastik segmentation workflow.

The script is originally developed to be used with output from an EVOS2 microscope (Thermo Fisher Scientific). Use with data from other microscopes will need adaption.
EVOS2 file names follow the pattern: ".*_Plate_Format_Timepoint_Zposition_0_WellFieldChannel.TIF"
The script assumes the following input file hierarchy: PATH/Evos2/INPUT_FOLDER/INPUT_SUBFOLDER1/INPUT_SUBSUBFOLDER1/Evos2_files (e.g. PATH/Evos2/experiment/plate/timepoint/Evos2_files)
Output folders are saved as: PATH/Evos2/INPUT_FOLDER/OUTPUT_SUBFOLDER1 (e.g. PATH/Evos2/experiment/Output_stacks)

The script contains two parts that perform the following steps:

Part1: Collections of z-layers and positions (optional stitching of 2/4 positions with 2 alternative acquisition orders for 4 positions) for each well, saves one stack per well. Files that do not follow the assumed EVOS2 rawdata file name pattern are ignored.
Output1a: Folder with Z stacks (creates one subfolder per INPUT_SUBSUBFOLDER)
Output1b: Folder with minimum intensity projection of each Z stack >> used for phenotype documentation and Input2 for Ilastik workflow (object classification workflow)

Part2 requires output from part1 but can be rerun independently (comment/uncomment).

Part2: Processing of created stacks, simple object segmentation based on e. Segmentation parameters such as threshold can be adjusted, optional manual ROI correction.
Output2a: Folder with numeric output of object segmentation (.csv table for each well)
Output2b: Folder with graphic output from object segmentation (PNG with ROI overlay for each well)
Output2c: Folder with ROI .zip archives (creates one subfolder per INPUT_SUBSUBFOLDER)
Output2d: Folder with summary projection of Sobel edge detection for each z-layer >> Input1 for Ilastik workflow (pixel classification workflow)
Output2e, optional (uncomment/comment): Folder with stack of each segmented object +20pixel band
