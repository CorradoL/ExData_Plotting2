## LOADING DATA ================================================================

temp <- tempfile()                                        # set a temporary file
download.file(
    'https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip',
    temp)                            # download (zip) file in the temporary file

content.name <- unzip(temp, list=TRUE)[1]            # whatch inside the archive
content.name                                       # there two files as aspected

unzip(temp)                                       # unzip the file into the wd()
NEI <- readRDS(content.name$Name[2])                            # importing data
SCC <- readRDS(content.name$Name[1])

unlink(temp)                                             # remove temporary file
rm(content.name, temp)


## CREATE USEFUL STRUCTURES ====================================================

library(dplyr)                                # upgrade data.frame to data_frame
library(stringr)
library(ggplot2)

NEI <- as_data_frame(NEI)                                  # create a data_frame
SCC <- as_data_frame(SCC)

glimpse(NEI)                                                      # inspect data
glimpse(SCC)

SCC.MV <- SCC %>%                                                     # from SCC
    filter(grepl(           # select only rows in which it can be find a pattern
        '(.*Motor(cycles|( Vehicles)).*)',               # on motor veichels
        Short.Name                         # in the general (condensed) name
    )
    ) %>%
    select(SCC)       # finally select only the SCC variable to retrive the code

MV.BLAPM25 <- NEI %>%                                    # from the NEI database
              filter(                                                # filter by
                fips == '24510' | fips == '06037',    # Baltimora C. (OR) L.A.C.
                SCC %in% SCC.MV[[1]]                     # and by motor vehicles
              ) %>%
              select(Emissions, year, fips) %>% # take Emissions, years and fips
              group_by(year, fips) %>%          # group by year and next by fips
              summarise(total = sum(Emissions)) %>% # sum of Emissions each year
              arrange(year)                 # sort by year (for assure ordering)
#NOTE: I use SCC.CC[[1]] to extract the (only) variable from df to a vector

MV.BLAPM25$fips <- gsub('24510', 'Baltimore C.', MV.BLAPM25$fips) # beauty names
MV.BLAPM25$fips <- gsub('06037', 'L.A. Country', MV.BLAPM25$fips)

## CREATE PLOT 1 on device PNG: plot1.png ======================================

png('plot6.png')             # switch-on output on PNG device named as requested

qplot(                                                 # create a ggplot2's plot
    year, total,     # year (x) versus totla ammount of pm2.5 (summed over type)
    data = MV.BLAPM25,                                        # the main data frame
    facets = fips ~ .,                          # one facet (vertical) each fips
    geom = c('point', 'smooth'),    # construct using points and confidence area
    method = lm,                      # standard linear model to describe trends
    col = fips                                  # each fips is a different color
)

dev.off()                                      # finaly we switch-off the Device

## THE END =====================================================================
