#######################################
## Plotting D stats with VCF output
# Stats run with ABBABABAwindows.py and pixy (Dxy)
# Some parts of this script was developed using generative AI (ChatGPT and Claude.ai). In all cases, was corrected and verified.
# 13/03/26 Mar
#######################################

library(dplyr)
#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")
#BiocManager::install("GenomicRanges")
library(GenomicRanges)
library(ggplot2)

setwd("C:/Users/Repulles/Matos Lab Dropbox/mar Repulles/PhD/MAproject/03.Populations_Heliconius/Population_analysis_R/KAY_pipeline/")

#######################################
# load and filter the tables of D stats 
#######################################
## read the tables
stats_table_eth05 = read.csv("ABBA-BABA_Allsamples/D_Allsamples_eth_var_5kb.csv.gz", as.is=T)
stats_table_eth10 = read.csv("ABBA-BABA_Allsamples/D_Allsamples_eth_var_10kb.csv.gz", as.is=T)
stats_table_eth50 = read.csv("ABBA-BABA_Allsamples/D_Allsamples_eth_var_50kb.csv.gz", as.is=T)

stats_table_mel05 = read.csv("ABBA-BABA_Allsamples/D_Allsamples_mel_var_5kb.csv.gz", as.is=T)
stats_table_mel10 = read.csv("ABBA-BABA_Allsamples/D_Allsamples_mel_var_10kb.csv.gz", as.is=T)
stats_table_mel50 = read.csv("ABBA-BABA_Allsamples/D_Allsamples_mel_var_50kb.csv.gz", as.is=T)

### Filter the tables
## extract only the big Scaffolds
chr <- c("Hmel201001o","Hmel202001o","Hmel203003o","Hmel204001o","Hmel205001o","Hmel206001o",
         "Hmel207001o","Hmel208001o","Hmel209001o","Hmel210001o","Hmel211001o","Hmel212001o",
         "Hmel213001o","Hmel214004o","Hmel215003o","Hmel216002o","Hmel217001o","Hmel218003o",
         "Hmel219001o","Hmel220003o","Hmel221001o")
tables <- list(stats_table_eth05,stats_table_eth10, stats_table_eth50, stats_table_mel05, stats_table_mel10, stats_table_mel50)
tables <- lapply(tables, function(x) x[x$scaffold %in% chr, ])

## convert fd to 0 when D is negative 
##(fd is meaningless when D is negative, as it is designed to quantify the excess of ABBA over BABA only when an excess exists.)
## for table list fd zero when D is negative
tables <- lapply(tables, function(x) {x$fd <- ifelse(x$D < 0,0,x$fd); x})

# make 2 variables (fdNA and DNA) with values to zero when NA (only for plotting purpose)
tables <- lapply(tables, function(x) {x$fdNA <- ifelse(is.na(x$fd), 0, x$fd); x})
tables <- lapply(tables, function(x) {x$DNA <- ifelse(is.na(x$D), 0, x$D); x})

## convert list elements back to separate objects
stats_table_eth05 <- tables[[1]]
stats_table_eth10 <- tables[[2]]
stats_table_eth50 <- tables[[3]]

stats_table_mel05 <- tables[[4]]
stats_table_mel10 <- tables[[5]]
stats_table_mel50 <- tables[[6]]

#################
### Dxy files
#################
dxy_eth_05kb <- read.table("pixy/Allsamples_eth_Allsites_5kb_sliding_dxy.txt", header=TRUE)
dxy_eth_10kb <- read.table("pixy/Allsamples_eth_Allsites_10kb_sliding_dxy.txt", header=TRUE)
dxy_eth_50kb <- read.table("pixy/Allsamples_eth_Allsites_50kb_sliding_dxy.txt", header=TRUE)

## melp
dxy_mel_05kb <- read.table("pixy/Allsamples_mel_Allsites_5kb_sliding_dxy.txt", header=TRUE)
dxy_mel_10kb <- read.table("pixy/Allsamples_mel_Allsites_10kb_sliding_dxy.txt", header=TRUE)
dxy_mel_50kb <- read.table("pixy/Allsamples_mel_Allsites_50kb_sliding_dxy.txt", header=TRUE)

unique(dxy_mel_50kb$pop2)
unique(dxy_eth_10kb$pop2)

## Subset of Dxy of only my spp of interest
dxy_eth_05kb <- subset(dxy_eth_05kb, pop1=="besckei" & pop2=="narcaea")
dxy_mel_05kb <- subset(dxy_mel_05kb, pop1=="besckei" & pop2=="nanna")

dxy_eth_10kb <- subset(dxy_eth_10kb, pop1=="besckei" & pop2=="narcaea")
dxy_mel_10kb <- subset(dxy_mel_10kb, pop1=="besckei" & pop2=="nanna")

dxy_eth_50kb <- subset(dxy_eth_50kb, pop1=="besckei" & pop2=="narcaea")
dxy_mel_50kb <- subset(dxy_mel_50kb, pop1=="besckei" & pop2=="nanna")

################################################################
### FIND WINDOWS INTR (Genome screening)
################################################################
#### Look for windows that met the 3 conditions (based on optix region results):
## D value < 0.87
## fd value < 0.75 (for 5 and 10kb windows) and fd < 0.50 (for 50 kb W)
## Dxy < percentile 0.25 of Dxy chromosome mean

#### MERGE TABLES by windows (D stats and Dxy)
## I did D stats and Dxy by sliding windows, so I will have a lot of windows --> after finding sliding windows, find the whole region

#ethilla
merged_eth_05kb <- dxy_eth_05kb %>% inner_join(
  stats_table_eth05,
  by = c("chromosome"="scaffold","window_pos_1"="start","window_pos_2"="end"))

merged_eth_10kb <- dxy_eth_10kb %>% inner_join(
  stats_table_eth10,
  by = c("chromosome"="scaffold","window_pos_1"="start","window_pos_2"="end"))

merged_eth_50kb <- dxy_eth_50kb %>% inner_join(
  stats_table_eth50,
  by = c("chromosome"="scaffold","window_pos_1"="start","window_pos_2"="end"))

#melpomene
merged_mel_05kb <- dxy_mel_05kb %>% inner_join(
  stats_table_mel05,
  by = c("chromosome"="scaffold","window_pos_1"="start","window_pos_2"="end"))

merged_mel_10kb <- dxy_mel_10kb %>% inner_join(
  stats_table_mel10,
  by = c("chromosome"="scaffold","window_pos_1"="start","window_pos_2"="end"))

merged_mel_50kb <- dxy_mel_50kb %>% inner_join(
  stats_table_mel50,
  by = c("chromosome"="scaffold","window_pos_1"="start","window_pos_2"="end"))

### Filter the rows that met the conditions
## 50kb
# eth
filt_merged_eth_50kb <- merged_eth_50kb %>%
  group_by(chromosome) %>%
  filter(
    fd > 0.5,
    D > 0.87,
    #avg_dxy < mean(avg_dxy, na.rm = TRUE) #lower than mean (best opt?)
    avg_dxy < quantile(avg_dxy, 0.25, na.rm = TRUE) #lower than 10percentil
  ) %>%
  ungroup()
# mel
filt_merged_mel_50kb <- merged_mel_50kb %>%
  group_by(chromosome) %>%
  filter(
    fd > 0.5,
    D > 0.87,
    #avg_dxy < mean(avg_dxy, na.rm = TRUE) #lower than mean (best opt?)
    avg_dxy < quantile(avg_dxy, 0.25, na.rm = TRUE) #lower than 10percentil
  ) %>%
  ungroup()

## 10kb
# eth
filt_merged_eth_10kb <- merged_eth_10kb %>%
  group_by(chromosome) %>%
  filter(
    fd > 0.75,
    D > 0.87,
    #avg_dxy < mean(avg_dxy, na.rm = TRUE) #lower than mean (best opt?)
    avg_dxy < quantile(avg_dxy, 0.25, na.rm = TRUE) #lower than 10percentil
  ) %>%
  ungroup()
# mel
filt_merged_mel_10kb <- merged_mel_10kb %>%
  group_by(chromosome) %>%
  filter(
    fd > 0.75,
    D > 0.87,
    #avg_dxy < mean(avg_dxy, na.rm = TRUE) #lower than mean (best opt?)
    avg_dxy < quantile(avg_dxy, 0.25, na.rm = TRUE) #lower than 10percentil
  ) %>%
  ungroup()

## 10kb
# eth
filt_merged_eth_05kb <- merged_eth_05kb %>%
  group_by(chromosome) %>%
  filter(
    fd > 0.75,
    D > 0.87,
    #avg_dxy < mean(avg_dxy, na.rm = TRUE) #lower than mean (best opt?)
    avg_dxy < quantile(avg_dxy, 0.25, na.rm = TRUE) #lower than 10percentil
  ) %>%
  ungroup()
# mel
filt_merged_mel_05kb <- merged_mel_05kb %>%
  group_by(chromosome) %>%
  filter(
    fd > 0.75,
    D > 0.87,
    #avg_dxy < mean(avg_dxy, na.rm = TRUE) #lower than mean (best opt?)
    avg_dxy < quantile(avg_dxy, 0.25, na.rm = TRUE) #lower than 10percentil
  ) %>%
  ungroup()

###### Calculate introgressed region size (contiguous)
## function to merge positive windows into regions
merge_regions <- function(df,gapwidth) {
  
  gr <- GRanges(
    seqnames = df$chromosome,
    ranges = IRanges(
      start = df$window_pos_1,
      end   = df$window_pos_2
    )
  )
  
  merged_regions <- reduce(gr, min.gapwidth = gapwidth)
  
  data.frame(
    chr = seqnames(merged_regions),
    start = start(merged_regions),
    end = end(merged_regions),
    size_bp = width(merged_regions)
  )
}

regions_df_mel_05kb <- merge_regions(filt_merged_mel_05kb, gapwidth = 5000)
regions_df_mel_10kb <- merge_regions(filt_merged_mel_10kb, gapwidth = 10000)
regions_df_mel_50kb <- merge_regions(filt_merged_mel_50kb, gapwidth = 50000)

regions_df_eth_05kb <- merge_regions(filt_merged_eth_05kb, gapwidth = 5000)
regions_df_eth_10kb <- merge_regions(filt_merged_eth_10kb, gapwidth = 10000)
regions_df_eth_50kb <- merge_regions(filt_merged_eth_50kb, gapwidth = 50000)

# mean size
mean(regions_df_mel_05kb$size_bp)
mean(regions_df_mel_10kb$size_bp)
mean(regions_df_mel_50kb$size_bp)

mean(regions_df_eth_05kb$size_bp)
mean(regions_df_eth_10kb$size_bp)
mean(regions_df_eth_50kb$size_bp)

# merge all data
mel_regions <- bind_rows(
  regions_df_mel_05kb %>% mutate(species = "mel", resolution = "5kb"),
  regions_df_mel_10kb %>% mutate(species = "mel", resolution = "10kb"),
  regions_df_mel_50kb %>% mutate(species = "mel", resolution = "50kb")
)

eth_regions <- bind_rows(
  regions_df_eth_05kb %>% mutate(species = "eth", resolution = "5kb"),
  regions_df_eth_10kb %>% mutate(species = "eth", resolution = "10kb"),
  regions_df_eth_50kb %>% mutate(species = "eth", resolution = "50kb")
)

## Merge overlapping regions
merge_regions_all <- function(df,gapwidth) {
  
  gr <- GRanges(
    seqnames = df$chr,
    ranges = IRanges(
      start = df$start,
      end   = df$end
    )
  )
  
  merged_regions <- reduce(gr, min.gapwidth = gapwidth)
  
  data.frame(
    chr = seqnames(merged_regions),
    start = start(merged_regions),
    end = end(merged_regions),
    size_bp = width(merged_regions)
  )
}

regionsAll_nonOverlapping_mel <- merge_regions_all(mel_regions, gapwidth = 1)
regionsAll_nonOverlapping_eth <- merge_regions_all(eth_regions, gapwidth = 1)

######################
## Find unique regions
######################
# Look for regions that are not shared between ethilla and melpomene datasets
mel_gr <- GRanges(
  seqnames = regionsAll_nonOverlapping_mel$chr,
  ranges = IRanges(start = regionsAll_nonOverlapping_mel$start,
                   end = regionsAll_nonOverlapping_mel$end)
)

eth_gr <- GRanges(
  seqnames = regionsAll_nonOverlapping_eth$chr,
  ranges = IRanges(start = regionsAll_nonOverlapping_eth$start,
                   end = regionsAll_nonOverlapping_eth$end)
)

# For each mel region, count how many eth regions it overlaps (0 = unique to mel)
mel_hits <- countOverlaps(mel_gr, eth_gr)
eth_hits <- countOverlaps(eth_gr, mel_gr)

mel_unique <- regionsAll_nonOverlapping_mel[mel_hits == 0, ]
eth_unique <- regionsAll_nonOverlapping_eth[eth_hits == 0, ]

mel_shared <- regionsAll_nonOverlapping_mel[mel_hits > 0, ]
eth_shared <- regionsAll_nonOverlapping_eth[eth_hits > 0, ]

# Quick summary
tibble::tibble(
  species = c("mel", "eth"),
  total = c(nrow(regionsAll_nonOverlapping_mel), nrow(regionsAll_nonOverlapping_eth)),
  unique = c(nrow(mel_unique), nrow(eth_unique)),
  shared = c(nrow(mel_shared), nrow(eth_shared))
)
# mean values
mean(regionsAll_nonOverlapping_mel$size_bp)
mean(regionsAll_nonOverlapping_eth$size_bp)
median(regionsAll_nonOverlapping_mel$size_bp)
median(regionsAll_nonOverlapping_eth$size_bp)


########################
#### plot Optix reg
########################

plotfile <- merged_eth_05kb
filtfile <- filt_merged_eth_05kb

scale_factor <- 1 / 0.004  # brings dxy to ~0–1 scale
dxy_mean <- mean(plotfile$avg_dxy, na.rm = TRUE)

nameDstats <- "D statistics and Dxy over 05 kb sliding windows for the ethilla dataset" 
p4 <- ggplot() +
  #coord_cartesian( ylim = c(0,1)) +
  coord_cartesian(xlim = c(500000, 1200000), ylim = c(0,1)) +
  annotate("rect", xmin = 559944, xmax = 1146324, ymin = -Inf, ymax = Inf,
           fill = "#FEF4D5FF", alpha = 0.5) +
  annotate("rect", xmin = 738985, xmax = 836822, ymin = -Inf, ymax = Inf,
           fill = "#7C873EFF", alpha = 0.3) +
  annotate("rect", xmin = 705604, xmax = 706407, ymin = -Inf, ymax = Inf,
           fill = "#E69F00", alpha = 1) +
  geom_hline(yintercept = dxy_mean * scale_factor,
             color = "#CD0BBC", linetype = "dashed", linewidth = 0.9) +
  
  geom_line(data = plotfile[plotfile$chromosome == "Hmel218003o", ], aes(x = mid, y = DNA), color = "grey", linewidth = 0.8) +
  geom_line(data = plotfile[plotfile$chromosome == "Hmel218003o", ], aes(x = mid, y = D), color = "black", linewidth = 0.9) +
  geom_line(data = plotfile[plotfile$chromosome == "Hmel218003o", ], aes(x = mid, y = fdNA), color = "grey50", linewidth = 0.8) +
  geom_line(data = plotfile[plotfile$chromosome == "Hmel218003o", ], aes(x = mid, y = fd), color = "#DB4743FF", linewidth = 1) +
  geom_line(data = plotfile[plotfile$chromosome == "Hmel218003o", ],aes(x = window_pos_1,y=avg_dxy*scale_factor),
            color = "#CD0BBC", linewidth = 1) +
  
  geom_point(data = filtfile[filtfile$chromosome == "Hmel218003o", ],
             aes(x = mid, y = fd),shape=25,
             fill = "#2297E6", color= "#2297E6", size = 2) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.05)),
    name = "D / fd",sec.axis = sec_axis(~ . / scale_factor, name = "Dxy")) +
  labs(title = nameDstats) +
  scale_x_continuous(labels = scales::label_number(scale = 1e-3),name = "Position (kb)") +
  theme_bw(base_size = 16)

## save
library(patchwork)
plot10kb <- p1/p2
final_plot <- p3/p4/p5/p6

ggsave("05.5.Allsamples_chr18_DstatsDxy_slidingW_05&50kb.png",
       final_plot,
       width = 35, height = 17, dpi = 300, limitsize = FALSE)
