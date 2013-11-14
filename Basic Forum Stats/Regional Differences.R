## ****************************************************
## Created: Adam Cooper, Cetis, Nov 2013
## This source code was produced for The University of
## Edinburgh DEI as part of their MOOC initiative.
## Computes forum use by region of contributor
## ****************************************************

## Chunks intended for use with knitter in the Rmd file.
## Can be used independently of knitr but NB that some config parameters are set in the Rmd

## @knitr INIT
#establish connection to MySQL, loading library. contains coursera DB exports from 2013
source("../dbConnect.R")
#helper functions
source("../helpers.R")
# Regions to consider - see helpers.R - (omits Oceania and unknown)
# If this contains any regions that do not exist, an error will result
regions<-c('EUROPE', 'NORTH AMERICA', 'SOUTH AMERICA', 'AFRICA',
           'ASIA', 'MIDDLE EAST', 'CENTRAL AMERICA', 'UK AND IRELAND',
           'CHINA', 'AUSTRALIA AND NZ', 'INDIA')
# function to reshape country and continent query results into a neat data frame with
# courses as rows and regions as columns
shape.toFrame<-function(cIDs, regs, dbResults.list){
   shaped.df<-data.frame(rep(character(0),length(regs)))
   for(i in 1:length(dbResults.list)){
      df<-data.frame(users=as.numeric(dbResults.list[[i]]$users), region=apply(dbResults.list[[i]],1,map.toRegion))
      region.table<-aggregate(df[,1], FUN=sum, by=list(region=df[,2]))
      shaped.df<-rbind(shaped.df,t(region.table[match(regs,region.table[,"region"]),"x"]))
   }
   colnames(shaped.df)<-regs
   rownames(shaped.df)<-cIDs
   shaped.df[is.na(shaped.df)]<-0
   return(shaped.df)
}

# this is for plotting the posting probabilities for 1 forum, showing regional comparison across
# intros, subject amd tech forums
plot.1course<-function(courseID){
   df<-rbind(introductions=postProb.intro[courseID,],
                    subject=postProb.subj[courseID,],
                    technical=postProb.tech[courseID,])
   cols<-rainbow(length(postProb.intro[1,]))
   barplot(100*t(as.matrix(df)), ylab="% Probability", col=cols, las=1, beside=T)
   legend("topright", inset=c(0.1,0),legend=colnames(df), fill=cols, cex=0.6)
}

## @knitr USER_DIST
userRegions.sql<-"SELECT c.ip_continent continent, c.ip_country country, count(1) users
                  FROM **gen.users u JOIN **gen.uoe_ip_country c
                                          ON u.anon_user_id = c.anon_user_id
                  WHERE u.access_group_id = 4 GROUP BY continent, country"
userRegions.list<-list.SELECT(db, courseIDs, userRegions.sql, echo=echo.sql)
#process a bit to get into useful shape 
userRegions.df<-shape.toFrame(courseIDs, regions, userRegions.list)



## @knitr POST_PROBS
# count the number of POSTERS, not number of POSTS
counts.sql.a<-"SELECT DISTINCT continent, country, count(1) users FROM
(SELECT DISTINCT c.ip_continent continent, c.ip_country country,  fp.forum_user_id
 FROM **for.forum_posts fp
 JOIN **map.hash_mapping m ON m.forum_user_id = fp.forum_user_id 
 JOIN **gen.uoe_ip_country c ON m.anon_user_id = c.anon_user_id
 JOIN **gen.users u ON m.anon_user_id = u.anon_user_id
 JOIN  **for.forum_threads ft ON fp.thread_id = ft.id
 JOIN  **for.forum_forums ff ON ft.forum_id = ff.id
 WHERE u.access_group_id = 4 AND fp.deleted=0 AND fp.is_spam = 0 AND ft.deleted=0 AND ft.is_spam=0
 AND ff.deleted=0"
counts.sql.b.non<-"AND ff.id=##"
counts.sql.b.subj<-"AND ff.id NOT IN (##)"
counts.sql.c<-") tt GROUP BY continent, country"
# 
# counts.sql.a<-"SELECT c.ip_continent continent, c.ip_country country, count(1) users
#                      FROM **for.forum_posts fp
#     JOIN **map.hash_mapping m ON m.forum_user_id = fp.forum_user_id 
#     JOIN **gen.uoe_ip_country c ON m.anon_user_id = c.anon_user_id
#     JOIN **gen.users u ON m.anon_user_id = u.anon_user_id
#     JOIN  **for.forum_threads ft ON fp.thread_id = ft.id
#     JOIN  **for.forum_forums ff ON ft.forum_id = ff.id
#         WHERE u.access_group_id = 4 AND fp.deleted=0 AND fp.is_spam = 0 AND ft.deleted=0 AND ft.is_spam=0
#             AND ff.deleted=0"
# counts.sql.b.non<-"AND ff.id=##"
# counts.sql.b.subj<-"AND ff.id NOT IN (##)"
# counts.sql.c<-"GROUP BY continent, country"

# introductions, tech and subject all get slightly different treatment
counts.sql.non<-paste(counts.sql.a, counts.sql.b.non, counts.sql.c)
counts.intro<-list.limit.SELECT(db, courseIDs, counts.sql.non, intro.fid, echo=echo.sql)
counts.intro.df<-shape.toFrame(courseIDs, regions, counts.intro)
counts.tech<-list.limit.SELECT(db, courseIDs, counts.sql.non, tech.fid, echo=echo.sql)
counts.tech.df<-shape.toFrame(courseIDs, regions, counts.tech)
exclude.fid<-apply(cbind(intro.fid, tech.fid), 1, paste, collapse=",")
counts.sql.subj<-paste(counts.sql.a, counts.sql.b.subj, counts.sql.c)
counts.subj<-list.limit.SELECT(db, courseIDs, counts.sql.subj, exclude.fid, echo=echo.sql)
counts.subj.df<-shape.toFrame(courseIDs, regions, counts.subj)
# the proportion of people from each region-course who posted estimates the probability that a randomly selected person would have posted
postProb.intro<-counts.intro.df/userRegions.df
postProb.tech<-counts.tech.df/userRegions.df
postProb.subj<-counts.subj.df/userRegions.df


## @knitr POSTS_PER_PERSON
Pcounts.sql.a<-"SELECT c.ip_continent continent, c.ip_country country, count(1) users
                     FROM **for.forum_posts fp
JOIN **map.hash_mapping m ON m.forum_user_id = fp.forum_user_id 
JOIN **gen.uoe_ip_country c ON m.anon_user_id = c.anon_user_id
JOIN **gen.users u ON m.anon_user_id = u.anon_user_id
JOIN  **for.forum_threads ft ON fp.thread_id = ft.id
JOIN  **for.forum_forums ff ON ft.forum_id = ff.id
WHERE u.access_group_id = 4 AND fp.deleted=0 AND fp.is_spam = 0 AND ft.deleted=0 AND ft.is_spam=0
AND ff.deleted=0"
Pcounts.sql.b.non<-"AND ff.id=##"
Pcounts.sql.b.subj<-"AND ff.id NOT IN (##)"
Pcounts.sql.c<-"GROUP BY continent, country"

# only get the subject forum content
exclude.fid<-apply(cbind(intro.fid, tech.fid), 1, paste, collapse=",")
Pcounts.sql.subj<-paste(Pcounts.sql.a, Pcounts.sql.b.subj, Pcounts.sql.c)
Pcounts.subj<-list.limit.SELECT(db, courseIDs, Pcounts.sql.subj, exclude.fid, echo=echo.sql)
Pcounts.subj.df<-shape.toFrame(courseIDs, regions, Pcounts.subj)
# average posts per person
postsPerPerson.subj<-Pcounts.subj.df/userRegions.df

## @knitr BINOM_TESTS
bt.p<-function(xx,nn,pp){
   return(binom.test(x=xx,n=nn,p=pp, alternative="two.sided")$p.value)
}

#H0.probs contains the probability that the Null Hypothesis is true, two-tailed
# The Null hypothesis is that the probability that a person in a given region and course is equal to the average probability of posting across all regions (in a given course)
H0.probs<-data.frame(rep(character(0), length(userRegions.df[1,])))
for (i in 1:length(courseIDs)){
   pp<-sum(counts.subj.df[i,])/sum(userRegions.df[i,])
   H0.probs<-rbind(H0.probs,mapply(bt.p,counts.subj.df[i,],userRegions.df[i,], MoreArgs=list(pp=pp)))
}
colnames(H0.probs)<-colnames(userRegions.df)
rownames(H0.probs)<-rownames(userRegions.df)

## @knitr EXIT
# saves useful data
name<-"Regional Differences"
fname<-paste(name, ".RData", sep="")
metadata<-list(project=basename(getwd()), origin=name, created=date())
save(list=c("metadata", "userRegions.df"),
     file=fname)
cat(paste("Saved to",fname,"\r\n"))
#end tidily
dbDisconnect(db)

## ***Made available using the The MIT License (MIT)***
#The MIT License (MIT)
#Copyright (c) 2013 Adam Cooper, University of Bolton
#
#Permission is hereby granted, free of charge, to any person obtaining a copy of
#this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#    
#    The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
## ************ end licence ***************
