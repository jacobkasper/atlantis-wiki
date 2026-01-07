#' Code to correct bgm
#' 
#' Reads in values and writes prm
#' @author Hem Nalini Morzaria Luna, email\{hmorzarialuna@gmail.com}
#' @keywords Puget Sound, Atlantis
#' 
#' February 2019
#' 
# this script corrects incorrect inside points in the bgm caused because
# the geographic centroid falls outside the boundaries of their parent polygon
# used point in surface as described here
# https://geocompr.robinlovelace.net/geometric-operations.html

# List of packages for session
.packages = c("rgdal","PBSmapping","tidyverse","maptools","sp", "data.table","rgeos","sf")


# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst], dependencies = TRUE)

# Load packages into session 
lapply(.packages, require, character.only=TRUE)

#' clean up the space

rm(list=ls())

#read bgm file that needs correcting
bgm.file <- "PugetSound_89b_070116_original.bgm"
corrected.bgm.file <- "PugetSound_89b_070116.bgm"

#read polygon shapefile
ps.polygons <- readOGR(".", "bgm_Puget_Sound_89b_0p0001_NAD83") %>% st_as_sf()

#get centroids
ps.centroids <- st_point_on_surface(ps.polygons)

#use this to plot centroids over polygons
plot(ps.polygons["BOX_ID"], reset = FALSE)
plot(ps.centroids["BOX_ID"], add = TRUE, col = "red")

#combine parameter name and centroid values
centroid.data <- st_coordinates(ps.centroids) %>% 
  as.data.frame() %>% 
  mutate(index = as.numeric(as.character(ps.centroids$BOX_ID)), box = paste0("box",index,".inside"),entry_name = paste(box,X,Y, sep = " "))

#scan bgm file
bgm.data <-  scan(bgm.file, character(0), sep = "\n") %>% 
  enframe(name = NULL) 

bgm.rows <- 1:nrow(centroid.data)

#replaces each centroid value for rows in the bgm
for(thisrow in bgm.rows){
  
  this.data <- centroid.data[thisrow,]
  
  this.bgm.name <- paste0(this.data$box,"*.*")
  this.bgm.value <- this.data$entry_name
  
  bgm.data <- bgm.data %>% 
    mutate(value=gsub(this.bgm.name,this.bgm.value,value))

}


#add line breaks so the bgm will be formatted properly
bgm.corrected <- bgm.data %>% 
           deframe()

#write bgm
cat(bgm.corrected,file=corrected.bgm.file, sep="\n",fill=FALSE, append=FALSE)
