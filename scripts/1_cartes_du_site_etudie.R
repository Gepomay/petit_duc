################################################################################
#-------------------------- 1_cartes_du_site_etudie.R -------------------------#
################################################################################


# load packages
library(wdpar)
library(dplyr)
library(ggplot2)
library(ggmap) #https://prioritizr.github.io/wdpar/
library(terra)
library(rnaturalearth)
library(rnaturalearthdata)
library(rnaturalearthhires)
library(raster)
library(sf)
library(egg)
library(gridExtra)
library(devtools)
library(usethis)
library(maptools)
library(ggsn)
library(rJava)
library(OpenStreetMap)


#crée le chemin d'accès au fichier pour enregistrer les données modifiées
outdir <- paste0(output_data, "/1_cartes")
#crée le fichier si il n'existe pas déjà
if (!dir.exists(outdir)) dir.create(outdir, recursive = TRUE)


#------------------------------------------------------------------------------#
#                            I- Carte Ocean Indien                             #
#------------------------------------------------------------------------------#

#                         1. Prepare landmask                                  #              
# landmask
world <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf")
lon1 <- 7.78
lat1 <- 26.84
lon2 <- 90.52
lat2 <- -35.08
e <- raster::extent(lon1, lon2, lat2, lat1)
box = c(xmin = e[1], ymin = e[3], xmax = e[2], ymax = e[4])
sf_use_s2(FALSE)
land <- sf::st_crop(world, box) # sf_use_s2(FALSE)


#                                 2. Plot                                      #

# plot
map_indian <- ggplot() +
  labs(fill = "Depth (m)") +
  geom_rect(aes(xmin = lon1, xmax = lon2, ymin = lat2, ymax = lat1), fill = grey(0.8)) +
  geom_sf(fill = "white", size = 0.5, data = land) +
  labs(x = '',y = '') +
  theme_article(base_size = 10) +
  theme(axis.title.x = element_blank(),
        axis.text.x  = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y  = element_blank(),
        axis.ticks = element_blank()) +
  coord_sf(expand = FALSE) +
  #add north arrow
  ggsn::north(data = NULL, location = "topleft",
              x.min = lon1, x.max = lon2, y.min = lat1, y.max = lat2,
              symbol = 1, scale = 0.12,
              anchor = c(x = lon1 + 73 , y = lat1 - 9)) +
  #add scalebar
  ggsn::scalebar(data = NULL, dist = 1000, transform = TRUE, model = "WGS84", dist_unit = "km",
                 x.min = lon1, x.max = lon2, y.min = lat1, y.max = lat2,
                 anchor = c(x = lon1 + 70, y = lat2 + 3.5), #offset_lon = 0.07, offset_lat = 0.01
                 st.color = "black", box.fill = c("black", "white"), st.size = 5) +
  ggplot2::geom_text(aes(x = 64.5, y= -4, label = "Indian\nOcean"), size=5)
map_indian

# Export plot
# with BAT
pg_png <- paste0(outdir, "/map_indian_ocean_g.png")
ggsave(pg_png, map_indian, width=18, height=20, units="cm", dpi=300)



#------------------------------------------------------------------------------#
#                            II- Carte Comores                                 #
#------------------------------------------------------------------------------#


#                         1. Prepare landmask                                  #              

# landmask
comore <- rnaturalearth::ne_countries(scale = "large", returnclass = "sf")
lonC1 <- 43.13
latC1 <- -11.32
lonC2 <- 45.37
latC2 <- -13.14
eC <- raster::extent(lonC1, lonC2, latC2, latC1)
boxC = c(xmin = eC[1], ymin = eC[3], xmax = eC[2], ymax = eC[4])
sf_use_s2(FALSE)
landC <- sf::st_crop(comore, boxC) # sf_use_s2(FALSE)


#                                 2. Plot                                      #

# plot
map_comore <- ggplot() +
  labs(fill = "Depth (m)") +
  geom_rect(aes(xmin = lonC1, xmax = lonC2, ymin = latC2, ymax = latC1), fill = grey(0.8)) +
  geom_sf(fill = "white", size = 0.5, data = landC) +
  labs(x = '',y = '') +
  theme_article(base_size = 10) +
  theme(axis.title.x = element_blank(),
        axis.text.x  = element_blank(),
        axis.title.y = element_blank(),
        axis.text.y  = element_blank(),
        axis.ticks = element_blank()) +
  coord_sf(expand = FALSE) +
  #add north arrow
  ggsn::north(data = NULL, location = "topleft",
              x.min = lonC1, x.max = lonC2, y.min = latC1, y.max = latC2,
              symbol = 1, scale = 0.12,
              anchor = c(x = lonC1+1.9 , y = latC1-0.1 )) +
  #add scalebar
  ggsn::scalebar(data = NULL, dist = 20, transform = TRUE, model = "WGS84", dist_unit = "km",
                 x.min = lonC1, x.max = lonC2, y.min = latC1, y.max = latC2,
                 anchor = c(x = lonC1+0.5, y = latC2+0.1), #offset_lon = 0.07, offset_lat = 0.01
                 st.color = "black", box.fill = c("black", "white"), st.size = 5.5) +
  ggplot2::geom_text(aes(x = lonC1+0.4, y= latC2+1.6, label = "Grande\nComore"), size=5)+
  ggplot2::geom_text(aes(x = lonC1+0.38, y= latC2+0.84, label = "Moheli"), size = 5)+
  ggplot2::geom_text(aes(x = lonC1+1.54, y= latC2+1, label = "Anjouan"), size=5)+
  ggplot2::geom_text(aes(x = lonC1+1.8, y= latC2+0.3, label = "Mayotte"), size=5, fontface = "bold")
map_comore

# Export plot
# with BAT
comore_png <- paste0(outdir, "/map_Comore.png")
ggsave(comore_png, map_comore, width=18, height=20, units="cm", dpi=300)


#------------------------------------------------------------------------------#
#                            III- Carte satellite sites                        #
#------------------------------------------------------------------------------#


#                         1. Prepare landmask                                  #              

# Definition zone d'etude
lon1_sat <- 44.96
lat1_sat <- -12.60
lon2_sat <- 45.33
lat2_sat <- -13.08

map = openmap(c(lat2_sat, lon1_sat), c(lat1_sat, lon2_sat), zoom = NULL,
              type = c("bing"), #for satellite view
              mergeTiles = TRUE)

maplatlon = OpenStreetMap::openproj(map, projection = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")

OpenStreetMap::autoplot.OpenStreetMap(maplatlon) +
  labs(x = 'Longitude', y = 'Latitude') +
  theme_article(base_size = 15) +
  coord_sf(expand = 0) +
  theme(axis.title.x = element_text(size = 10),
        axis.text.x  = element_text(size = 6),
        axis.title.y = element_text(size = 10),
        axis.text.y  = element_text(size = 6)) +
  coord_sf(expand = FALSE) +
  #add north arrow
  ggsn::north(data = NULL, location = "topright",
              x.min = lon1_st, x.max = lon2_st, y.min = lat1_st, y.max = lat2_st,
              symbol = 1, scale = 0.1) +
  #add scalebar
  ggsn::scalebar(data = NULL, dist = 0.000000000000001, transform = TRUE, model = "WGS84", dist_unit = "km",
                 x.min = lon1_st, x.max = lon2_st, y.min = lat1_st, y.max = lat2_st, location = "bottomright",
                 anchor = c(x = lon1_st + 0.00001, y = lat2_st + 0.00001),
                 st.color = "white", box.fill = c("white", "white"), st.size = 2.5)

