## Install ggplot2 and ggrepel if not already available.
#if (!require(ggplot2))
#{
#  install.packages("ggplot2")
#}
#
#if (!require(ggrepel))
#{
#  install.packages("ggrepel")
#}

## Import and settings statements.
library(ggplot2)
library(ggrepel)
args = commandArgs(trailingOnly=TRUE)
setEPS()
postscript("Pangenome.eps", height = 8.5, width = 8.5)

## This script is run from within Pangloss as "RingChart.R [core_genome_size] [accessory_genome_size]",
## so these are parsed as numerics.
if (length(args)==2) {
  core <- as.numeric(args[1])
  accessory <- as.numeric(args[2])
}

## Load numbers into dataframe and convert them into radial numbers.
ring = data.frame(count=c(accessory, core), category=c("Accessory", "Core"))
ring$fraction = ring$count / sum(ring$count)
ring = ring[order(ring$fraction), ]
ring$ymax = cumsum(ring$fraction)
ring$ymin = c(0, head(ring$ymax, n=-1))

## Make size label for the middle of the ring chart.
size_label = sprintf("%s unique genes\n%s core genes\n%s accessory genes", 
                     core + accessory, core, accessory)

## Generate ring chart plot.
p1 = ggplot(ring, aes(fill=category, ymax=ymax, ymin=ymin, xmax=4, xmin=3)) +
     geom_rect(stat="identity", color='black') +
     coord_polar(theta="y") +
     xlim(c(0, 5)) +
     annotate("text", x = 0, y = 0, label = size_label) +
     labs(title="") +
     geom_label_repel(aes(label=paste(category, "\n",round(fraction*100, digits = 2),"%"), x=4 ,y=(ymin+ymax)/2), nudge_x = 2, arrow = arrow(angle = 0, length = unit(0.01, 'npc')), inherit.aes = FALSE, show.legend = FALSE, direction="both", max.iter = 3e3, ylim=c(6,8)) +
     guides(fill=guide_legend(reverse = TRUE, override.aes=list(colour=NA))) +
     scale_fill_manual(values = c("red", "darkgreen")) +
     theme_void() +
     theme(legend.position="top", legend.title = element_text(face="bold")) +
     labs(fill = "Component")


## Write ring chart to file and close.
p1
dev.off()
