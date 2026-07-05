################################
# Twisst2 results and plots
# Script based on official web: https://github.com/simonhmartin/twisst2/blob/main/plot_twisst/example_plot.R
# Some parts of this script was developed using generative AI (ChatGPT and Claude.ai). In all cases, was corrected and verified.
# 13/03/26 Mar
################################

setwd("C:/Users/Repulles/Matos Lab Dropbox/mar Repulles/PhD/MAproject/03.Populations_Heliconius/Population_analysis_R/KAY_pipeline/")

library(dplyr)
library(ggplot2)
library(GenomicRanges)

source("../plot_twisst.R") #https://github.com/simonhmartin/twisst2/blob/main/plot_twisst/example_plot.R

################################# import data ##################################
twisst_dir <- "Twisst2/out_AllsamplesAllChr_bes.eth_060526/"
intervals_files  <- sort(list.files(twisst_dir, pattern="\\.intervals\\.tsv\\.gz$", full.names=TRUE))
topocounts_files <- sort(list.files(twisst_dir, pattern="\\.topocounts\\.tsv\\.gz$", full.names=TRUE))

stopifnot(length(intervals_files) == length(topocounts_files))

# read you data and check your topos
twisst_data <- import.twisst(intervals_files=intervals_files,
                             topocounts_files=topocounts_files, ignore_extra_columns=TRUE, min_subtrees=100,  max_interval=10000)

############################
## Identify Introgression regions and size
############################

## I want to identify along the genome windows with a with a support of more than 50% of one topology
## And the region size (if the next window has also >50% support for the same topology, we sum)
## then check the size of the region for introgression suppert (bes-mel or bes-eth together)
## Check also, how many SNPs has the region (?)

### Used claude.ai top produce the function
## Function to find AND MERGE intervals where topo5 > threshold
find_topo5_intervals <- function(twisst_data, threshold = 0.5) {
  
  results <- list()
  
  for (region_name in names(twisst_data$weights)) {
    
    weights <- twisst_data$weights[[region_name]]
    interval_data <- twisst_data$interval_data[[region_name]]
    
    # Step 1: Find intervals where topo5 > threshold (if there is none, record an empty result for it and continue)
    high_topo5 <- weights$topo5 > threshold
    
    if (sum(high_topo5) == 0) {
      results[[region_name]] <- data.frame(
        chrom = character(),
        start = numeric(),
        end = numeric(),
        size = numeric(),
        n_intervals = integer(),
        mean_weight = numeric()
      )
      next
    }
    
    # Step 2: Identify runs of consecutive TRUE values
    rle_result <- rle(high_topo5)
    
    # Get end positions of each run
    end_positions <- cumsum(rle_result$lengths)
    start_positions <- c(1, end_positions[-length(end_positions)] + 1)
    
    # Filter to only runs where condition is TRUE
    true_runs <- which(rle_result$values == TRUE)
    
    merged_intervals <- data.frame(
      chrom = character(),
      start = numeric(),
      end = numeric(),
      size = numeric(),
      n_intervals = integer(),
      mean_weight = numeric(),
      stringsAsFactors = FALSE
    )
    
    for (run_idx in true_runs) {
      run_start <- start_positions[run_idx]
      run_end <- end_positions[run_idx]
      
      # Get genomic coordinates
      chrom <- interval_data$chrom[run_start]
      genomic_start <- interval_data$start[run_start]
      genomic_end <- interval_data$end[run_end]
      
      # Step 3: Calculate size
      size <- genomic_end - genomic_start + 1
      
      # Number of original intervals merged
      n_intervals <- run_end - run_start + 1
      
      # Mean topo5 weight across merged interval
      mean_weight <- mean(weights$topo5[run_start:run_end])
      
      merged_intervals <- rbind(merged_intervals, data.frame(
        chrom = chrom,
        start = genomic_start,
        end = genomic_end,
        size = size,
        n_intervals = n_intervals,
        mean_weight = mean_weight
      ))
    }
    
    results[[region_name]] <- merged_intervals
  }
  
  return(results)
}

## Run the analysis
topo5_intervals_mel80 <- find_topo5_intervals(twisst_data, threshold = 0.8)

# Combine all regions into one dataframe
all_intervals_mel80 <- do.call(rbind, lapply(names(topo5_intervals_mel80), function(r) {
  df <- topo5_intervals_mel80[[r]]
  if (nrow(df) > 0) {
    df$region <- r
    df
  } else {
    NULL
  }
}))


####### Find regions that are not share between eth and mel (unique)

all_intervals2spp <- bind_rows(
  all_intervals_mel80 %>% mutate(species = "melpomene"),
  all_intervals_eth80 %>% mutate(species = "ethilla"))

gr <- GRanges(
  seqnames = all_intervals2spp$chrom,
  ranges = IRanges(start = all_intervals2spp$start,
                   end = all_intervals2spp$end)
)

# Find overlaps between intervals, excluding self-overlaps
hits <- findOverlaps(gr, gr)
hits <- hits[queryHits(hits) != subjectHits(hits)]

# Rows involved in any overlap
overlapping_rows <- unique(c(queryHits(hits), subjectHits(hits)))

# Intervals to discard: both sides of every overlap
duplicate_intervals <- all_intervals2spp[overlapping_rows, ]

# Intervals with no overlap with any other interval
unique_intervals <- all_intervals2spp[-overlapping_rows, ]

## summary
summary_allintervals2aspp <- unique_intervals %>% group_by(species) %>%
  summarise(
    interval_number = n(),
    median_size = median(size, na.rm = TRUE),
    mean_size = mean(size, na.rm = TRUE),
    p95 = quantile(size, 0.95, na.rm = TRUE)
  ) %>%
  mutate(label = paste0(
    species, "\n",
    "n: ", interval_number, "\n",
    "median: ", round(median_size/1000, 1), " kb\n",
    "mean: ", round(mean_size/1000, 1), " kb\n",
    "p95: ", round(p95/1000, 1), " kb"
  ), y = c(Inf, Inf), vjust = c(1.2, 3.5))


##################################
# Plot twisst2 results B/D region
##################################
#################### subset to only the most abundant topologies #################

#get list of the most abundant topologies (top 2 in this case)
top_topos <- order(twisst_data$weights_overall_mean, decreasing=T)[1:3]

#subset twisst object for these
twisst_data_toptopos_eth <- subset.twisst.by.topos(twisst_data, top_topos)
#this can then be used in all the same plotting functions above.

## plot and save
colstopo <- c("#2297E6","#61D04F","#EEA236")

#png("03.5.Twisst2_BDreg_melpomene.png", width=50, height=9, units="cm", res=300)
plot.twisst(twisst_data_toptopos_mel, mode=3, show_topos=TRUE, cols=colstopo, ncol_topos=3, regions=18, include_region_names=TRUE, xlim = c(559944,1146324))
rect(738985,0,836822,1, col = NA, border="#7C873EFF")
abline(v = c(705604, 706407),col = "#DB4743FF",lwd = 3) #only gene Optix 
#dev.off()

################ subset to only specific regions #########################

#regions to keep (more than one can be specified)
chr18 <- c("region18")
chr21 <- c("region21")
#subset twisst object for these
twisst_data_toptopos_eth_chr18 <- subset.twisst.by.regions(twisst_data_toptopos_eth, chr18)
twisst_data_toptopos_eth_chr21 <- subset.twisst.by.regions(twisst_data_toptopos_eth, chr21)

plot.twisst.summary.boxplot(twisst_data_toptopos_eth,cols=colstopo)
plot.twisst.summary.boxplot(twisst_data_toptopos_eth_chr18,cols=colstopo)
plot.twisst.summary.boxplot(twisst_data_toptopos_eth_chr21,cols=colstopo)
