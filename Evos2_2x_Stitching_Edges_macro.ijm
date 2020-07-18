//ImageJ/Fiji script used in the publication "A semi-automated intestinal organoid screening method demonstrates epigenetic control of epithelial maturation" (Ostrop et al. 2020).
////
////
//MIT License
//
//Copyright (c) 2020 Jenny Ostrop, Norwegian University of Science and Technology
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
////
////



////
////
//ENTRY
////
delim = "\\"

//INPUT
//directory, adjust for hierarchy
//hierarchy example: PATH/Evos2/INPUT_FOLDER/INPUT_SUBFOLDER1/INPUT_SUBSUBFOLDER1/Evos2_files
dir = "PATH\\Evos2"
subdir = "INPUT_FOLDER"
dirHierarchyOrig = dir +delim +subdir; //adjust for folder hierarchy
finalsubdir = newArray("INPUT_SUBFOLDER1","INPUT_SUBFOLDER2","INPUT_SUBFOLDER3","INPUT_SUBFOLDERn") //input subfolders must only contain subfolders with Evos files

//file names,EVOS2
//EVOS2 file name = "*_Plate_Format_Timepoint_Zposition_0_WellFieldChannel.TIF"
//fileRaw example = "date_expno_plateno_timepoint_Plate_R_p00_z00_0_C01f01d0.TIF"
//Format: raw, merged (R/M)
fileFormat = newArray("R");
//Channel
fileChannel = newArray("d4");
PatternLength = fileFormat.length*fileChannel.length;
print("FilePatternLength= "+ PatternLength);
tifPattern = newArray();
for (z=0; z<PatternLength; z++){
	for (y=0; y<fileChannel.length; y++){
		for (x=0; x<fileFormat.length; x++){
			tifPattern = Array.concat(tifPattern,".*_Plate_" +fileFormat[z] +"_.*" +"_z.*" +"_.*" +fileChannel[y] +".TIF");
			print("Pattern= "+ tifPattern[z]);	
		}
	}
}

//OUTPUT
//directory, adjust for desired output
//subdirOutputOrig = newArray("Output_stacks","Output_projection"); //part 1, stack collection
subdirOutputOrig = newArray("Output_stacks","Output_projection","Output_numeric","Output_graphic","Output_objectsTable","Output_edges"); //part 1+2, stack collection and object processing
//subdirOutputOrig = newArray("Output_stacks","Output_projection","Output_numeric","Output_graphic","Output_objectsTable","Output_edges","Output_objectsCut"); //optional: part 1+2, stack collection and object processing, save stack of each segmented object
//subsubdirOutput = newArray("Output_stacks"); //part 1, stack collection
subsubdirOutput = newArray("Output_stacks","Output_objectsTable"); //part 1+2, stack collection and object processing


//object processing and segmentation
//PARMETERS >> test&adjust here if segmentation is not good! Changing threshold and circularity has strongest effect.
//function OrganoidProjection
//parameters for projection and thresholding
contrast = "yes" //enhance contrast 
ProjMeth = newArray("Standard Deviation","Sum Slices"); //ProjMeth[0] for segmentation: "Standard Deviation"=STD or "Min Intensity"=MIN; ProjMeth[1] for Ilastik: "Sum Slices"
ShortMeth = "STD";
ThreshMeth = "Otsu"; //Threshold: "Otsu","IJ_IsoData","Triangle"
threshold = "manual_numeric"; //manual or auto threshold? "auto","manual_numeric","manual_user-defined"
thresh = 210; //8-bit, threshold manual numeric
//function OrganoidSegmenation
//parameters for object size and circularity
minimalSize = "200"; //pixel
maximalSize = "Infinity"; //pixel or "Infinity"
minimalCirc = "0.01"; //0-1
maximalCirc = "1"; //0-1
manualCorr = "no"; //manual ROI correction?
//optional ENTRY for different parameters (timepoints) per folder. CAVE: Segmentation returns error if more input folders than entries!
minSize = newArray(minimalSize,minimalSize,minimalSize,minimalSize,minimalSize,minimalSize,minimalSize,minimalSize,minimalSize,minimalSize); //pixel
maxSize = newArray(maximalSize,maximalSize,maximalSize,maximalSize,maximalSize,maximalSize,maximalSize,maximalSize,maximalSize,maximalSize); //pixel or "Infinity"
minCirc = newArray(minimalCirc,minimalCirc,minimalCirc,minimalCirc,minimalCirc,minimalCirc,minimalCirc,minimalCirc,minimalCirc,minimalCirc); //0-1
maxCirc = newArray(maximalCirc,maximalCirc,maximalCirc,maximalCirc,maximalCirc,maximalCirc,maximalCirc,maximalCirc,maximalCirc,maximalCirc); //0-1


////
////
//BEGIN Script
////
//create output directory, function outputDir
dirHierarchy = dirHierarchyOrig;
subdirOutput = subdirOutputOrig;
outputdir(dirHierarchy,subdirOutput);

// /*
//part1: COLLECT files, make stacks
//input folders (subfolders of finalsubdir)
//i = element in finalsubdir
for (i=0; i<finalsubdir.length; i++){
	print("i= " +i);
	Input = dirHierarchyOrig +delim +finalsubdir[i];
	print("Input directory= " +Input);
	
	//call function folderlist	
	folderList = folderlist(Input);
	print("Number of folders in directory= " +folderList.length);

	//for each subfolder
	//j = element in folderList
	for (j=0; j<folderList.length; j++){
		print("j= " +j);
		print("Folder= " +folderList[j]);
		stringSplit = lastIndexOf(folderList[j],".");
		//print("stringSplit= " +stringSplit);
		folderShort = substring(folderList[j], 0, stringSplit);
		print("folderShort= " +folderShort);
		
		//get fileList of subfolder, call function filelist
		iter = j; //iteration to be used	
		fileList = filelist(Input,folderList);
		print("Number of files in directory= " +fileList.length);
		
		//.tif pattern as defined in entry
		print("number of FilePatterns= " +tifPattern.length +", first= "+tifPattern[0] +", last= "+tifPattern[tifPattern.length-1]);
		//valid tif files in each input folder
		//k = element in tifPattern
		for (k=0; k<tifPattern.length; k++){
			print("k= " +k);
			print("tifPattern =" +tifPattern[k]);
			savePattern = k+1;
			
			//call function tifcorrect
			iterPattern = k;
			tifCorrect = tifcorrect(Input,folderList,tifPattern);
			tifCorrect = Array.sort(tifCorrect);
			Array.print(tifCorrect);
			print("Number of correct .TIF in directory= " +tifCorrect.length);
			stringLength = lastIndexOf(tifCorrect[0],".TIF");

			wells = newArray();				
			positions =newArray("f00");
			timepoints = newArray("p00");
			noZ = newArray();

			//extract well, position, timepoint, zslice (by position in string)
			//l = element in tifCorrect
			for (l=0; l<tifCorrect.length; l++){
				//print("file =" +tifCorrect[l]);	

				wellID = substring(tifCorrect[l], stringLength-8, stringLength-5);
				stitchPosition = substring(tifCorrect[l], stringLength-5, stringLength-2);	
				timepoint = substring(tifCorrect[l], stringLength-18, stringLength-15);	
				zslice = substring(tifCorrect[l], stringLength-14, stringLength-11);
														
				//extract number of wells in directory					
				if (zslice=="z00" && timepoint=="p00" && stitchPosition=="f00"){ //only .tif with z00 and p00
					//print("wellID= " +wellID);
					wells = Array.concat(wells,wellID);
				}
				
				//extract number of positions per well
				if (wellID==wells[0]){
					if (stitchPosition!="f00" && zslice=="z00" && timepoint=="p00"){
						//print("stitchPosition= " +stitchPosition);
						positions = Array.concat(positions,stitchPosition);
					}
					//extract number of timepoints
					if (timepoint!="p00" && stitchPosition=="f00" && zslice=="z00"){
						//print("timepoint= " +timepoint);
						timepoints = Array.concat(timepoints,timepoint);
					}
					if (timepoint=="p00" && stitchPosition=="f00"){
						noZ = Array.concat(noZ,zslice);
						//print("zslice =" +zslice);
					}
				}
			}

			print("folderShort= " +folderShort);
			Array.sort(wells);
			print("Number of wells in directory= " +wells.length +", first= "+wells[0] +", last= "+wells[wells.length-1]);
			Array.sort(positions);
			print("Number of positions per well= " +positions.length +", first= "+positions[0] +", last= "+positions[positions.length-1]);
			Array.sort(timepoints);		
			print("Number of timepoints in directory= " +timepoints.length +", first= "+timepoints[0] +", last= "+timepoints[timepoints.length-1]);	
			Array.sort(noZ);				
			print("Number of Zslices in directory= " +noZ.length +", first= "+noZ[0] +", last= "+noZ[noZ.length-1]);

			////
			////
			//OUTPUT directories
			////
			//output_stacks
			//create output subdirectory for stacks for each tifPattern, function outputDir
			dirHierarchy = dirHierarchyOrig +delim +subsubdirOutput[0];
			subdirOutput = newArray();
			subdirOutput = Array.concat(folderShort +"_tifPattern" +savePattern +"_zstack");
			outputdir(dirHierarchy,subdirOutput);
			stackDir = dirHierarchy +delim +subdirOutput[0];
	
			//output_zprojection
			projectionDir = dirHierarchyOrig +delim +subdirOutputOrig[1];

			////
			////
			//Image PROCESSING
			////
			//open images, stitch positions, and create stack for each well
			//raw data directory
			dirHierarchy = dirHierarchyOrig;
			dirInput_raw = dirHierarchy +delim +finalsubdir[i] +delim +folderList[j];

			//m = element in timepoints
			for (m=0; m<timepoints.length; m++){
				saveTime = timepoints[m];
				
				//n = elements in wells
				for (n=0; n<wells.length; n++){
					saveWell = wells[n];
					print("processing timepoint " +saveTime +", well " +saveWell);

					f00 = newArray();
					f01 = newArray();
					f02 = newArray();
					f03 = newArray();
					//o = element in noZ
					for(o=0; o<noZ.length; o++){
						z=noZ[o];
							
						//n = element in tifCorrect
						for (l=0; l<tifCorrect.length; l++){

							//each tifPattern
							if(matches(tifCorrect[l],tifPattern[k])){
								//print("tifPattern" +(k+1) +" " +tifPattern[k] +" matched");
	
								if (matches(tifCorrect[l], ".*_" +saveTime +"_" +z +".*_" +saveWell +".*.TIF")){
									slice = tifCorrect[l];
									print("Slice= " +slice);
	
									//position1
									if (matches(slice, ".*_" +saveTime +"_" +z +".*_" +saveWell +"f00.*.TIF")){
										f00 = Array.concat(f00,slice);
									}
									//position2
									if (matches(slice, ".*_" +saveTime +"_" +z +".*_" +saveWell +"f01.*.TIF")){
										f01 = Array.concat(f01,slice);
									}
									//position3
									if (matches(slice, ".*_" +saveTime +"_" +z +".*_" +saveWell +"f02.*.TIF")){
										f02 = Array.concat(f02,slice);
									}
									//position4
									if (matches(slice, ".*_" +saveTime +"_" +z +".*_" +saveWell +"f03.*.TIF")){
										f03 = Array.concat(f03,slice);
									}									
								}
							}
						}
					}
					print("field00.length= " +f00.length);
					print("field01.length= " +f01.length);
					print("field02.length= " +f02.length);
					print("field03.length= " +f03.length);

					//batch mode on (this is required to stand inside loop)
					setBatchMode(true);	
				
					//one position, no stitching					
					if(positions.length==1){
						print("1 position");
						for (o=0; o<noZ.length; o++){				
							z=noZ[o];
							open(dirInput_raw +delim +f00[o]);
							rename(z);
						}
					}

					//stitch 2 positions, QnD
					if(positions.length==2){
						print("stitch 2 positions");
									
						for (o=0; o<noZ.length; o++){
							z=noZ[o];
							newImage("Background", "8-bit black", 1328, 2084, 1);
							ID0 = getImageID();
							//print("ID Background=" +ID0);
						
							open(dirInput_raw +delim +f00[o]);
							ID1 = getImageID();
							//print("ID Bottom=" +ID1);
							open(dirInput_raw +delim +f01[o]);
							ID2 = getImageID();
							//print("ID Top=" +ID2);
							
							selectImage(ID2);
							run("Copy");
							selectImage(ID0);
							makeRectangle(0, 0, 1328, 1048);
							run("Paste");	
							
							selectImage(ID1);
							run("Copy");
							selectImage(ID0);
							makeRectangle(0, 1034, 1328, 1048);
							run("Paste");
							

							rename(z);
							selectImage(ID1);
							run("Close");
							selectImage(ID2);
							run("Close");
						}
					}
										
					//stitch 4 positions, acquisition in default order, QnD
					if(positions.length==4){
						print("stitch 4 positions");
						
						for (o=0; o<noZ.length; o++){
							z=noZ[o];					
							newImage("Background", "8-bit black", 2636, 2084, 1);
							ID0 = getImageID();
							//print("ID Background=" +ID0);
	
							open(dirInput_raw +delim +f00[o]);
							ID1 = getImageID();
							//print("ID BottomLeft=" +ID1);
							open(dirInput_raw +delim +f01[o]);
							ID2 = getImageID();
							//print("ID BottomRight=" +ID2);
							open(dirInput_raw +delim +f02[o]);
							ID3 = getImageID();
							//print("ID TopRight=" +ID3);
							open(dirInput_raw +delim +f03[o]);
							ID4 = getImageID();
							//print("ID TopLeft=" +ID4);

							selectImage(ID4);
							run("Copy");
							selectImage(ID0);
							makeRectangle(0, 0, 1328, 1048);
							run("Paste");
								
							selectImage(ID1);
							run("Copy");
							selectImage(ID0);
							makeRectangle(0, 1034, 1328, 1048);
							run("Paste");
							
							selectImage(ID3);
							run("Copy");
							selectImage(ID0);
							makeRectangle(1316, 0, 1328, 1048);
							run("Paste");
							
							selectImage(ID2);
							run("Copy");
							selectImage(ID0);
							makeRectangle(1316, 1034, 1328, 1048);
							run("Paste");					
	
							rename(z);
							selectImage(ID1);
							run("Close");
							selectImage(ID2);
							run("Close");
							selectImage(ID3);
							run("Close");
							selectImage(ID4);
							run("Close");
						}					
					}

					/*
					//stitch 4 positions, acquisition serpent horizontal, QnD
					if(positions.length==4){
						print("stitch 4 positions");
						
						for (o=0; o<noZ.length; o++){
							z=noZ[o];
							
							newImage("Background", "8-bit black", 2656, 2084, 1);
							ID0 = getImageID();
							//print("ID Background=" +ID0);

							open(dirInput_raw +delim +f00[o]);
							ID1 = getImageID();
							//print("ID BottomLeft=" +ID1);
							open(dirInput_raw +delim +f01[o]);
							ID2 = getImageID();
							//print("ID BottomRight=" +ID2);
							open(dirInput_raw +delim +f02[o]);
							ID3 = getImageID();
							//print("ID TopRight=" +ID3);
							open(dirInput_raw +delim +f03[o]);
							ID4 = getImageID();
							//print("ID TopLeft=" +ID4);

							selectImage(ID4);
							run("Copy");
							selectImage(ID0);
							makeRectangle(0, 1048, 1328, 1048);
							run("Paste");
				
							selectImage(ID1);
							run("Copy");
							selectImage(ID0);	
							makeRectangle(0, 0, 1328, 1048);
							run("Paste");
							
							selectImage(ID3);
							run("Copy");
							selectImage(ID0);
							makeRectangle(1328, 1048, 1328, 1048);
							run("Paste");	
							
							selectImage(ID2);
							run("Copy");
							selectImage(ID0);
							makeRectangle(1328, 0, 1328, 1048);
							run("Paste");			
	
							rename(z);
							selectImage(ID1);
							run("Close");
							selectImage(ID2);
							run("Close");
							selectImage(ID3);
							run("Close");
							selectImage(ID4);
							run("Close");
						}					
					}
					*/
					
					//make stack
					run("Images to Stack", "name=Stack title=[] use");
					stack = getImageID();
					//save stack
					saveStack = stackDir +delim +folderShort +"_" +saveWell +"_tifPattern" +savePattern +"_" +saveTime +"_Zstack";
					saveAs("TIFF", saveStack +".tif");
							
					//save Z projection of stack
					selectImage(stack);
					run("Z Project...", "projection=[Min Intensity]");
					saveProjection = projectionDir +delim +folderShort +"_" +saveWell +"_tifPattern" +savePattern +"_" +saveTime +"_Zprojection";
					saveAs("PNG", saveProjection +".png");

					//tidy
					run("Close All");
					roiManager("reset");
				}
			}
		}
	}
	print("Stacks done!");
}
// */


////
////
// /*
//part2: PROCESS stacks, segment objects
print("Processing stacks");
//input folders (subsubdirOutput[z])
Input = dirHierarchyOrig +delim +subsubdirOutput[0]
//call function folderlist	
folderList = folderlist(Input);
print("Number of folders in directory= " +folderList.length);
Array.print(folderList);

//i = element in folderList
for (i=0; i<folderList.length; i++){
	stringSplit = lastIndexOf(folderList[i],"_tif");
	folderShort = substring(folderList[i], 0, stringSplit);
	print("FolderShort= " +folderShort);

	////
	////
	//OUTPUT directories
	////
	//output_numeric
	numericDir = dirHierarchyOrig +delim +subdirOutputOrig[2];

	//output_graphic
	graphicDir = dirHierarchyOrig +delim +subdirOutputOrig[3];
	
	////
	//output_zobjectsTable
	//create output subdirectory for zobjects for each tifPattern, function outputDir
	dirHierarchy = dirHierarchyOrig +delim +subsubdirOutput[1];
	subdirOutput = newArray();
	subdirOutput = Array.concat(folderShort +"_zobject");
	outputdir(dirHierarchy,subdirOutput);
	objectTableDir = dirHierarchy +delim +subdirOutput[0];

	//output_edges
	edgesDir = dirHierarchyOrig +delim +subdirOutputOrig[5];
	
	/*
	////
	//output_zobjectsCut, optional
	//create output subdirectory for zobjects for each tifPattern, function outputDir
	dirHierarchy = dirHierarchyOrig +delim +subsubdirOutput[2];
	subdirOutput = newArray();
	subdirOutput = Array.concat(folderShort +"_zobject");
	outputdir(dirHierarchy,subdirOutput);
	objectCutDir = dirHierarchy +delim +subdirOutput[0];
	*/
	
	///
	////
	//Stack PROCESSING
	////
	//get fileList of subfolder, call function filelist
	iter = i; //iteration to be used	
	fileList = filelist(Input,folderList);
	print("Number of files in directory= " +fileList.length);
	Array.print(fileList);

	//j = element in fileList
	for (j=0; j<fileList.length; j++){
		print("file= "+fileList[j]);
		stringSplit = lastIndexOf(fileList[j],"_Zstack");
		saveName = substring(fileList[j], 0, stringSplit);
		print("saveName= " +saveName);
		
		//batch mode on (this is required to stand inside loop)
		setBatchMode(true);	

		//open stack
		open(Input +delim +folderList[i] +delim +fileList[j]);
		stack = getImageID();

		//batch mode off if user-input required
		if (threshold=="manual_user-defined"){
			setBatchMode(false);
		}
					
		//function OrganoidProjection
		//save edge projection
		iterMeth = 1;
		saveEdges = edgesDir +delim +saveName;
		edges = OrganoidProjection(stack);
		saveAs("PNG", saveEdges +"_edges.png");
		run("Close");

		//edge projection for segmentation
		iterMeth = 0;
		edges = OrganoidProjection(stack);	

		//batch mode off if user-input required
		if (manualCorr=="yes"){
			setBatchMode(false);
		}
		//function OrganoidSegmentation
		//iteration to be used for size cuttoff
		//iterSegment = i;
		iterSegment = 0; //WORKAROUND
		//save table
		saveNumeric = numericDir +delim +saveName;
		//save organoid segmentation
		saveGraphic= graphicDir +delim +saveName;
		//save segmented objects
		saveObjectTable= objectTableDir +delim +saveName;
		//saveObjectCut= objectCutDir +delim +saveName;		
		//OrganoidSegmentation
		//function
		OrganoidSegmentation(edges);
				
		//tidy
		run("Close All");
		roiManager("reset");				
	}
	//batch mode off
	setBatchMode(false);

	//tidy
	run("Close All");
	selectWindow("Results");
	run("Close");	
	print("Segmentation done!");
}
// */

////
////
//END Script
////

////
////
////

////
////
//BEGIN Functions
////

//GENERAL FUNCTIONS
////
//create output directory
//function
function outputdir(dirHierarchy,subdirOutput){
	print("Output directories");
	for (z=0; z<subdirOutput.length; z++){
		dirOutput = dirHierarchy +delim +subdirOutput[z];
		if (File.isDirectory(dirOutput)){
			print(dirOutput +" exists");
			print("dirOutput= " +dirOutput);
		}
		if (!File.isDirectory(dirOutput)){
			File.makeDirectory(dirOutput);
			print("created directory " +dirOutput);
			print("dirOutput= " +dirOutput);
		}	
	}
}

////
//get list of files (folders) in input directory
//function
function folderlist(Input){
	//get file list
	folders = getFileList(Input);
	//remove "/" at end of string
	for (z=0; z<folders.length; z++){
		folders[z] = replace(folders[z], "/", "");
	}
	//return
	return folders;
}

//get list of files in folders in directory
//function
function filelist(Input,folderList){
	dirInput_raw = Input +delim +folderList[iter]; //iteration is taken from loop in which function is called
	//print("dirInput_raw=" +dirInput_raw);
	//get file list
	fileList = getFileList(dirInput_raw);
	//print("fileList.length =" +fileList.length);		
	//remove "/" at end of string
	for (z=0; z<fileList.length; z++){
		fileList[z] = replace(fileList[z], "/", "");
	}
	return fileList;
}

////
//get list of .tif files in directory
//function
function tifcorrect(Input,folderList,tifPattern){
	//get fileList in folder from folderList, use function filelist
	fileList = filelist(Input, folderList);
	//print("fileList.length =" +fileList.length);
	//array that contains only .tif files in directory
	tifCorrect = newArray();
	for (z=0; z<fileList.length; z++){
		//print("z= " +z);
		if (matches(fileList[z],tifPattern[iterPattern])){
			//print(z +" is .tif");
			tifEntry = fileList[z];
			//print("tifEntry= " +tifEntry);
			//add entry to array tifContent
			tifCorrect = Array.concat(tifCorrect,tifEntry);
			//print("tifContent.length= " +tifContent.length);
		}
	}
	return tifCorrect;
}

////
////
//SPECIFIC FUNCTIONS
////
//projection of Zstacks, edge detection
//function
function OrganoidProjection(stack){
	print("running function OrganoidProjection");
	selectImage(stack);
	run("Duplicate...", "duplicate");
	edges = getImageID();
	selectImage(edges);
	//remove scale (inch on Evos)
	run("Set Scale...", "distance=0 global");
	//process stack, Z projection
	if(contrast=="yes"){
		run("Enhance Contrast...", "saturated=0.3 process_all use");
	}
	run("Find Edges", "stack");
	run("Invert", "stack");
	
	//z projection
	run("Z Project...", "projection=[" +ProjMeth[iterMeth] +"]");
	if (ProjMeth[iterMeth] =="Standard Deviation"){
		run("Invert");
	}	
	return edges;
}

////
//organoid segmentation
//function
function OrganoidSegmentation(edges){
	print("running function OrganoidSegmentation");
	selectImage(edges);
	run("Duplicate...", "title=Segmentation");
	segmentation = getImageID();
	run("8-bit");
	setAutoThreshold(ThreshMeth);
	if (threshold == "manual_user-defined"){
		run("Threshold...");
		selectWindow("Threshold");
		waitForUser("Manual threshold", "Please bring threshold window forward. \n  \nSelect threshold & press apply. \n  \nWhen done, press \"Ok\" to continue.");
	}
	if (threshold == "manual_numeric"){
		run("Threshold...");
		setThreshold(0, thresh);
		selectWindow("Threshold");
		run("Close");			
	}
	run("Convert to Mask");
	//binary: fill holes
	run("Fill Holes");
	//analyze: particle analyzer
	run("Clear Results");
	run("Set Measurements...", "area mean centroid center perimeter bounding shape feret's integrated display redirect=None decimal=1"); //"Results" measurements
	roiManager("reset")
	roiManager("Associate", "true"); //associate ROI with outlines
	roiManager("Show All");
	run("Analyze Particles...", "size=" +minSize[iterSegment] +"-" +maxSize[iterSegment] +" pixel circularity=" +minCirc[iterSegment] +"-" +maxCirc[iterSegment] +" show=Outlines display exclude clear record add");
	//show segmentation as overlay
	/*
	selectImage(edges);
	run("Remove Overlay");
	run("From ROI Manager");
	*/
	//manual ROI correction
	if (manualCorr=="yes"){
		run("Clear Results");
		selectImage(edges);
		selectWindow("ROI Manager");
		roiManager("Show None");
		roiManager("Show All");
		waitForUser("Manual ROI correction", "Please bring ROI manager forward. \n  \nStep 1: Choose selection tool and select false ROI by clicking on its number (appears blue), press \"Remove\". \nTry to tick/untick \"Show all\" if highlighting does not work. \nStep 2: Choose freehand tool and draw line around missed object. Press \"Add\". \nYou have to repeat these actions for every wrong/missing shape. \n  \nWhen done, press \"Ok\" to continue.");
		roiManager("measure");
	}
	//save table
	selectWindow("Results");
	if (threshold=="manual_numeric"){	
		//print("numerical output saved as " +"_Proj-" +ShortMeth +"_Tresh-" +threshold +"_OrganoidTable.csv");
		saveAs("Results", saveNumeric +"_Proj-" +ShortMeth +"_Tresh-" +threshold +"_OrganoidTable.csv");
	}
	if (((threshold=="manual_user-defined")|(threshold=="auto"))){			
		//print("numerical output saved as " +"_Proj-" +ShortMeth +"_OrganoidTable.csv");
		saveAs("Results", saveNumeric +"_Proj-" +ShortMeth +"_OrganoidTable.csv");
	}
	//save organoid segmentation
	selectImage(edges);
	run("Remove Overlay");
	run("From ROI Manager");
	run("Overlay Options...", "stroke=orange width=1 fill=none set apply show");
	run("Labels...", "color=red font=14 show bold");
	if (threshold=="manual_numeric"){
		//print("graphical output saved as " +"_Proj-" +ShortMeth +"_Tresh-" +threshold +"-" +thresh +"_manualROI-" +manualCorr +"_OrganoidSegment.png");
		saveAs("PNG", saveGraphic +"_Proj-" +ShortMeth +"_Tresh-" +threshold +"-" +thresh +"_manualROI-" +manualCorr +"_OrganoidSegment.png");
	}
	if (((threshold=="manual_user-defined")|(threshold=="auto"))){
		//print("graphical output saved as " +"_Proj-" +ShortMeth +"_Thresh-" +threshold +"_manualROI-" +manualCorr +"_OrganoidSegment.png");
		saveAs("PNG", saveGraphic +"_Proj-" +ShortMeth +"_Thresh-" +threshold +"_manualROI-" +manualCorr +"_OrganoidSegment.png");
	}

	//save roi table
	roiManager("save", saveObjectTable +"_ZobjectRoi.zip")

	/*
	//save each segmented object, optional
	NoRoi = roiManager("count");
	print("NoRoi= " +NoRoi);
	for (z=0; z<NoRoi; z++){
		if(z<=9){
			roi = "00" +z;
		}
		if(z>9 && z<=99){
			roi = "0" +z;
		}
		if(z>=99 && z<=999){
			roi = z;
		}
		selectImage(stack);
		roiManager("select", z);
		run("Make Band...", "band=20");
		run("Duplicate...", "duplicate");
		CutRoi = getImageID();
		run("Remove Overlay");
		selectImage(CutRoi);
		saveAs("TIFF", saveObjectCut +"_roi" +roi +"_Zobject.tif");
		selectImage(CutRoi);
		run("Close");
	}
	*/
}

////
// END of specific FUNCTIONS
////
////