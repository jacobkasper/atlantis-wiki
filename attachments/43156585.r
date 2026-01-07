####################################################################################################################################
#
#
#	Purpose: Write an R script that will generate an output file in a similar structure to the BiomIndx.txt output file
#		from Atlantis but shows the biomass in individual boxes of interes.	
#
#	How to use: Update the values in the 'USER VALUES' block to point to your existing Atlantis output files, tell it 
#			which boxes you are interested in and what you want your output file to be called.
#
#	Warning: This is my first R script ever so there are probably much much better ways to do everything. If you know R
#		please let me know what I could have done better.
#
#	Author: Bec Gorton bec.gorton@csiro.au
#	09-August-2011
#
####################################################################################################################################


library(ncdf)

####################################################################################################################################
#	USER VALUES
#
#
#
####################################################################################################################################
# To change scenario just change this line only.
ncdfCDFFileName = "C:/Atlantis/RunFiles/VMPA run/vmpa_base run/vmpaoutput_base.nc";

# don't worry about changing these two.

# If you are only interested in a subset of the groups then you can edit the list of groups in your
# funct group file to just include the groups you are interested in. This will make this script run
# heaps faster as it will only do the calcs for the smaller number of groups.
FunctGroupFileName = "C:/Atlantis/Rscripts/functionalGroups.csv";
bgmFileName = "C:/Atlantis/RunFiles/VMPA run/VMPA80.bgm";

# Name of the file you want to create.
outputFile = "C:/Atlantis/Rscripts/outputData.txt";

# Which boxes in your model are a boundary box? You can set verbose to 2 in your run.prm file
# then just run your model for a single day. The info about boundary boxes will be written to 
# standard error which you can redirect to a file using 2>out2.txt.
boundaryBoxes = c(0, 2, 3, 5, 19, 50, 56, 77, 78, 79);

numSedLayers = 1;	# In all existing Atlantis models there is only a single sediment layer.

# The list of boxes you are interested in.
#boxes = array(0:79, dim=c(80));	# This will produce data for all boxes.It will take a long time. Run overnight.
boxes = c(10, 11, 12)	# Just generate data for boxes 10, 11 and 12, - remember your boxes start at 0.

# If set to TRUE the values in the boxes specified will be added together, if FALSE the values are shown per box.
addBoxvalues = TRUE;	


####################################################################################################################################
#	DON"T CHANGE ANYTHING BELOW HERE!!!
#
#
#
####################################################################################################################################

####################################################################################################################################
# Work out which boxes are boundary boxes
boundaryIndexValues = boundaryBoxes + 1;
boxesOfInterest = boxes + 1;

####################################################################################################################################
# Now read in the biomass Data.

ThisNC.nc = open.ncdf(ncdfCDFFileName);
FuncGroupNamesInPlotOrder<-read.table(FunctGroupFileName,as.is = TRUE,header=TRUE,sep=",");

volumeData <- get.var.ncdf( ThisNC.nc,"volume") # extract the data from the variable. The variable contains lots of other metainfo like units, name, etc.
volDims<-dim(volumeData)  # Just use volume to see how many time steps are in the data
volBottomCells<-volumeData[volDims[1],,] # Because dz (height) of lowest boxes is 1m,I can say that Area is equal to the volume of the lowest boxes 
dz <- get.var.ncdf( ThisNC.nc,"dz")
numDepths<-dim(dz)[1];
zBottomCell<- dz[numDepths,1,1]
areaData<-volBottomCells/zBottomCell

numBoxes = length(boxesOfInterest);
numYears = volDims[3];
numWCLayers = numDepths - numSedLayers;
startSedIndex = numWCLayers + 1;

rowscols<-dim(FuncGroupNamesInPlotOrder) # count how many species are in this data
numFuncGroups<-rowscols[1]
#numFuncGroups<- 3;
yearlyBiomass = array(0, dim=c(numBoxes, numYears, numFuncGroups));
biomass = array(0, dim =c(numFuncGroups, numYears, numBoxes, numDepths));

#set up the boxes string.
boxesString = "";
for(index in 1:numBoxes){
  boxesString = paste(boxesString, boxes[index], "");
}

####################################################################################################################################
# 	Time Data
####################################################################################################################################

# timeData <- get.var.ncdf( ThisNC.nc,"t") # extract the data from the variable. The variable contains lots of other metainfo like units, name, etc.
# timeData = timeData / 24*24*60;
#####################################################################################################################################
#	Read in data from the BGM file.
#
#
#
####################################################################################################################################
bgmFile = file(bgmFileName, "r", blocking = FALSE)

data = readLines(bgmFile);
close(bgmFile);

boxIndex = 1;
boxArea = array(0, dim=c(numBoxes))
boxBotZ = array(0, dim=c(numBoxes))
maxwcbotz = NaN;
for (index in 1:length(data)){

  # grab the maxBotx  
  if(regexpr( "maxwcbotz", data[index]) > 0){
    print(data[index]);
    area = sub("maxwcbotz", "", data[index])
    area = sub(" ", "", area);	
    area = sub("\t", "", area);	
    print(area);
    maxwcbotz = -1* as.double(area);
  }

  # grab the box area,
  if(regexpr( ".area", data[index]) > 0){
    #print(data[index]);

    # grab the box id.
    area = sub("box.*.area\t", "", data[index])
    area = sub(" ", "", area);		
    #print(area)
    boxArea[boxIndex] =  as.double(area);
    #print(boxArea[boxIndex])
    boxIndex = boxIndex + 1;
  }

  # grab the box bottom z value.
  if(regexpr( ".botz", data[index]) > 0){
    #print(data[index]);

    # grab the box id.
    area = sub("box.*.botz\t", "", data[index])
    area = sub(" ", "", area);		
    #print(area)
    boxBotZ[boxIndex] = -1* as.double(area);
    #print(boxBotZ[boxIndex])
   
  }
}

if(is.nan(maxwcbotz))
  print("Failed to find maxwcbotz in the bgm file");

#####################################################################################################################################
#	
#	Calculate the biomass data for each functional group.
#	
#
#####################################################################################################################################
for (funcGroup in 1:numFuncGroups )
{
  # Vertebrates first.
  if(FuncGroupNamesInPlotOrder$isVertebrate[funcGroup] == 1){
    biomass[funcGroup]<- 0;
    value = 0;
    for (cohort in 1:10){
      varName = paste(FuncGroupNamesInPlotOrder$Diag.Name[funcGroup],  cohort, "_Nums", sep="")

      if (is.null(ThisNC.nc$var[[varName]])){
	      print("No data");
	      print(varName);
      }else{
	      NumsData <- get.var.ncdf( ThisNC.nc,varName);

	      varName = paste(FuncGroupNamesInPlotOrder$Diag.Name[funcGroup],  cohort, "_StructN", sep="")
	      structNData <- get.var.ncdf( ThisNC.nc,varName);
	      varName = paste(FuncGroupNamesInPlotOrder$Diag.Name[funcGroup],  cohort, "_ResN", sep="")
	      resNData <- get.var.ncdf( ThisNC.nc,varName);

	      biomassData= (structNData + resNData) * NumsData;

	      # Set data to 0 where its a boundary box.
	      biomassData[, boundaryIndexValues,] = 0;

	      for (year in 1:numYears){
	        for(boxIndex in 1:numBoxes){
	          box = boxesOfInterest[boxIndex];
	          yearlyBiomass[boxIndex, year, funcGroup] = yearlyBiomass[boxIndex, year, funcGroup] + sum(biomassData[1:numDepths, box, year]);
	        }
	      }
      }
    }
  }else{

     if(FuncGroupNamesInPlotOrder$NumCohorts[funcGroup] > 1){

      # Allow for the 2 cohorts - will sum over the cohorts to get a single total per group.
      for (cohort in 1:2){
	      varName = paste(FuncGroupNamesInPlotOrder$Long.Name[funcGroup], "_N", cohort, sep="")
	
	      if (is.null(ThisNC.nc$var[[varName]])){
        		print("No data");
        		print(varName);
	      }else{

		      thisData <- get.var.ncdf( ThisNC.nc,varName);

		      # Set data to 0 in the boundary boxes.
		      thisData[, boundaryIndexValues,] = 0;

		      for (year in 1:numYears){
		        for(boxIndex in 1:numBoxes){
		          box = boxesOfInterest[boxIndex];
		          for(layerIndex in 1:numWCLayers){
		            # tracer values are in mg N m-3 so we need to mult by the box area and layer depth.
		            x = boxArea[box] * dz[layerIndex,box, year] * thisData[layerIndex, box, year];
		            yearlyBiomass[boxIndex, year, funcGroup] = yearlyBiomass[boxIndex, year, funcGroup] + x;
		          }	
		          if(boxBotZ[box] <= maxwcbotz){
		            for(layerIndex in startSedIndex: numDepths){
			            # tracer values are in mg N m-3 so we need to mult by the box area and layer depth.
			            x = boxArea[box] * dz[layerIndex,box, year] * thisData[layerIndex,box, year];
			            yearlyBiomass[boxIndex, year, funcGroup] = yearlyBiomass[boxIndex, year, funcGroup] + x;
		            }
		          }
		        }
		      }
	      }
      }
    }else{
      varName = paste(FuncGroupNamesInPlotOrder$Diag.Name[funcGroup], "_N", sep="")

      if (is.null(ThisNC.nc$var[[varName]])){
        print("No data");
        print(varName);
      }else{
        thisData <- get.var.ncdf( ThisNC.nc,varName);

        # Is this variable a 2 or 3 D? If 2D then its an epibenthic tracer and we just need to worry about box and year.
        if (length(dim(thisData))==2)        {

          # Set data to 0 in the boundary boxes.
          thisData[boundaryIndexValues,] = 0;
          for (year in 1:numYears){
            for(boxIndex in 1:numBoxes){
	            box = boxesOfInterest[boxIndex];
	            # tracer values are in mg N m-2 so we need to mult by the box area (not dz as we are in 2D world)
	            x = boxArea[box] * thisData[box, year];
	            yearlyBiomass[boxIndex, year, funcGroup] = yearlyBiomass[boxIndex, year, funcGroup] + x;
            }
          }
        }else{
          # Set data to 0 in the boundary boxes.
          thisData[, boundaryIndexValues,] = 0;
          for (year in 1:numYears){
            for(boxIndex in 1:numBoxes){
              box = boxesOfInterest[boxIndex];

              # Only include WC values if this group lives in the WC. Should be 0 if it doesn't live there but pop the check in just in case.
              if(FuncGroupNamesInPlotOrder$WC_COEFF[funcGroup] > 0){

                for(layerIndex in 1:numWCLayers){
                  # tracer values are in mg N m-3 so we need to mult by the box area and layer depth.
                  x = boxArea[box] * dz[layerIndex, box, year] * thisData[layerIndex, box, year];
                  yearlyBiomass[boxIndex, year, funcGroup] = yearlyBiomass[boxIndex, year, funcGroup] + x; 
                }
              }
              # Only include SED values if this group lives in the SED. Should be 0 if it doesn't live there but pop the check in just in case.
              if(FuncGroupNamesInPlotOrder$SED_COEFF[funcGroup] > 0){

                if(boxBotZ[box] <= maxwcbotz){
                  for(layerIndex in startSedIndex: numDepths){
	                  # tracer values are in mg N m-3 so we need to mult by the box area and layer depth.
	                  x = boxArea[box] * dz[layerIndex, box, year] * thisData[layerIndex, box, year];
	                  yearlyBiomass[boxIndex, year, funcGroup] = yearlyBiomass[boxIndex, year, funcGroup] + x; 
                  }
                }
              }
	          }
	        }    
	      }
	    }
    }
  }
}
#####################################################################################################################################
#
#	Output the data to the output file.
#
#
#####################################################################################################################################
# Convert to net weight in tonnes.
yearlyBiomass = yearlyBiomass* 5.7*20/10^9;


if(addBoxvalues){
  # Set up the column names.
  names = c("TimeStep", FuncGroupNamesInPlotOrder$Code);
  Heading = c("Biomass data - sum of boxes " , boxesString);
  # Pop the box number in slot 1 in the output data so the boxID ends up in the correct place in the output file.
  outputData = array(-1, dim=c(numYears, numFuncGroups));
  for(year in 1:numYears){
    # sum all the boxes together.
    for(boxIndex in 1:numBoxes){
      for (funcGroup in 1:numFuncGroups ){
        outputData[year, funcGroup] = outputData[year, funcGroup] + yearlyBiomass[boxIndex, year, funcGroup];
      }
    }
  }
  
  # Now print it all out to the output file. There must be a better way of doing this!
  write.table(Heading, outputFile, FALSE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
           col.names = FALSE, qmethod = c("escape", "double"))
  write.table(t(names), outputFile, TRUE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
           col.names = FALSE, qmethod = c("escape", "double"))
  write.table(outputData[ ,], outputFile, TRUE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = TRUE,
          col.names = FALSE, qmethod = c("escape", "double"))
  
}else{
  # Set up the column names.
  names = c("TimeStep", "Box", FuncGroupNamesInPlotOrder$Code);
  emptyLine = array(" ", numFuncGroups + 2);

   # Pop the box number in slot 1 in the output data so the boxID ends up in the correct place in the output file.
  bigIndex = numFuncGroups + 1;
  outputData = array(-1, dim=c(numBoxes, numYears, bigIndex));
  for(boxIndex in 1:numBoxes){
    box = boxes[boxIndex];
    for(year in 1:numYears){
      outputData[boxIndex, year, 1] = box;
      outputData[boxIndex, year, 2:bigIndex] = yearlyBiomass[boxIndex, year, ];
    }
  }

  # Now print it all out to the output file. There must be a better way of doing this!
  index = 1;
  for(boxIndex in 1:numBoxes){
    if(index == 1){
      # Note the FALSE here on the append parameter, all others are true so we add to the end of the file.
      write.table(t(names), outputFile, FALSE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
               col.names = FALSE, qmethod = c("escape", "double"))
      write.table(outputData[boxIndex, ,], outputFile, TRUE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = TRUE,
              col.names = FALSE, qmethod = c("escape", "double"))
    }else{
      write.table(t(names), outputFile, TRUE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
               col.names = FALSE, qmethod = c("escape", "double"))
      write.table(outputData[boxIndex,, ], outputFile, TRUE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = TRUE,
              col.names = FALSE, qmethod = c("escape", "double"))
    }
     write.table(t(emptyLine), outputFile, TRUE, FALSE, " ", eol = "\n", na = "NA", dec = ".", row.names = FALSE,
               col.names = FALSE, qmethod = c("escape", "double"))

    index = index + 1;
  }
}
