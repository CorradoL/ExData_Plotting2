## LOADING DATA

temp <- tempfile()                                        # set a temporary file
download.file('https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip',
              temp)                  # download (zip) file in the temporary file

content.name <- unzip(temp, list=TRUE)[1]            # whatch inside the archive

content.name                                       # there two files as aspected

unzip(temp)

NEI <- readRDS(content.name$Name[2])                            # importing data
SCC <- readRDS(content.name$Name[1])

unlink(temp)                                             # remove temporary file
rm(content.name, temp)


## CREATE USEFUL STRUCTURES

library(dplyr)                                # upgrade data.frame to data_frame
library(stringr)

NEI <- as_data_frame(NEI)                                  # create a data_frame
SCC <- as_data_frame(SCC)

glimpse(NEI)                                                     # inspect data
glimpse(SCC)

totPM25 <- NEI %>%                                       # from the NEI database
            select(Emissions, year) %>%          # take only Emissions and years
            group_by(year) %>%                 # group result data frame by year
            summarise(total = sum(Emissions)) %>%  # sum of Emissions each group
            arrange(year) # sort by year (for assure ordering)
# NOTE: yach 'group' in a summarise step is an year!!

## CREATE PLOT 1 on device PNG: plot1.png
png('plot1.png')             # switch-on output on PNG device named as requested

def.bars <- barplot(  # create a barplot (and save to store x-coord of the bars)
    height = totPM25$total,                       # of the total PM2.5 each year
    density = 75,                              # with a partial filling of color
    angle = -20,                      # quite descending angle for texture lines
    names.arg = totPM25$year,                         # bars' names are the year
    col = 'steelblue4',                           # my idea of pollution's color
    main = 'Total pm2.5 in USA (1999 - 2008)',                  # with its title
    xlab = 'years',                                           # and axes' labels
    ylab = 'pm 2.5 (tons)'
    )
lines(x  = def.bars, y = totPM25$total/2)        # baricentric line to emphasize

dev.off()                                      # finaly we switch-off the Device

## THE END
