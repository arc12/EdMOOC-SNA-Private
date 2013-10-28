## ****************************************************
## Created: Adam Cooper, Cetis, Oct 2013
## This source code was produced for The University of
## Edinburgh DEI as part of their MOOC initiative.
## Computes some basic statistics about forum use.
## ****************************************************

## Chunks intended for use with knitter in the Rmd file.
## Can be used independently of knitr but NB that some config parameters are set in the Rmd

## @knitr INIT

#establish connection to MySQL, loading library. contains coursera DB exports from 2013
source("../dbConnect.R")
#helper functions
source("../helpers.R")

## For all SQL here. The wildcard ** is for replacement by vpodata_equine etc.

## @knitr ACCESSED
accessed.sql <- "SELECT count(1) registered, sum(last_access_time >0) accessed FROM **gen.users WHERE access_group_id=4"
accessed.df<-tabular.SELECT(db, courseIDs, accessed.sql, echo=echo.sql)

## @knitr FORUM_COUNT
forumCount.sql <- "SELECT count(id) forums, sum(deleted) forums_deleted, sum(can_post) forums_can_post,
   (SELECT count(1) from **for.forum_subscribe_forums) forums_user_subscriptions
   from **for.forum_forums"
threadCount.sql <- "SELECT count(id) threads, sum(deleted) threads_deleted, sum(is_spam) threads_spam,
   sum(stickied) threads_stickied, sum(instructor_replied) threads_instructor_replied,
   sum(anonymous) threads_anonymous, avg(votes) threads_average_votes, 
   (SELECT count(1) from **for.forum_tags_threads) threads_tags,
   (SELECT count(1) from **for.forum_subscribe_threads) threads_user_subscriptions
   from **for.forum_threads"
postCount.sql <- "SELECT count(id) posts, sum(deleted) posts_deleted, sum(is_spam) posts_spam,
   sum(stickied) posts_stickied, sum(approved) posts_approved, sum(anonymous) posts_anonymous,
   avg(votes) posts_average_votes from **for.forum_posts"
commentCount.sql<-"SELECT count(id) comments, sum(deleted) comments_deleted,
   sum(is_spam) comments_spam, sum(anonymous) comments_anonymous, avg(votes) comments_average_votes
   from **for.forum_comments"
forumCount.df<-tabular.SELECT(db, courseIDs, forumCount.sql, echo=echo.sql)
threadCount.df<-tabular.SELECT(db, courseIDs, threadCount.sql, echo=echo.sql)
postCount.df<-tabular.SELECT(db, courseIDs, postCount.sql, echo=echo.sql)
commentCount.df<-tabular.SELECT(db, courseIDs, commentCount.sql, echo=echo.sql)

## - see lower down for FORUM_BUSHINESS for COUNT queries where deleted and spam are eliminated

## @knitr FORUM_ORPHANS
#posts in deleted threads or forums
orphanedPosts.sql<-"select count(1) 'orphan posts' FROM **for.forum_posts fp, **for.forum_threads ft,
                                                         **for.forum_forums ff
   WHERE fp.thread_id = ft.id AND ft.forum_id = ff.id AND fp.deleted=0 AND (ft.deleted = 1 OR ff.deleted = 1)"
#comments without parent post
orphanedComments1.sql<-"select count(1) 'orphan comments (parent)' FROM **for.forum_comments fc, **for.forum_posts fp
   WHERE fc.post_id = fp.id AND fc.deleted=0 AND fp.deleted = 1"
#comments with a deleted ancestor somewhere
orphanedCommentsAll.sql<-"select count(1) 'orphan comments' FROM **for.forum_comments fc, **for.forum_posts fp,
                                                   **for.forum_threads ft, **for.forum_forums ff
   WHERE fc.post_id = fp.id AND fp.thread_id = ft.id AND ft.forum_id = ff.id  AND fc.deleted=0 
            AND (fp.deleted = 1 OR ft.deleted = 1 OR ff.deleted = 1)"
orphans.df<-tabular.SELECT(db, courseIDs, orphanedPosts.sql, echo=echo.sql)
orphans.df<-cbind(orphans.df, tabular.SELECT(db, courseIDs, orphanedComments1.sql, echo=echo.sql))
orphans.df<-cbind(orphans.df, tabular.SELECT(db, courseIDs, orphanedCommentsAll.sql, echo=echo.sql))

## @knitr FORUM_TOP_STRUCT
forumTopStruct.sql <- "select ff.id, ff.name, ff.parent_id parent,
      FROM_UNIXTIME(ff.open_time, '%D %M %Y') 'open date', COUNT(ft.id) threads
   FROM **for.forum_forums ff LEFT OUTER JOIN **for.forum_threads ft ON ff.id = ft.forum_id
      WHERE ff.deleted=0 GROUP BY ff.id order by open_time"
forumTopStruct<-list.SELECT(db, courseIDs, forumTopStruct.sql, echo=echo.sql)

## @knitr POSTER_ROLES
posterRoles.sql<- "SELECT u.access_group_id, COUNT(fp.forum_user_id) posts
   FROM **for.forum_posts fp, **for.forum_threads ft, **for.forum_forums ff, **map.hash_mapping m, **gen.users u
      WHERE fp.thread_id = ft.id AND ft.forum_id = ff.id
         AND fp.forum_user_id = m.forum_user_id AND m.anon_user_id = u.anon_user_id 
         AND fp.deleted=0 AND ft.deleted = 0 AND ff.deleted = 0 AND fp.is_spam=0 GROUP BY u.access_group_id"
posterRoles<-list.SELECT(db, courseIDs, posterRoles.sql, echo=echo.sql)
#next is a bit hacky.
posterRoles.mat<-matrix(NA,0,9)
for(i in 1:length(posterRoles)){
   posterRoles.mat<- rbind(posterRoles.mat,t(posterRoles[[i]][match(1:9, posterRoles[[i]]$access_group_id),"posts"]))
}
posterRoles.df<- data.frame(posterRoles.mat)
posterRoles.df[is.na(posterRoles.df)]<-0
#colnames(posterRoles.df)<-paste("Role",seq(1,8),sep=".")
colnames(posterRoles.df)<- dbGetQuery(db,"select name from vpodata_equinegen.access_groups WHERE id<10 ORDER BY ID")[,1]
rownames(posterRoles.df)<-names(posterRoles)

## @knitr POSTER_DISTRIBUTION
# how many posts per person (excludes people who never posted
# students
posterDistS.sql<-"SELECT fp.forum_user_id, COUNT(fp.forum_user_id) posts
   FROM **for.forum_posts fp, **for.forum_threads ft, **for.forum_forums ff, **map.hash_mapping m, **gen.users u
   WHERE fp.thread_id = ft.id AND ft.forum_id = ff.id 
         AND fp.forum_user_id = m.forum_user_id AND m.anon_user_id = u.anon_user_id
         AND fp.deleted=0 AND ft.deleted = 0 AND ff.deleted = 0 AND fp.is_spam=0 AND u.access_group_id = 4
         GROUP BY fp.forum_user_id"
# teaching staff (incl instructor)
posterDistT.sql<-"SELECT fp.forum_user_id, COUNT(fp.forum_user_id) posts
   FROM **for.forum_posts fp, **for.forum_threads ft, **for.forum_forums ff, **map.hash_mapping m, **gen.users u
   WHERE fp.thread_id = ft.id AND ft.forum_id = ff.id 
         AND fp.forum_user_id = m.forum_user_id AND m.anon_user_id = u.anon_user_id
         AND fp.deleted=0 AND ft.deleted = 0 AND ff.deleted = 0 AND fp.is_spam=0 AND u.access_group_id IN (2,3)
         GROUP BY fp.forum_user_id"
posterDistS<-list.SELECT(db, courseIDs, posterDistS.sql, echo=echo.sql)
posterDistT<-list.SELECT(db, courseIDs, posterDistT.sql, echo=echo.sql)

## @knitr COMMENTER_DISTRIBUTION
# how many comments per person (excludes people who never commented
# students
commenterDistS.sql<-"SELECT fc.forum_user_id, COUNT(fc.forum_user_id) comments
   FROM  **for.forum_comments fc, **map.hash_mapping m, **gen.users u
   WHERE fc.forum_user_id = m.forum_user_id AND m.anon_user_id = u.anon_user_id
        AND fc.deleted=0 AND fc.is_spam=0 AND u.access_group_id =4
            GROUP BY fc.forum_user_id"
# teaching staff (incl instructor)
commenterDistT.sql<-"SELECT fc.forum_user_id, COUNT(fc.forum_user_id) comments
   FROM  **for.forum_comments fc, **map.hash_mapping m, **gen.users u
   WHERE fc.forum_user_id = m.forum_user_id AND m.anon_user_id = u.anon_user_id
        AND fc.deleted=0 AND fc.is_spam=0 AND u.access_group_id IN (2,3)
            GROUP BY fc.forum_user_id"
commenterDistS<-list.SELECT(db, courseIDs, commenterDistS.sql, echo=echo.sql)
commenterDistT<-list.SELECT(db, courseIDs, commenterDistT.sql, echo=echo.sql)

## @knitr FORUM_BUSHINESS
#similar to FORUM_COUNT but excluding deleted and spam (there are a few undeleted spam threads and posts)
forumCountX.sql <- "SELECT count(id) forums FROM **for.forum_forums WHERE deleted=0 AND parent_id >=0"
threadCountX.sql <- "SELECT count(ft.id) threads FROM  **for.forum_threads ft, **for.forum_forums ff
   WHERE ft.forum_id = ff.id AND ff.deleted=0 AND ft.deleted=0 AND ft.is_spam=0"
postCountX.sql <- "SELECT count(fp.id) posts
   FROM **for.forum_posts fp, **for.forum_threads ft, **for.forum_forums ff
      WHERE  ft.forum_id = ff.id AND fp.thread_id = ft.id
         AND ff.deleted=0 AND ft.deleted=0 AND ft.is_spam=0 AND fp.deleted=0 AND fp.is_spam=0"
commentCountX.sql<-"SELECT count(fc.id) comments
   FROM **for.forum_comments fc, **for.forum_posts fp, **for.forum_threads ft, **for.forum_forums ff
      WHERE ft.forum_id = ff.id AND fp.thread_id = ft.id AND fc.post_id = fp.id
         AND ff.deleted=0 AND ft.deleted=0 AND ft.is_spam=0 AND fp.deleted=0 AND fp.is_spam=0
         AND fc.deleted=0 AND fc.is_spam=0"
forumCountX.df<-tabular.SELECT(db, courseIDs, forumCountX.sql, echo=echo.sql)
threadCountX.df<-tabular.SELECT(db, courseIDs, threadCountX.sql, echo=echo.sql)
postCountX.df<-tabular.SELECT(db, courseIDs, postCountX.sql, echo=echo.sql)
commentCountX.df<-tabular.SELECT(db, courseIDs, commentCountX.sql, echo=echo.sql)

bushiness.df<-cbind(forums=forumCountX.df$forums,
                    thread_factor=threadCountX.df$threads/forumCountX.df$forums,
                    post_factor=postCountX.df$posts/threadCountX.df$threads,
                    comment_factor=commentCountX.df$comments/postCountX.df$posts)
rownames(bushiness.df)<-rownames(forumCountX.df)

## @knitr FORUM_DISTRIBUTION
# 1. post_commentDist.sql creates a compact summary but it isn't helpful for further processing
# it does include the count of posts with 0 comments (see OUTER JOIN)
post_commentDist.sql<-"SELECT comments, count(post_id) posts FROM (SELECT fp.id post_id,
   count(fc.id) comments from **for.forum_posts fp
      LEFT OUTER JOIN **for.forum_comments fc ON fc.post_id = fp.id  WHERE fp.deleted = 0 GROUP BY fp.id) a
       GROUP BY comments ORDER BY comments"
post_commentDist<-list.SELECT(db, courseIDs, post_commentDist.sql, echo=echo.sql)
#number of posts with 0 comments
post_0comments<-NULL
for(i in 1:length(post_commentDist)){
   post_0comments<-c(post_0comments, post_commentDist[[i]][1,"posts"])
}
names(post_0comments)<-names(post_commentDist)
# 2. post_commentDist2.sql is the full list of post ids with #comments BUT without those with 0 posts
post_commentDist2.sql <- "SELECT fp.id post_id, count(fc.id) comments from **for.forum_posts fp,
    **for.forum_comments fc WHERE fc.post_id = fp.id AND fp.deleted = 0  GROUP BY fp.id"
post_commentDist2<-list.SELECT(db, courseIDs, post_commentDist2.sql, echo=echo.sql)
   
## @knitr EXIT
# saves useful data
name<-"Basic Forum Stats"
fname<-paste(name, ".RData", sep="")
metadata<-list(project=basename(getwd()), origin=name, created=date())
save(list=c("accessed.df",
            "forumCount.df","threadCount.df","postCount.df","commentCount.df","bushiness.df",
            "orphans.df", "forumTopStruct",
            "posterRoles.df","posterDistS","posterDistT","commenterDistS","commenterDistT",
            "post_commentDist","post_commentDist2"),
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
