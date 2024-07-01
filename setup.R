###############################################################################
#----------------------- POUR CREER LES REPERTOIRES  --------------------------#
################################################################################


# 1. Pour créer les répertoires avec les données et celui avec les scripts
# dir.create("data")
# dir.create("data/input")
# dir.create("data/output")
# dir.create("data/input/images")
# dir.create("scripts")
# #crée le fichier "main" contenant les informations sur chaque scripts
# file.create("scripts/main.R")
# #crée les scripts
#file.create("scripts/1_cartes_du_site_etudie.R")
#file.create("scripts/2_Analyse_statistique.R")

# 2. Pour créer le principale chemin d'accès aux données
main_dir <- "/Users/ad/Documents/R_Github/petit_duc/data"


# 3. Pour créer les chemins d'accès au données avant et après traitement
#avant
input_data <- paste(main_dir, "input", sep="/")
if (!dir.exists(input_data)) dir.create(input_data, recursive = TRUE)
#après
output_data <- paste(main_dir, "output", sep="/")
if (!dir.exists(output_data)) dir.create(output_data, recursive = TRUE)

