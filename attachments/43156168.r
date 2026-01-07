
##########################################################################################
##    This code will give you info on 30 vertebrate functional groups   		        ##
##	 Info is: total biomass, biomass-at-age, numbers-at-age, length-at-age              ##
##                      and structural nitrogen-at-age                                  ##
##	  The code is now designed for vertebrates only, as it expects four dimensional     ##
##                                variables from the .nc file                           ##
##                 Download and install MASS and ncdf libraries for R 					##
## 	If you want to add or remove functional groups you would have to change the three   ##
##  text files that are used as inputs (functionalGroups.txt, functionalNames.txt and   ##
## 	                          abParam.txt                                               ##
##  Talk to Asta if you want some help on how to adapt the code for your needs          ##
##########################################################################################


setwd("C:/atlantis/R")   # SET YOUR WORKING DIRECTORY
rm(list=ls())
library(MASS)			
library(ncdf)

ThisNC.nc<-open.ncdf("C:/atlantis/results/ncfiles/ams_2000SevM06F0.nc") #give the name of your .nc file. It will take a while to load this .nc file so be patient

pdf(file="results.pdf",onefile=TRUE)    #give the name of the .pdf file to save figures in. This will save graphical output to one .pdf file. So there will be no graphical output to screen. 

funcgr <- read.table(file="functionalGroups.txt",sep=",",header=FALSE)   #This is the list of functional groups as it is referred to in the .nc file
funcname <- read.table(file="functionalNames.txt",sep=",",header=FALSE) #These names are for legends on the figures, you can change them the way you want, but make sure there are still 30 of them
abparam <- read.table(file="abParam.txt",header=FALSE) #These are the a and b parameters of length-weight relationship to get length-at-age from the weight information

NFG <- 30 #give the number of functional groups

volumeData <- get.var.ncdf( ThisNC.nc,"volume") # extract the data from the variable. Used to find out the number of years used in the run
len <-length(volumeData[1,1,])

mycol <- rainbow(10) #this will create ten colours used to plot ten age classes. You can change the number of colours to create

for (n in 1:NFG) {

ReN <- array(data=NA,c(5,56,c(len),10))
StN <- array(data=NA,c(5,56,c(len),10))
Num <- array(data=NA,c(5,56,c(len),10))
Len <- array(data=NA,c(c(len),10))
StNm <- array(data=NA,c(c(len),10))
aaa <- funcname[1,n]
aaa <- as.character(aaa)
bbb <- funcgr[1,n]

for (i in 1:10) {
	ReN.temp <- get.var.ncdf(ThisNC.nc,paste(funcgr[1,n],i,"_ResN",sep="")) 
	ReN.temp <- ReN.temp[-6,,] #delete the bottom layer
	ReN.temp <- ReN.temp[,-c(1,13,23,24,36,49,50,58:64,66),] #delete boundary boxes
	ReN[,,,i] <- ReN.temp #this will give a four dimensional matrix (layer, box, year, age-group) of reserve nitrogen without bottom layer and boundary boxes 
	}

for (i in 1:10) {

	StN.temp <- get.var.ncdf(ThisNC.nc,paste(funcgr[1,n],i,"_StructN",sep="")) 
	StN.temp <- StN.temp[-6,,] #delete the bottom layer
	StN.temp <- StN.temp[,-c(1,13,23,24,36,49,50,58:64,66),] #delete boundary boxes
	StN[,,,i] <- StN.temp #same as above for structural nitrogen
	}

for(i in 1:10) {
	Num.temp <- get.var.ncdf(ThisNC.nc,paste(funcgr[1,n],i,"_Nums",sep="")) 
	Num.temp <- Num.temp[-6,,] # delete the bottom layer
	Num.temp <- Num.temp[,-c(1,13,23,24,36,49,50,58:64,66),] #delete 15 boundary boxes
	Num[,,,i] <- Num.temp # same as above for numbers
	}

BiomLayBoxTimeAge <- ((StN+ReN)*Num)*5.7*20/1000000000 #biomax in tons per layer/box/time/age
BiomBoxTimeAge <- colSums(BiomLayBoxTimeAge) #sums over layers to produce a three dimensional matrix of box-year-age class biomass
BiomTimeAge <- colSums(BiomBoxTimeAge) #sums over boxes to produce two dimensional matrix of year-age class
NumTimeAge <- colSums(colSums(Num)) #sums over layers and boxes, gives matrix of time and age classes - two dimensional matrix
Biom <- rowSums(BiomTimeAge) #sums over age classes - main series of flathead total biomass over time - one dimensional array
IndMass <- (ReN+StN)*5.7*20/1000 #convert dry N weight to wet weight in g - four dim matrix 
IndLen <- ((IndMass)/abparam[n,1])^(1/abparam[n,2]) #calculate length - four dim matrix of layers-boxes-years-age classes


for (i in 1:5) { #turn zero elements in the four dimensional matrices to NA so that the average can be taken
	for (j in 1:56) {
		for (o in 1:71) {
			for (m in 1:10) {
				if (IndLen[i,j,o,m]<0.0001) {
					IndLen[i,j,o,m]=NA
					}
				if (StN[i,j,o,m]<0.0001) {
					StN[i,j,o,m]=NA
					}					
				}
			}
		}
	}
					

for (i in 1:71) {
	for (j in 1:10) {
		Len[i,j]<- mean(IndLen[,,i,j],na.rm=TRUE) #here we take an average ind length over all layers and boxes. It is quite similar in all the boxes and layers, but some boxes have slightly bigger fish. This produces two dimensional matrix of lengths over time and age classes. In contrast to biomass and numbers we can't sum over boxes and layers, so we take an average. 
		StNm[i,j]<- mean(StN[,,i,j],na.rm=TRUE) #here we take an average of structural nitrogen over all layers and boxes. It is quite similar in all the boxes and layers, but some boxes have slightly bigger fish. Just as above
		}
	}
	
  

#start plotting the results
par(mfrow=c(3,2),oma=c(2,2,2,1),mar=c(2,4,1,1)) #mar indicates a margin, x,y,top margin and right margin

#Plot total biomass over time
plot(Biom,type="l",lwd=1.5,ylab="Total biomass") 

#Plotting biomass at age over time
plot(BiomTimeAge[,1],col=mycol[1],type="l",lwd=1.5,ylim=c(min(BiomTimeAge[,1:10]),max(BiomTimeAge[,1:10])),ylab="Biomass at age") 
for (i in 2:10) {
	points(BiomTimeAge[,i],type="l",lwd=1.5,col=mycol[i])
	}

#Plotting numbers at age over time
plot(NumTimeAge[,1],type="l",col=mycol[1],lwd=1.5,ylim=c(min(NumTimeAge[,1:10]),max(NumTimeAge[,1:10])),ylab="Numbers at age") 	
for (i in 2:10) {
	points(NumTimeAge[,i],type="l",lwd=1.5,col=mycol[i])
	}

#Plotting length-at-age over time
plot(Len[,1],type="l",col=mycol[1],lwd=1.5,ylim=c(min(Len[,1:10],na.rm=TRUE),max(Len[,1:10],na.rm=TRUE)),ylab="Length-at-age") 
for (i in 2:10) {
	points(Len[,i],type="l",lwd=1.5,col=mycol[i])
	}

#Plotting structural nitrogen at-age over time
plot(StNm[,1],type="l",col=mycol[1],lwd=1.5,ylim=c(min(StNm[,1:10],na.rm=TRUE),max(StNm[,1:10],na.rm=TRUE)),ylab="Structural N at age") 
for (i in 2:10) {
	points(StNm[,i],type="l",lwd=1.5,col=mycol[i])
	}	
	
mtext(aaa,3,outer=TRUE,line=1) #main title of the graph	
}

dev.off() #close the pdf printing device
