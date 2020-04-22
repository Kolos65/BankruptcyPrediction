library(readxl)

# Az adatok beolvasása
clustered <- read_excel("clustered.xlsx")

# A CLUSTER értéket kategória változóként akarjuk beolvasni:
clustered$CLUSTER <- factor(clustered$CLUSTER)

# A változók összefűzése
vars <- cbind(
  PCA_ESZK_JOVED, 
  PCA_BEV_ARANYOS_JOVED, 
  PCA_ELAD_MERTEKE, 
  PCA_TOKE_ELLAT, 
  PCA_LIKVID, 
  PCA_MERET, 
  PCA_FEDEZETTSEG
)

# Anova elemzés
test <- manova(vars ~ CLUSTER, data = clustered)

# A végeredmény kiírása
summary.aov(test)



