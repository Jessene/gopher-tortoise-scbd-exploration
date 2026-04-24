---
  
# Description: Rose plot of Species Contribution to Beta Diversity (SCBD)
#              Camera trap data from Gopher Tortoise burrows, southeast Florida.
#              Companion analysis to Huffman et al. 2025 (Southeastern Naturalist).
#              Uses abundance-based Hellinger-transformed beta diversity; the
#              published paper used presence-absence data for its main analyses.
# Author: Jessene Aquino-Thomas
# Date: 13/Jun/2022
# Last Edited: 2/Feb/2023
# Cleaned up for GitHub: 23/Apr/2026
# Output: rose_plot_scbd.png
  
---


# Load Libraries 
library(tidyverse)
library(vegan)
library(adespatial)


# Import csv file 
camera_all <- read.csv(file = "Camera Study.csv")

# Checking that data imported correctly 
head(camera_all)
str(camera_all)
colnames(camera_all)


# Changing column name to something easier to type
names(camera_all)[names(camera_all) == 'ï..Site'] <- "site"


# making site a factor
camera_all$site <- as.factor(camera_all$site)

# combine site and habitat into one column
camera_all$site.habitat <- paste(camera_all$site, camera_all$Habitat.type, 
                                 sep = "/")
# making site/habitat a factor
camera_all$site.habitat <- as.factor(camera_all$site.habitat)



####Subset species data by site/habitat####

# FAU Grass
camera_all_species.FG <- camera_all[ ,13:58] %>% 
  filter(site.habitat == "FAU/Grass")

# FAU Scrub
camera_all_species.FS <- camera_all[ ,13:58] %>% 
  filter(site.habitat == "FAU/Scrub")

# Jonathan Dickinson Scrub 
camera_all_species.JS <- camera_all[ ,13:58] %>% 
  filter(site.habitat == "JDSP/Scrub")

# Pine Jog Pine Flatwoods 
camera_all_species.PP <- camera_all[ ,13:58] %>% 
  filter(site.habitat == "PJP/Pine")



####Sum observations per species for each site####

# sum the observations for each species/column for the site 
colsumspecies.FG <- colSums(camera_all_species.FG[sapply(camera_all_species.FG, 
                                                         is.numeric)])
# making into data frame 
colsumspecies.FG <- as.data.frame(colsumspecies.FG)
# rename the column 
colsumspecies.FG <- colsumspecies.FG %>% 
  rename(observations = "colsumspecies.FG")
#changing the column name and turning into the the tidyverse tibble 
colsumspecies.FG <- tibble::rownames_to_column(colsumspecies.FG, "Species")


colsumspecies.FS <- colSums(camera_all_species.FS[sapply(camera_all_species.FS, 
                                                         is.numeric)])
colsumspecies.FS <- as.data.frame(colsumspecies.FS)
colsumspecies.FS <- colsumspecies.FS %>% 
  rename(observations = "colsumspecies.FS")
colsumspecies.FS <- tibble::rownames_to_column(colsumspecies.FS, "Species")


colsumspecies.JS <- colSums(camera_all_species.JS[sapply(camera_all_species.JS, 
                                                         is.numeric)])
colsumspecies.JS <- as.data.frame(colsumspecies.JS)
colsumspecies.JS <- colsumspecies.JS %>% 
  rename(observations = "colsumspecies.JS")
colsumspecies.JS <- tibble::rownames_to_column(colsumspecies.JS, "Species")


colsumspecies.PP <- colSums(camera_all_species.PP[sapply(camera_all_species.PP, 
                                                         is.numeric)])
colsumspecies.PP <- as.data.frame(colsumspecies.PP)
colsumspecies.PP <- colsumspecies.PP %>% 
  rename(observations = "colsumspecies.PP")
colsumspecies.PP <- tibble::rownames_to_column(colsumspecies.PP, "Species")



####Combine sites into one wide-format matrix####

# reorganizes datasheet wide
colsumspecies.FG_wide <- colsumspecies.FG %>% 
  pivot_wider(names_from = "Species", 
              values_from = "observations") 
# add column with site
colsumspecies.FG_wide <- colsumspecies.FG_wide %>%
  add_column(site = "FG", .before = "BasiliskLizard")

colsumspecies.FS_wide <- colsumspecies.FS %>% 
  pivot_wider(names_from = "Species", 
              values_from = "observations") 
colsumspecies.FS_wide <- colsumspecies.FS_wide %>%
  add_column(site = "FS", .before = "BasiliskLizard")

colsumspecies.JS_wide <- colsumspecies.JS %>% 
  pivot_wider(names_from = "Species", 
              values_from = "observations") 
colsumspecies.JS_wide <- colsumspecies.JS_wide %>%
  add_column(site = "JS", .before = "BasiliskLizard")

colsumspecies.PP_wide <- colsumspecies.PP %>% 
  pivot_wider(names_from = "Species", 
              values_from = "observations") 
colsumspecies.PP_wide <- colsumspecies.PP_wide %>%
  add_column(site = "PP", .before = "BasiliskLizard")


# bind the four sites together 
colsumspecies.wide <- bind_rows(colsumspecies.FG_wide, colsumspecies.FS_wide,
                                colsumspecies.JS_wide, colsumspecies.PP_wide)

View(colsumspecies.wide)



####Calculate species contribution to beta diversity (SCBD)####

# Hellinger-transformed beta diversity 
# NOTE: this is abundance-based; the published paper used presence-absence data. 
BDRB <- beta.div(colsumspecies.wide[ ,-1], method = "hellinger")
RBSCBD = data.frame(BDRB$SCBD)
RBSCBD <- as_tibble(rownames_to_column(RBSCBD, var = "SPECIES"))


# pull the 10 species with the largest SCBD values for the plot 
abun <- RBSCBD[c(8, 16, 17, 18, 20, 25, 33, 34, 38, 39), ]



####Rose plot of top SCBD species####
# NOTE: silhouettes around the plot were added manually after export, 
# using public-domain images. The plot below is the base figure.

rose_plot <- ggplot(abun, aes(x = SPECIES, y = BDRB.SCBD)) + 
  geom_bar(aes(fill = SPECIES), stat = "identity") +
  scale_y_continuous(breaks = 0:10) +
  coord_polar() + 
  labs(x = "", y = "") +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank() 
  ) 

rose_plot



####Save the figure####
ggsave("rose_plot_scbd.png", rose_plot, 
       width = 8, height = 8, dpi = 150)
