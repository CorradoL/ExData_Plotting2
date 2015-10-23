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
library(ggplot2)                                           # grammar of graphics

NEI <- as_data_frame(NEI)                                  # create a data_frame
SCC <- as_data_frame(SCC)

glimpse(NEI)                                                      # inspect data
glimpse(SCC)

BC.type.PM25 <- NEI %>%                                  # from the NEI database
    filter(fips == '24510') %>%                  # filter by Baltimora city code
    select(Emissions, type, year) %>%            # take only Emissions and years
    group_by(year,type) %>%    # group result data frame by year and nex by type
    summarise(total = sum(Emissions)) %>%   # sum of Emissions by type each year
    arrange(year) %>%                       # sort by year (for assure ordering)
    mutate(type = as.factor(type))              # transforming to use in ggplot2

BC.type.PM25                                                    # whatching data

## CREATE PLOT 1 on device PNG: plot1.png ======================================

png('plot3.png')             # switch-on output on PNG device named as requested

qplot(                                                 # create a ggplot2's plot
    year, total,     # year (x) versus totla ammount of pm2.5 (summed over type)
    data = BC.type.PM25,                                   # the main data frame
    facets = type ~ .,                          # one facet (vertical) each type
    geom = c('point', 'smooth'),    # construct using points and confidence area
    method = lm,                      # standard linear model to describe trends
    col = type                                  # each type is a different color
)

dev.off()                                      # finaly we switch-off the Device

## THE END =====================================================================
