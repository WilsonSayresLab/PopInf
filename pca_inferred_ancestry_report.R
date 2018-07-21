#!/usr/bin/Rscript
# Authors: Angela Taravella and Anagha Deshpande
#usage: pca_inferred_ancestry_report.R evec_file eval_file reference_panel_info.txt unkpop_info.txt output_fileSetemName output_inferredPopReport_fileStemName


### LOAD PACKAGES ###
library("car")
library("plotrix")


### DEFINE FUNCTIONS ###
# Function 1: circle_function #
# circle_function plots centroid of each population coordinate along with plotting 1, and 3 standard deviation circles around the cluster mean.
circle_function <- function(continent) {
  continent_of_choice <- continent
  continent_of_choice_data <- evec_file_full[evec_file_full$V3.x %in% continent_of_choice,]
  mean_x <- mean(continent_of_choice_data$V2.y)
  mean_y <- mean(continent_of_choice_data$V3.y)
  points(mean_x, mean_y, pch = 3, cex = 1)
  test <- sqrt( ((mean_x - (continent_of_choice_data$V2.y))^2) + ((mean_y - (continent_of_choice_data$V3.y))^2) )
  radius <- sqrt(sum((test-0)^2/(length(test)-1)))
  draw.circle(mean_x, mean_y, radius)
  draw.circle(mean_x, mean_y, radius*3)
}

# Function 2: Get centroid coordinates and radii for each population cluster  #
circle_function_noplot <- function(continent) {
  continent_of_choice <- continent
  continent_of_choice_data <- evec_file_full[evec_file_full$V3.x %in% continent_of_choice,]
  mean_x <- mean(continent_of_choice_data$V2.y)
  mean_y <- mean(continent_of_choice_data$V3.y)
  test <- sqrt( ((mean_x - (continent_of_choice_data$V2.y))^2) + ((mean_y - (continent_of_choice_data$V3.y))^2) )
  radius <- sqrt(sum((test-0)^2/(length(test)-1)))
  my_list <- list("radius" = radius, "mean_x" = mean_x, "mean_y" = mean_y)
  return(my_list)
}


### SET UP COMMAND INPUTS ###
args = commandArgs(trailingOnly=TRUE)
evec = args[1]
eval = args[2]
pop = args[3]
unkpop = args[4]
out = args[5]
out_inferred_report = args[6]


### SET UP OUTPUT PDF ###
pfdfilename <- paste(out,".pdf",sep="")
pdf(pfdfilename, 8,8) #save as pdf, with size 8x8


### READ IN DATA ###
evec_file <- read.table(evec, header = FALSE)
eval_file <- read.table(eval, header = FALSE)
known_population_file <- read.table(pop, header = FALSE, sep = "\t")
unkownpop_file <- read.table(unkpop, header = FALSE, sep = "\t")

print("All data has been imported into the program")


### SET UP INITIAL DATA FRAMES ###
known_sample_info_merge <- merge(known_population_file, evec_file,  by.x = "V1", by.y = "V1")
UnkownPop_data_WithInfo <- merge(unkownpop_file, evec_file, by.x = "V1", by.y = "V1")
evec_file_full <- rbind(known_sample_info_merge, UnkownPop_data_WithInfo)


### CALCULATE PERCENT VARIANCE EXPLAINED FOR EACH PC ###
eval_file$Perc_Var<- prop.table(eval_file$V1)*100

print("Plotting has started")

### PLOTTING ###
# Set up colors
n_colors <- length(levels(evec_file_full$V3.x))
rainbowcols <- rainbow(n_colors)

# Generate the legend
plot(1, type="n", axes=FALSE, xlab="", ylab="", main = "Key", cex=1.5)
legend('topleft', bty="n", legend = c(levels(evec_file_full$V3.x)), fill = c(rainbowcols),
       cex = 1, title=expression(bold("Populations")))
legend('top', bty="n", legend = c(levels(evec_file_full$V2.x)),
       cex = 1, pch = c(2, 1)[evec_file_full$V2.x], title=expression(bold("Genetic Sex")))



# Plot the graphs of the first 10 PCs
i <- 1
a <- 0
pc1 <- 0
pc2 <- 0
while (i<10)
{
  j <- 4 + a
  z <- 5 + a
  pc1 <- eval_file[i,2]
  pc1 <- round(pc1, digits = 2)
  axis_pc1 <- paste("PC",i," (",pc1,"%)",sep="")
  pc2 <- eval_file[j,2]
  pc2 <- round(pc2, digits = 2) # round so number doesnt have a lot of decimal places
  axis_pc2 <- paste("PC",i+1," (",pc2,"%)",sep="")
  plot(evec_file_full[,j],evec_file_full[,z], xlab = axis_pc1, ylab = axis_pc2,
       col=c(rainbowcols)[evec_file_full$V3.x], pch =c(16, 17)[evec_file_full$V2.x], asp = 1, 
       par(cex.axis=1.5,cex.lab=2))
  i <- i+2
  a <- a + 1

}

### SET UP OUTPUT INFERRED POPULATION REPORT ###
inferredpopreport <- paste(out_inferred_report,".txt",sep="")


### INFERRED ANCESTRY REPORT ###
print("Inferred population report has started")

# Generate the legend for the plot with cluster and midpoint info
plot(1, type="n", axes=FALSE, xlab="", ylab="", main = "Key")
legend('topleft', bty="n", legend = c(levels(evec_file_full$V3.x)), fill = c(rainbowcols),
       cex = 1, title=expression(bold("Populations")))
legend('top', bty="n", legend = c(levels(evec_file_full$V2.x)),
       cex = 1, pch = c(2, 1)[evec_file_full$V2.x], title=expression(bold("Genetic Sex")))
legend('left', bty="n", legend = c("Cluster Centroid",
                                   "1 and 3 Standard Deviations from Cluster Mean",
                                   "Pair-wise Cluster Mid Points"),
       cex = 1, pch = c(3, 1, 4))

# Plot
plot(evec_file_full[,4],evec_file_full[,5], xlab = "PC1", ylab = "PC2",
     col=c(rainbowcols)[evec_file_full$V3.x], pch =c(16, 17)[evec_file_full$V2.x], asp = 1,
     par(cex.axis=1.5,cex.lab=2))

# Print all clusters onto the scatter plot
test_vector <- levels(known_sample_info_merge$V3.x)
for (i in 1:length(test_vector)) {
  circle_function(test_vector[i])
}


### Store relevant information in matricies ###
# Stores values of radius, mean X, and mean Y in a martrix called "mat_meanx_meany_rad"
n <- length(test_vector)
mat_meanx_meany_rad <- matrix(ncol=4, nrow=n)
test_vector <- levels(known_sample_info_merge$V3.x)
for (i in 1:length(test_vector)) {
  my_list <- circle_function_noplot(test_vector[i])
  mat_meanx_meany_rad[i,] <- c(test_vector[i],my_list$mean_x,my_list$mean_y,my_list$radius)
}

# Find the mid point (X and Y coordinates) for each pairwise comparison and store in a matrix called "mat_meanx_meany_compares"
n_com <- factorial(length(test_vector))/((factorial((length(test_vector)-2)))*factorial(2))
mat_meanx_meany_compares <- matrix(ncol=4, nrow=n_com)
combination_num <- 0

for (i in 1:length(test_vector)) {
  num <- i + 1
  for (num in i:length(test_vector)) {
    if (num > length(test_vector)) {}
    else {
      if (test_vector[i] == test_vector[num]) {}
      else {
        comparison <- c(test_vector[i], test_vector[num])
        my_list <- circle_function_noplot(test_vector[i])
        test_mean_x_first <- my_list$mean_x
        test_mean_y_first <- my_list$mean_y

        my_list <- circle_function_noplot(test_vector[num])
        test_mean_x_second <- my_list$mean_x
        test_mean_y_second <- my_list$mean_y

        x_mid <- (test_mean_x_first+test_mean_x_second)/2
        y_mid <- (test_mean_y_first+test_mean_y_second)/2

        points(x_mid,y_mid, col = "black", pch = 4)
        comparison_name <- paste(test_vector[i], test_vector[num], sep = "-")
        combination_num <- combination_num + 1
        mat_meanx_meany_compares[combination_num,] <- c(comparison_name,x_mid,y_mid,0)
      }
    }
  }
}

### Generate inferred population report ###
row_num <- length(UnkownPop_data_WithInfo[,1])
col_num <- length(test_vector) + 5
df <- data.frame(matrix(ncol = col_num, nrow = row_num))
vector_col_names <- c("Sample",
                      "Confident Inferred Pop: 1SD",
                      "Confident Inferred Pop: 2SD",
                      "Confident Inferred Pop: 3SD",
                      "Less Restricted Inferred Pop")
for (i in 1:length(test_vector)) {
  col_name_cluster_i <- paste("Distance to cluster", test_vector[i], sep = " ")
  vector_col_names <- c(vector_col_names, col_name_cluster_i)
}
colnames(df) <- vector_col_names


iterator <- 0
for (i in UnkownPop_data_WithInfo[,1]) {

  iterator <- iterator + 1
  sample_i <- paste(UnkownPop_data_WithInfo[iterator,1])
  pc_x <- UnkownPop_data_WithInfo[iterator,4]
  pc_y <-  UnkownPop_data_WithInfo[iterator,5]

  vector_to_add_df <- c(sample_i)

  inferred_pop_1SD <- c()
  inferred_pop_2SD <- c()
  inferred_pop_3SD <- c()

  test_all_for_ans_1SD <- FALSE
  test_all_for_ans_2SD <- FALSE
  test_all_for_ans_3SD <- FALSE

  for (cluster in 1:length(mat_meanx_meany_rad[,1])) {
    x <- as.numeric(mat_meanx_meany_rad[cluster,2])
    y <- as.numeric(mat_meanx_meany_rad[cluster,3])
    dist_i_to_cluster_centriod <- sqrt( ((x - pc_x)^2) + ((y - pc_y)^2) )

    sd_1 <- as.numeric(mat_meanx_meany_rad[cluster,4])
    if (dist_i_to_cluster_centriod <= sd_1) {
      test_all_for_ans_1SD <- TRUE
      inferred_pop_1SD <- paste(inferred_pop_1SD, mat_meanx_meany_rad[cluster,1], sep = " ")
    }

    sd_2 <- as.numeric(mat_meanx_meany_rad[cluster,4]) * 2
    if (dist_i_to_cluster_centriod <= sd_2) {
      test_all_for_ans_2SD <- TRUE
      inferred_pop_2SD <- paste(inferred_pop_2SD, mat_meanx_meany_rad[cluster,1], sep = " ")
    }

    sd_3 <- as.numeric(mat_meanx_meany_rad[cluster,4]) * 3
    if (dist_i_to_cluster_centriod <= sd_3) {
      test_all_for_ans_3SD <- TRUE
      inferred_pop_3SD <- paste(inferred_pop_3SD, mat_meanx_meany_rad[cluster,1], sep = " ")
    }

  }

  if (!test_all_for_ans_1SD) {
    inferred_pop_1SD <- "-"
  }
  if (!test_all_for_ans_2SD) {
    inferred_pop_2SD <- "-"
  }
  if (!test_all_for_ans_3SD) {
    inferred_pop_3SD <- "-"
  }

  vector_to_add_df <- c(vector_to_add_df, inferred_pop_1SD, inferred_pop_2SD, inferred_pop_3SD)
  less_rest_inf_pop <- c()
  cat_points <- rbind(mat_meanx_meany_rad, mat_meanx_meany_compares)
  n_all <- length(cat_points[,1])
  com_all_pnts <- matrix(ncol=2, nrow=n_all)
  if (inferred_pop_3SD == "-"){
    for (test_all_pts in 1:length(cat_points[,1])) {
      if (cat_points[test_all_pts,4] != 0){
        x <- as.numeric(cat_points[test_all_pts,2])
        y <- as.numeric(cat_points[test_all_pts,3])
        dist_i_to_centroid <- sqrt( ((x - pc_x)^2) + ((y - pc_y)^2) )
        dist_i_to_pnt <- abs(dist_i_to_centroid - (3*as.numeric(mat_meanx_meany_rad[test_all_pts,4])))
      } else {
        x <- as.numeric(cat_points[test_all_pts,2])
        y <- as.numeric(cat_points[test_all_pts,3])
        dist_i_to_pnt <- sqrt( ((x - pc_x)^2) + ((y - pc_y)^2) )
      }
      com_all_pnts[test_all_pts,] <- c(cat_points[test_all_pts,1],dist_i_to_pnt)
      index_num <- which(com_all_pnts == min(com_all_pnts)) - n_all
      less_rest_inf_pop <- com_all_pnts[index_num]
    }
  } else {less_rest_inf_pop <- inferred_pop_3SD}

  vector_to_add_df <- c(vector_to_add_df, less_rest_inf_pop)

  for (cluster in 1:length(mat_meanx_meany_rad[,1])) {
    x <- as.numeric(mat_meanx_meany_rad[cluster,2])
    y <- as.numeric(mat_meanx_meany_rad[cluster,3])
    dist_i_to_cluster_centriod <- sqrt( ((x - pc_x)^2) + ((y - pc_y)^2) )
    cluster_dist_i <- format(round(dist_i_to_cluster_centriod, 5), nsmall = 5)
    vector_to_add_df <- c(vector_to_add_df, cluster_dist_i)
  }

  df[iterator, ] = vector_to_add_df
}

write.table(df, inferredpopreport, sep = "\t", quote = F, row.names = F)

dev.off() # close pdf

