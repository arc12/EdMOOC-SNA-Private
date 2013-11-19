# iterate over a number of courses, executing "FAP Forums.Rmd" for each one.
# creates an HTML report for each course

library(knitr)
library(markdown)

# NB including an explicit "~/R Projects/Edinburgh MOOC/EdMOOC-SNA" as argument to markdownToHTML
# causes it to fail to find file. Also get figures directory in wrong place without setwd()
setwd("~/R Projects/Edinburgh MOOC/EdMOOC-SNA/Tie Type Comparison")
courseIDs<-c("aiplan","astro","crit","edc","equine","intro")
tie.type.1<-"P-C"
tie.type.2<-"P-Set"

dir.create("data", showWarnings=F)

process1<-function(){
   md.filename<-paste("Tie Type Correlation - ",courseID,".md", sep="")
   html.filename<-paste("Tie Type Correlation - ",courseID,".html", sep="")
   knit("Tie Type Correlation.Rmd", output=md.filename)#, envir=.GlobalEnv) #envir leaves last run in workspace for inspection/debug
   markdownToHTML(md.filename, output=html.filename, stylesheet="../../custom_md.css")
   file.remove(md.filename)
   file.rename(html.filename, file.path("reports",html.filename))
}

for (courseID in courseIDs){
   process1()
}