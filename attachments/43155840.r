#PlotOutNC_NandRN


#   This plots Biomass (all groups) and reserve N (all Vertebrates) over time. 
#   See/check/change the user defined block of parameters below. 
#   It expects two things in the working directory: 
#    FuncGroupNamesInPlotOrder.csv  , with four columns: 1)NetCDFName (like "Planktiv_S_Fish_N"); 2) CODE, like "FVO"; and 3) EMOCCName, like "Migrating Bird", and 4) Virgin Biomass/ Current Biomass, like 10. (No headers; Put "NA" if you want some subplots to be blank)
#    VertGroupNamesInPlotOrder.csv , with 2 columns: 1) NetCDFVertName, like "Planktiv_S_Fish1_ResN",and 2) EMOCCVertName, like "Small Planktivore" (No headers)
 #   AssessOrSurveyData.csv, with 1st column as year, columns 2-max are biomass of each functional group in each year. NAs are ok. 

#ToDO:This should really use matplot() to make plots faster
# Isaac Kaplan isaac.kaplan@noaa.gov 
#---------

#rm(list=ls())


library(ncdf)

#-------------
# USER CAN DEFINE INPUT FILES, STARTYEAR, TIMESTEP, SAVE DIRECTORY, ETC. HERE:  
#Here are some things that are hardcoded, but change here if you want. 
year0<-1971      #1964   # or whatever is appropriate. 
fishingStartYear<-1981     #1967  #All this does is draw a red vertical line on the plots. 
numStepsPerYear<-3  #Number of output intervals per year. With output intervals of 122 days, this is = 3. 
wantSubtitle<-TRUE  # Set this to true, to print graph subtitles, allows you to make sure the NetCDF name matches the Common Name used in the title. 
plotRowsPerPage<-3   #number of rows of subplots you want per page
plotColsPerPage<-2   # number of columns of subplots you want per page
setwd('C:/Atlantis/EMOCC_ParamsDataPaper/Manuscripts') # set working directory, place with  CSV file (see below)
pathToSavePlots<-"C:/TestTex/"
FuncGroupNamesInPlotOrder<-read.table("FuncGroupNamesInPlotOrder.csv",as.is = TRUE,header=TRUE,sep=",") # For the Biomass vs. Time plots here. Any order is ok, but that order will specify plot order. "NA" will leave a subplot blank. 

AssessOrSurveyData<-read.table("AssessOrSurveyData.csv",as.is = TRUE,header=TRUE,sep=",") # Assessment or survey data. Column 1 is year, other cols are MT biomass per year
print('**** AssessOrSurveyData.csv must have functional groups in same order...')
print('    ...as FuncGroupNamesInPlotOrder.csv (including NAs)***** ')
VertNamesInPlotOrder<-read.table("VertNamesInPlotOrder.csv",as.is = TRUE,header=FALSE,col.names=c("NetCDFVertName","EMOCCVertName"),sep=",") # For the rN vs. time plots below. It should have # rows=10*numVertebrates (one per age class). Any order is ok, but that order will specify plot order. "NA" will leave a subplot blank. 

print('**** OPENING THE NETCDF FILE CAN TAKE 5 MINUTES ***** ')
print('**** YOU CAN TRY USING save() and load() TO AVOID THIS IN THE FUTURE***** ')
ThisNC.nc<-open.ncdf("EmoccOut10YrSpinup.nc") #EmoccOutFeb2BF.nc Y:/ecosystem/EMOCC_Atlantis/IndicatorsAIFRB/FATEresults/EmoccOutPlanktonLink1.nc")   #Y:/ecosystem/EMOCC_Atlantis/IndicatorsAIFRB/BethsFeb2FmultResults/F0pt05/EmoccOut0pt05.nc")  #EmoccOut0pt075EmoccOutAug21 moccOutFeb2BF  EmoccOutJan30bNoFish.ncAMS: amsFCoutput12Mar.nc neusintHistoutput.nc"EmoccOutJan30bNoFish.nc EmoccOutFeb2BF.nc EmoccOutJan24a.nc Open NetCDF file
save(ThisNC.nc,file="EmoccOutJan30bNoFish.Rdata")
#load (file="neusintHistoutput.Rdata") 

 # END OF DEFINITION BLOCK. USER CAN PROBABLY IGNORE EVERYTHING BELOW
 #-----------

VirginBToCurrentB <- FuncGroupNamesInPlotOrder$VirgBToCurrentB

plotsPerPage<-plotRowsPerPage*plotColsPerPage

graphics.off()

volumeData <- get.var.ncdf( ThisNC.nc,"volume") # extract the data from the variable. The variable contains lots of other metainfo like units, name, etc.
volDims<-dim(volumeData)  # Just use volume to see how many time steps are in the data
volBottomCells<-volumeData[volDims[1],,] # Because dz (height) of lowest boxes is 1m,I can say that Area is equal to the volume of the lowest boxes 
dz <- get.var.ncdf( ThisNC.nc,"dz") 
numDepths<-dim(dz)[1]
zBottomCell<- dz[numDepths,1,1]
areaData<-volBottomCells/zBottomCell

#-----------------------------------------------------
# MAKE PLOTS OF ABUNDANCE OVER TIME


numTimeSteps<-volDims[3]
rowscols<-dim(FuncGroupNamesInPlotOrder) # count how many species are in this data
numFuncGroups<-rowscols[1]

plotNum<-0
simYears<-(year0+(seq(1,numTimeSteps)/numStepsPerYear))  # Get some x values for the plot (time)

#LOOP OVER ALL FUNCTIONAL GROUPS
for (funcGroup in 1:numFuncGroups )      
{ 
     print(FuncGroupNamesInPlotOrder$EMOCCName[funcGroup])
     
   # If we are on Functional Group number 1, 7, 13,19, [i.e. want a fresh page for subplots], set up the plot page 
    if (((funcGroup-1)%%plotsPerPage)==0)  
    {  
    plotNum<-plotNum+1  
    BiomassPlotNameString<-paste(pathToSavePlots, "BiomassPlot",plotNum,".eps",sep="") # create a string to use as the file name
    postscript(file=BiomassPlotNameString, onefile=FALSE, horizontal=FALSE) # give the plot that filename
    par(mfrow=c(plotRowsPerPage,plotColsPerPage)) # lay out the 3x2 blank plots
    }
     
     
     #NOW DEFINE Y VALUES AND LABELS FOR THE PLOT, AS LONG AS THE SPECIES NAME IS NOT "NA" ( the .csv input file, FuncGroupNamesInPlotOrder, could contain NA's in place of a species name, if you wanted for instance 5 plots on one page, plus a blank square. In these instances, skip the plotting below 
     if (!is.na(FuncGroupNamesInPlotOrder$NetCDFName[funcGroup]))  
     {
        maxYForPlot<-1    # set up a y limit max, which will change below
        thisData <- get.var.ncdf( ThisNC.nc,FuncGroupNamesInPlotOrder$NetCDFName[funcGroup])  # Extract data from variable
        # IF WE HAVE A 2D SPECIES LIKE AN INVERT....
        if (length(dim(thisData))==2)  
        {
            thisY<-apply(thisData*areaData,2,sum)*(5.7*20/10^9)
            yLabString<-'Biomass, metric tons'
        }
             # IF WE HAVE A 3D THING THAT IS NH3, N03, Chla, Carrion, we leave it in mg N/m^3  
        if( FuncGroupNamesInPlotOrder$NetCDFName[funcGroup]=='NH3'| FuncGroupNamesInPlotOrder[funcGroup,1]=='NO3'| FuncGroupNamesInPlotOrder[funcGroup,1]=='Chl_a' | FuncGroupNamesInPlotOrder[funcGroup,1]=='Carrion_N' )  
         {
            thisY<-apply(thisData*volumeData,3,sum)/apply(volumeData,3,sum)
            yLabString<-'mg N/m^3'
         }
          # IF WE HAVE A 3D SPECIES LIKE A FISH (not Nuts,Chla, or Carrion)...
        if( length(dim(thisData))==3 &  !FuncGroupNamesInPlotOrder$NetCDFName[funcGroup]=='NH3' &  !FuncGroupNamesInPlotOrder[funcGroup,1]=='NO3' &  !FuncGroupNamesInPlotOrder[funcGroup,1]=='Chl_a' &  !FuncGroupNamesInPlotOrder[funcGroup,1]=='Carrion_N' )  
        {
            thisY<-apply(thisData*volumeData,3,sum)*(5.7*20/10^9)
            yLabString<-'Biomass, metric tons'
        }
        
        
        #MAKE THE PLOT
        assessOrSurveyMT<-AssessOrSurveyData[,funcGroup+1]  # add 1 because 1st column is year, and then the columns are in order for the plots. 
        YYear1 <- thisY[1]
        testVec<-c(maxYForPlot,1.1*max(thisY),YYear1*VirginBToCurrentB[funcGroup],assessOrSurveyMT) # Calculate max Y value needed to show in plot       
        maxYForPlot<-max(testVec[!is.na(testVec)])
        
        plot(simYears,thisY,lwd=4,type='l',cex.lab=1.5,cex.axis=2, col='black',lty='dotdash',ylab=yLabString,main=FuncGroupNamesInPlotOrder$EMOCCName[funcGroup],xlab='Year',ylim=c(0,maxYForPlot ),cex.main=2)
        if (wantSubtitle)
        {
        title(sub=FuncGroupNamesInPlotOrder$NetCDFName[funcGroup])
        }
        lines(x=c(0,max(simYears)),y=c(YYear1*VirginBToCurrentB[funcGroup],YYear1*VirginBToCurrentB[funcGroup]),lty='dashed',lwd=2,col='green')
        lines(x=c(fishingStartYear, fishingStartYear ),y=c(0,maxYForPlot),lty='dashed',lwd=2,col='red')
        lines(x=AssessOrSurveyData$Year,y=assessOrSurveyMT,lwd=3,col='black')
         

         
     
     }
    
   # If we are on Functional Group number 6, 12, 18,24, [i.e. the plotpage is full], close the plot
   if (((funcGroup)%%plotsPerPage)==0)    
   {
        dev.off()  # close the device
   }
    
}


#-------------------------------------------------------
#PLOT RESERVE NITROGEN OVER TIME: 

print('rN over time')
rowsCols<-dim(VertNamesInPlotOrder)
numCohortsAllSpp<-rowsCols[1]
plotNum<-0

for (funcGroup in 1:(numCohortsAllSpp/10) )     # loop over all functional groups (there are 10 age classes per functinal group)
{
     
    if (((funcGroup-1)%%plotsPerPage)==0)   # if we are on Functional Group number 1, 7, 13,19, etc. 
    {  
    plotNum<-plotNum+1
    rNPlotNameString<-paste(pathToSavePlots,"rNPlot",plotNum,".eps",sep="")
    print(rNPlotNameString)
    postscript(file=rNPlotNameString, onefile=FALSE, horizontal=FALSE) #, height=8, width=8, pointsize=16).
    par(mfrow=c(plotRowsPerPage,plotColsPerPage)) # lay out the 3x2 blank plots
    }
     


#-----------------
 # All this loop does is  find the max Y value for this rN  plot (10 age classes, one functional group)   
     maxYForPlot<-1.1  # set up a y limit max, which will change below
     for (ageclass in 1:10) # loop over all 10 age classes
     {
     #thisVar <- ThisNC.nc$var[[ SppRnIndices[(funcGroup-1)*10+ageclass] ]]  # Extract variable
     thisData <- get.var.ncdf( ThisNC.nc,VertNamesInPlotOrder$NetCDFVertName[((funcGroup-1)*10+ageclass)])  # Extract data from variable
     thisData[thisData==0]<-NA  # Replace 0's with NA
     thisDataMeanMg<-apply(thisData,3,mean,na.rm = TRUE)#Get mean size over time, averaging over depth and location 
     thisY<-thisDataMeanMg/thisDataMeanMg[1]  # Normalize by initial value
     maxYObserved<-max(thisY,na.rm=TRUE)
     maxYForPlot<-max(c(maxYForPlot,1.1*maxYObserved),na.rm=TRUE) # Calculate max Y value needed to show in plot
    }

#-----------------

     for (ageclass in 1:10) # loop over all 10 age classes
     {
     #thisVar <- ThisNC.nc$var[[ SppRnIndices[(funcGroup-1)*10+ageclass] ]]  # Extract variable
     thisData <- get.var.ncdf( ThisNC.nc,VertNamesInPlotOrder$NetCDFVertName[((funcGroup-1)*10+ageclass)])  # Extract data from variable
     thisData[thisData==0]<-NA  # Replace 0's with NA
     thisDataMeanMg<-apply(thisData,3,mean,na.rm = TRUE)#Get mean size over time, averaging over depth and location 
     thisY<-thisDataMeanMg/thisDataMeanMg[1]  # Normalize by initial value
     #maxYForPlot<-max(c(maxYForPlot,1.1*max(thisY))) # Calculate max Y value needed to show in plot
     rainbowColors<-rainbow(10)    # Make a rainbow color palette for plotting. 
     speciesName<-VertNamesInPlotOrder$EMOCCVertName[funcGroup*10]
      
         if (ageclass==1)  # If we are plotting age class 1, start a new plot
         {
            plot(simYears,thisY,cex.lab=1.5, cex.axis=2,lwd=0.5,type='l',ylab='rN / initial rN',main=speciesName,cex.main=2, xlab='Year',ylim=c(0,maxYForPlot ),lty=ageclass,col = rainbowColors[ageclass])
             print(speciesName)
         }
         else  # If we are doing age class 2 or higher, just add lines to the existing plot made for Age class 1. 
         {
           lines(simYears,thisY,lwd=0.5,type='l',lty=ageclass,col = rainbowColors[ageclass])
             
         }
    }  
     lines(x=c(0,max(simYears)),y=c(1,1),lty='dashed',lwd=2,col='black')
     if (wantSubtitle)
     {
     title(sub=VertNamesInPlotOrder$NetCDFVertName[funcGroup*10])
     }
   if (((funcGroup)%%plotsPerPage)==0)    
   {
        dev.off()  # close the device
   }

    
}

#--------------
# JUST LIST ALL THE VARIABLES IN THE NCDF FILE
# THIS CODE JUST PRINTS VARIABLE NAMES TO SCREEN, BUT CAN BE USEFUL FOR MAKING THE .CSV INPUT FILES. 
print('LISTING ALL VARIABLE NAMES IN THE NETCDF FILE')
numVarsInNC<-length(ThisNC.nc$var)

for (groupIndex in 1:numVarsInNC )   
{
     thisVar <- ThisNC.nc$var[[groupIndex]]  
     print(thisVar$name)    
}
print('THE LISTING ABOVE IS ALL VARIABLE NAMES IN CDF')
print('THIS MAY BE USEFUL FOR MAKING .CSV INPUT FILES')

close.ncdf(ThisNC.nc)
