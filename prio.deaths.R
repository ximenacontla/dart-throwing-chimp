library(plyr)
library(scales)

# Get the .zip archive from PRIO and extract the .csv compressed therein
temp <- tempfile()
download.file("http://www.pcr.uu.se/digitalAssets/124/124934_1ucdpbattle-relateddeathsdatasetv.5-2014conflict.csv.zip", temp)
PRIO.deaths <- read.csv(unz(temp, "UCDPBattle-RelatedDeathsDatasetv.5-2014Conflict.csv"), stringsAsFactors = FALSE)
unlink(temp)

# In v5-2014, Syria in 2013 gets a missing code (-99) for BdBest and BdHigh; only a low value is recorded. I'm not sure
# why they decided to treat that as missing for best and high when they're really saying that they only have a single 
# estimate and suspect it's low. At any rate, to avoid having the Syria fatalities counted only in the low but not the
# best and high categories that year, we need to hard code those other two cells to match.
# See http://www.pcr.uu.se/digitalAssets/124/124934_1codebook-ucdp-battle-related-deaths-datasets-v.5-2014.pdf
PRIO.deaths$BdBest <- with(PRIO.deaths, ifelse(BdBest == -99, BdLow, BdBest))
PRIO.deaths$BdHigh <- with(PRIO.deaths, ifelse(BdHigh == -99, BdLow, BdHigh))

# Use plyr's ddply to get annual sums
PRIO.deaths.annual <- ddply(PRIO.deaths, .(Year), summarise,
     low = sum(BdLow),
     best = sum(BdBest),
     high = sum(BdHigh))

# Make a line plot
png("prio.battle.related.deaths.by.year.png",
     width = 6.5, height = 9/16 * 6.5, unit = "in", bg = "white", res = 300)
par(cex.axis = 0.7, mai=c(0.25, 0.75, 0.1, 0.1))
# Use high to set frame because it will have highest values
with(PRIO.deaths.annual, plot(high, type = "n", ylim = c(0,max(high)+1000), xlab = "", ylab = "", axes = FALSE))
axis(2, at = seq(0,100000,25000), tick = FALSE, las = 2)
axis(1, at = seq(2,22,5), labels = seq(1990, 2010, 5), tick = FALSE, pos = 5000)
abline(h = 0, lwd = 1, col = "black")
abline(h = seq(25000,100000,25000), lwd = 0.5, col = alpha("gray50", alpha = 1/2))
with(PRIO.deaths.annual, lines(best, col = "red3", lwd = 2))
with(PRIO.deaths.annual, lines(low, col = "red3", lwd = 1, lty = 2))
with(PRIO.deaths.annual, lines(high, col = "red3", lwd = 1, lty = 2))
dev.off()


# Now get data on one-sided violence; see
# http://www.pcr.uu.se/research/ucdp/datasets/ucdp_one-sided_violence_dataset/
PRIO.1side <- read.csv("http://www.pcr.uu.se/digitalAssets/124/124932_1ucdp_one-sidedviolencedataset1.4-2014.csv",
     stringsAsFactors = FALSE)

# Summarize it.
PRIO.1side.annual <- ddply(PRIO.1side, .(Year), summarise,
     low = sum(LowFatalityEstimate),
     best = sum(BestFatalityEstimate),
     high = sum(HighFatalityEstimate))

# Plot that.
png("prio.onesided.deaths.by.year.png",
     width = 6.5, height = 9/16 * 6.5, unit = "in", bg = "white", res = 300)
par(cex.axis = 0.7, mai=c(0.25, 0.75, 0.1, 0.1))
# Use high to set frame because it will have highest values
with(PRIO.1side.annual, plot(high, type = "n", ylim = c(0,1000000), xlab = "", ylab = "", axes = FALSE))
axis(2, at = seq(0,1000000,250000), labels = c("0", "250,000", "500,000", "750,000", "1 million"), tick = FALSE, las = 2)
axis(1, at = seq(2,22,5), labels = seq(1990, 2010, 5), tick = FALSE, pos = 50000)
abline(h = 0, lwd = 1, col = "black")
abline(h = seq(250000,1000000,250000), lwd = 0.5, col = alpha("gray50", alpha = 1/2))
with(PRIO.1side.annual, lines(best, col = "darkorange3", lwd = 2))
with(PRIO.1side.annual, lines(low, col = "darkorange3", lwd = 1, lty = 2))
with(PRIO.1side.annual, lines(high, col = "darkorange3", lwd = 1, lty = 2))
dev.off()

# Now combine the two
PRIO.sum.annual <- data.frame(PRIO.deaths.annual[,1], PRIO.deaths.annual[,2:4] + PRIO.1side.annual[,2:4])
names(PRIO.sum.annual) <- c("year", "low", "best", "high")

# Now plot that
png("prio.deaths.summed.by.year.png",
     width = 6.5, height = 9/16 * 6.5, unit = "in", bg = "white", res = 300)
par(cex.axis = 0.7, mai=c(0.25, 0.75, 0.1, 0.1))
# Use high to set frame because it will have highest values
with(PRIO.sum.annual, plot(high, type = "n", ylim = c(0,1000000), xlab = "", ylab = "", axes = FALSE))
axis(2, at = seq(0,1000000,250000), labels = c("0", "250,000", "500,000", "750,000", "1 million"), tick = FALSE, las = 2)
axis(1, at = seq(2,22,5), labels = seq(1990, 2010, 5), tick = FALSE, pos = 50000)
abline(h = 0, lwd = 1, col = "black")
abline(h = seq(250000,1000000,250000), lwd = 0.5, col = alpha("gray50", alpha = 1/2))
with(PRIO.sum.annual, lines(best, col = "darkred", lwd = 2))
with(PRIO.sum.annual, lines(low, col = "darkred", lwd = 1, lty = 2))
with(PRIO.sum.annual, lines(high, col = "darkred", lwd = 1, lty = 2))
dev.off()
