# iterate over a number of courses, executing "Degree P-C.Rmd" for each one.
# creates an HTML report and DL file for each course

library(knitr)
library(markdown)

# base.dir relative to RStudio project working dir.
# NB including an explicit "~/R Projects/Edinburgh MOOC/EdMOOC-SNA" causes markdownToHTML to fail to find file
setwd("~/R Projects/Edinburgh MOOC/EdMOOC-SNA/Top Subnets")
courseIDs<-c("aiplan","astro","crit","edc","equine","intro")
for (courseID in courseIDs){
   md.filename<-paste("Degree P-C - ",courseID,".md", sep="")
   html.filename<-paste("Degree P-C - ",courseID,".html", sep="")
   knit("Degree P-C.Rmd", output=md.filename)
   markdownToHTML(md.filename, output=html.filename, stylesheet="../../custom_md.css")
}