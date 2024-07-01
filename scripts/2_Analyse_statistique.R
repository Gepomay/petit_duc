################################################################################
#--------------------------- 2_Analyse_statistique.R --------------------------#
################################################################################


# load packages
library(sjPlot)
library(FactoMineR)
library(betareg)
library(car)
library(glmmTMB)
library(DHARMa)
library(ggplot2)
library(tidyverse)
library(hrbrthemes)
library(viridis)
library(grid)
library(png)
library(here)
library(cowplot)
library(magick)
library(Hmisc)


#crée le chemin d'accès au fichier pour enregistrer les données brut
indir <- paste0(input_data)
#crée le fichier si il n'existe pas déjà
if (!dir.exists(indir)) dir.create(indir, recursive = TRUE)

#crée le chemin d'accès au fichier pour enregistrer les données modifiées
outdir <- paste0(output_data, "/2_Analyse_statistique")
#crée le fichier si il n'existe pas déjà
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)


# load data
M_site_1 <- read.table(paste0(input_data,"/chic.txt"), h=T)
AF_site_2 <- read.table(paste0(input_data,"/dada.txt"), h=T)
M_site_2 <- read.table(paste0(input_data,"/bouyou.txt"), h=T)
M_site_3 <- read.table(paste0(input_data,"/iro.txt"), h=T)
F_site_1 <- read.table(paste0(input_data,"/comb.txt"), h=T)
M_site_1$Audio <- as.factor(M_site_1$Audio)
AF_site_2$Audio <- as.factor(AF_site_2$Audio)
M_site_2$Audio <- as.factor(M_site_2$Audio)
M_site_3$Audio <- as.factor(M_site_3$Audio)
F_site_1$Audio <- as.factor(F_site_1$Audio)

data <- read.table(paste0(input_data,"/Data_all.txt"), h=T)
data$hab <- as.factor(data$hab)
data$site_id <- as.factor(data$site_id)
data$pluie <- as.factor(data$pluie)

################################################################################
#-------------------------------STATISTICAL ANALYSIS---------------------------#
################################################################################

#------------ Significance test between the two AudioMoth of pairs ------------#

mod.M_site_1 <- lm(pourc_chant_eff~Audio, data=M_site_1)
drop1(mod.M_site_1, test="F") 

mod.AF_site_2 <- lm(pourc_chant_eff~Audio, data=AF_site_2)
drop1(mod.AF_site_2, test="F")

mod.M_site_2 <- lm(pourc_chant_eff~Audio, data=M_site_2)
drop1(mod.M_site_2, test="F") 

mod.M_site_3 <- lm(pourc_chant_eff~Audio, data=M_site_3)
drop1(mod.M_site_3, test="F") 

mod.F_site_1 <- lm(pourc_chant_eff~Audio, data=F_site_1)
drop1(mod.F_site_1, test="F")

## => There were no significant differences in the percentage of singing recordings between the two AudioMoth pairs.



#------------------------------- DATA EXPLORATION -----------------------------#

# The variable to be explained PST corresponds to "pourc_chant_eff" in the script

## CHECKING FOR MISSING DATA
colSums(is.na(data)) 
# There is no missing data

## CHECK FOR THE PRESENCE OF OUTLIERS IN Y AND THE DISTRIBUTION OF Y VALUES. 
hist(data$pourc_chant_eff,col='blue',xlab="pourc_chant",main="") 
# No normal distribution because Y is a percentage resulting from a count. Instead, we have a bêta distribution

dotchart(data$pourc_chant_eff,pch=16,col='blue',xlab='pourc_chant_eff') 
# An outlier but not an error, due to the high percentage of singing on the first recording of F_site_5. 


## FOR QUANTITATIVE X, CHECK FOR OUTLIERS AND DISTRIBUTION:
# pourc_exploit
dotchart(data$pourc_exploit,pch=16,col='blue',xlab='pourc_exploit') # OK
qqnorm(data$pourc_exploit,pch=16,col='blue',xlab='pourc_exploit') # OK

# moon
dotchart(data$lune,pch=16,col='blue',xlab='lune') # OK
qqnorm(data$lune,pch=16,col='blue',xlab='lune') # OK

# dist_urb
dotchart(data$dist_urb,pch=16,col='blue',xlab='dist_urb') # OK
qqnorm(data$dist_urb,pch=16,col='blue',xlab='dist_urb') # OK

## FOR X CATEGORIES, CHECK THE NUMBER OF LEVELS AND THE NUMBER OF ITEM PER LEVEL
summary(data$hab) # Not equal but has no impact on analyses
summary(data$pluie) # Not equal, but the aim isn't to specifically assess the effect of rain, so it's not a problem in itself.

## ANALYSE THE POTENTIAL RELATIONSHIPS BETWEEN Y AND X.
# PST ~ hab
# sample size
sample_size = data %>% group_by(hab)

PST_hab <- data %>%
  left_join(sample_size) %>%
  ggplot( aes(x=hab, y=pourc_chant_eff, fill=hab)) +
  geom_violin(width=1.4) +
  stat_summary(
    fun.data = "mean_se",  fun.args = list(mult = 1), 
    geom = "pointrange", color = "black"
  ) +
  scale_fill_manual(values = c("darkorange2", "#669900", "darkslategray3")) +
  theme_bw() +
  theme(
    legend.position="none",
    plot.title = element_text(size=16, hjus = 0.5, face = "bold"),
    axis.title.x = element_text(size = 15, face = "plain", hjust = 0.5),
    axis.title.y = element_text(size = 15, face = "plain",hjust = 0.5),
    axis.text.x = element_text(size = 15),
    axis.text.y = element_text(size = 15)) +
  ggtitle("PST depending on the type of habitat") +
  geom_text(aes(x = 2, y= 0.52, label = "**"), size=10) +
  labs(x = "Habitat type", y = "PST")
# There seems to be less activity in mangroves

# PST ~ site
img_AF <- png::readPNG(paste0(indir,"/images/AF.png"))
img_F <- png::readPNG(paste0(indir,"/images/F.png"))
img_M <- png::readPNG(paste0(indir,"/images/M.png"))

plot_AF <- ggplot(data[data$hab == "A-F",], aes(x = site_id, y = pourc_chant_eff, fill = site_id)) +
  geom_boxplot() +
  scale_fill_manual(values = c("darkorange2", "darkorange2", "darkorange2", "darkorange2")) +
  theme_bw() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
    axis.title.x = element_text(size = 15, face = "plain", hjust = 0.5,  margin = margin(t = 0.5)),
    axis.title.y = element_text(size = 15, face = "plain", hjust = 0.5),
    axis.text.x = element_text(size = 15, angle = 35, vjust = 0.5, margin = margin(t = 4)),
    axis.text.y = element_text(size = 15)) +
  ylim(0, 0.5)+
  ggtitle("Agroforest") +
  labs(x = "", y = "PST")

plot_F <- ggplot(data[data$hab == "F",], aes(x = site_id, y = pourc_chant_eff, fill = site_id)) +
  geom_boxplot() +
  scale_fill_manual(values = c("#669900", "#669900", "#669900", "#669900", "#669900")) +
  theme_bw() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
    axis.title.x = element_text(size = 15, face = "plain", hjust = 0.5,  margin = margin(t = 10)),
    axis.title.y = element_blank(),
    axis.text.x = element_text(size = 15, angle = 35, vjust = 0.5, margin = margin(t = 4)),
    axis.text.y = element_blank()) +
  ylim(0, 0.5)+
  ggtitle("Forest") +
  labs(x = "Site", y = "PST")

plot_M <- ggplot(data[data$hab == "M",], aes(x = site_id, y = pourc_chant_eff, fill = site_id)) +
  geom_boxplot() +
  scale_fill_manual(values = c("darkslategray3", "darkslategray3", "darkslategray3", "darkslategray3")) +
  theme_bw() +
  theme(
    legend.position = "none",
    plot.title = element_text(size = 16, hjust = 0.5, face = "bold"),
    axis.title.x = element_text(size = 15, face = "plain", hjust = 0.5,  margin = margin(t = 9)),
    axis.title.y = element_blank(),
    axis.text.x = element_text(size = 15, angle = 35, vjust = 0.5, margin = margin(t = 4)),
    axis.text.y = element_blank()) +
  ylim(0, 0.5)+
  ggtitle("Mangrove") +
  labs(x = "", y = "PST")

final_plot <- plot_grid(plot_AF,plot_F, plot_M, nrow = 1)
final_plot_site <- plot_grid(
  plot_AF + annotation_custom(rasterGrob(img_AF), xmin = 3.2, xmax = 4.4, ymin = 0.296, ymax = 0.607),
  plot_F + annotation_custom(rasterGrob(img_F), xmin = 4, xmax = 5.3, ymin = 0.296, ymax = 0.607),
  plot_M + annotation_custom(rasterGrob(img_M), xmin = 2.88, xmax = 4.68, ymin = 0.4, ymax = 0.5),
  nrow = 1)
final_plot_site
# There are variations between forest and agroforest sites.

# PST ~ pluie
boxplot(data$pourc_chant_eff~data$pluie,col='blue')

# PST ~ pourc_exploit
plot(data$pourc_chant_eff~data$pourc_exploit) # Maybe a relationship between the two.

# PST ~ lune
plot(data$pourc_chant_eff~data$lune) # Maybe a relationship between the two.

# PST ~ dist_urb
plot(data$pourc_chant_eff~data$dist_urb) # Maybe a relationship between the two.


## CHECK POTENTIAL RELATIONSHIPS BETWEEN THE VARIOUS X:
plot(data$pourc_exploit~data$lune) # No relation
plot(data$pourc_exploit~data$dist_urb) # No relation
plot(data$lune~data$dist_urb) # No relation
plot(data$dist_urb~data$hab) # Relation

## CHECK THE COLLINEARITY BETWEEN THE XS. 
# WE WILL CENTRE AND REDUCE THE QUANTITATIVE VARIABLES TO MAKE IT EASIER TO INTERPRET THE COEFFICIENTS AND AVOID PROBLEMS OF COLLINEARITY.
data$pourc_exploit_ST <- scale(data$pourc_exploit)
data$lune_ST <- scale(data$lune)
data$dist_urb_ST <- scale(data$dist_urb)

# VIF test (We take a threshold of two for the left-hand column)
vif_X <- lm(pourc_chant_eff~ hab + pourc_exploit_ST + pluie + lune_ST + dist_urb_ST, data=data)
vif(vif_X) # no collinearity between X


#------------------------------- STATISTICAL MODEL ----------------------------#

# We run a generalised linear mixed model with a beta family, with the site as a random factor.
mod <- glmmTMB(pourc_chant_eff~ hab + pourc_exploit_ST + pluie + lune_ST + dist_urb_ST + 
                 hab:pourc_exploit_ST + hab:pluie + hab:lune_ST + hab:dist_urb_ST +
                 pourc_exploit_ST:pluie + pourc_exploit_ST:lune_ST + dist_urb_ST+
                 pluie:lune_ST + pluie:dist_urb_ST + lune_ST:dist_urb_ST +
                 (1 | site_id), family = beta_family(), data=data)
Anova(mod, type = "III") # Type III ANOVA because it is better in a mixed model because it takes interactions into account

#=> Model selected:
mod1 <- glmmTMB(pourc_chant_eff~ hab  + pluie + lune_ST + dist_urb_ST + 
                  hab:pluie + hab:lune_ST + hab:dist_urb_ST +
                  pluie:lune_ST + pluie:dist_urb_ST + 
                  lune_ST:dist_urb_ST +
                  (1 | site_id), family = beta_family(), data=data)
Anova(mod1, type = "III")
#=> PST significantly impacted by : 
#   hab, lune, and the interactions hab:lune, hab:dist_urb, pluie:dist_urb, lune:dist_urb
summary(mod1)


#---------------------------- GRAPHICAL VISUALIZATION -------------------------#

# PST ~ lune:hab
PST_hab_moon <- plot_model(mod1, type = "pred", terms = c("lune_ST", "hab"), colors = c("darkorange2", "#669900", "cyan3"))+
  theme_minimal() +
  labs(x = "Visible percentage of moon", y = "PST predicted", color = "Habitat") +
  theme_bw() +
  theme(
    plot.title = element_blank(),
    axis.title.x = element_text(size = 17, hjust = 0.5, margin = margin(t = 10)),
    axis.title.y = element_text(size = 17, hjust = 0.5, margin = margin(r = 10)),
    axis.text.x = element_text(size = 17, vjust = 0.5),
    axis.text.y = element_text(size = 17, vjust = 0.5),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 15))

# PST ~ dist_urb:hab
PST_hab_urb <- plot_model(mod1, type = "pred", terms = c("dist_urb_ST", "hab"), colors = c("darkorange2", "#669900", "cyan3"))+
  theme_minimal() +
  labs(x = "Distance to nearest urban area", y = "PST predicted", color = "Habitat") +
  theme_bw() +
  theme(
    plot.title = element_blank(),
    axis.title.x = element_text(size = 17, hjust = 0.5, margin = margin(t = 10)),
    axis.title.y = element_text(size = 17, hjust = 0.5, margin = margin(r = 10)),
    axis.text.x = element_text(size = 17, vjust = 0.5),
    axis.text.y = element_text(size = 17, vjust = 0.5),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 15))

# PST ~ pluie:dist_urb
PST_rain_urb <- plot_model(mod1, type = "pred", terms = c("dist_urb_ST", "pluie"), colors = c("gray49", "cyan4"))+
  theme_minimal() +
  labs(x = "Distance to nearest urban area", y = "PST predicted", color = "Rain") +
  theme_bw() +
  theme(
    plot.title = element_blank(),
    axis.title.x = element_text(size = 17, hjust = 0.5, margin = margin(t = 10)),
    axis.title.y = element_text(size = 17, hjust = 0.5, margin = margin(r = 10)),
    axis.text.x = element_text(size = 17, vjust = 0.5),
    axis.text.y = element_text(size = 17, vjust = 0.5),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 15))


# PST ~ lune:dist_urb
PST_moon_urb <- plot_model(mod1, type = "pred", terms = c("dist_urb_ST", "lune_ST"), colors = c("khaki2", "khaki3", "khaki4"))+
  theme_minimal() +
  labs(x = "Distance to nearest urban area", y = "PST predicted", color = "Visible\npercentage\nof moon") +
  theme_bw() +
  theme(
    plot.title = element_blank(),
    axis.title.x = element_text(size = 17, hjust = 0.5, margin = margin(t = 10)),
    axis.title.y = element_text(size = 17, hjust = 0.5, margin = margin(r = 10)),
    axis.text.x = element_text(size = 17, vjust = 0.5),
    axis.text.y = element_text(size = 17, vjust = 0.5),
    legend.title = element_text(size = 16),
    legend.text = element_text(size = 15))


#--------------------------- MODEL VALIDATION-------------------------------#

validatio <- plot(simulateResiduals(mod1))
# No outliers, no significant problems detected. Validated model.
