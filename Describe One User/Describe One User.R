## Set these for each run. NB: they are not independent.
courseID<-"astro"
forum_user_id<-"22ff21ae849c5580ab12304d9d9ab77d29902228"

# NB including an explicit "~/R Projects/Edinburgh MOOC/EdMOOC-SNA" as argument to markdownToHTML
# causes it to fail to find file. Also get figures directory in wrong place without setwd()
setwd("~/R Projects/Edinburgh MOOC/EdMOOC-SNA/Describe One User")
dir.create(courseID, showWarnings=F)

library(knitr)
library(markdown)

#the process here is not efficient. The network data is loaded EACH time knitr is invoked
#consider improving if the load times get irritating......
   md.filename<-paste(forum_user_id,".md", sep="")
   html.filename<-paste(forum_user_id,".html", sep="")
   knit("Describe One User.Rmd", output=md.filename)
   markdownToHTML(md.filename, output=html.filename, stylesheet="../../custom_md.css")
   file.remove(md.filename)
   file.rename(html.filename, file.path(courseID,html.filename))