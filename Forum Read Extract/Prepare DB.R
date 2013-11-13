# create tables to store result from Forum Read Extract.R
source("./dbConnect.R")
#source("./helpers.R")

courseIDs<-c("aiplan","astro","crit","edc","equine","intro")
schemaPrefix="vpodata_"
sql.drop <-"DROP TABLE IF EXISTS uoe_forum_reads"
sql.create<-"CREATE TABLE `uoe_forum_reads` (`forum_user_id` varchar(120) NOT NULL, `thread_id` int(11) NOT NULL, `anon_user_id` varchar(120) NOT NULL, `read_time` int(11) NOT NULL,  PRIMARY KEY (`forum_user_id`,`thread_id`), KEY `anon_user_idx` (`anon_user_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"

for(i in 1:length(courseIDs)){
   dbSendQuery(db, statement=paste("USE ",schemaPrefix,courseIDs[i],"for",sep=""))
   dbSendQuery(db, statement=sql.drop)
   #dbSendQuery(db, statement=sql.create)
}
dbDisconnect(db)