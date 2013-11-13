# an odd thing to do in R but...
# read all of the forum read data in its key/value form and insert into a nice DB table (see Prepare DB.R)
# ignores records at whole-forum level ("_all" records)
# deletes all prior content

#does not create read records for deleted (missing) users
#does not create read records for threads with 0 reads

# create tables to store result from Forum Read Extract.R
source("./dbConnect.R")
#source("./helpers.R")

courseIDs<-c("aiplan","astro","crit","edc","equine","intro")
kvsIDs<-c("284","310","290","314","312","366") #same order as courseIDS!

sql.drop <-"DROP TABLE IF EXISTS uoe_forum_reads"
sql.create<-"CREATE TABLE `uoe_forum_reads` (`forum_user_id` varchar(120) NOT NULL, `forum_id` int(11) NOT NULL, `thread_id` int(11) NOT NULL, `anon_user_id` varchar(120) NOT NULL, `read_time` int(11) NOT NULL,  PRIMARY KEY (`forum_user_id`,`thread_id`), KEY `anon_user_idx` (`anon_user_id`), KEY `forum_idx` (`forum_id`), KEY `thread_idx` (`thread_id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
sql.read<-"SELECT `key`, value FROM **for.`kvs_course.##.forum_readrecord` WHERE value NOT LIKE '%_all%'"
sql.hash<-"SELECT anon_user_id, forum_user_id from **map.hash_mapping WHERE user_id=##"
sql.insert<-"INSERT INTO **for.uoe_forum_reads (forum_user_id, anon_user_id, forum_id, thread_id, read_time) VALUES"

for(i in 1:length(courseIDs)){
   print(courseIDs[i])
   #set schema
   dbSendQuery(db, statement=paste("USE vpodata_",courseIDs[i],"for",sep=""))
   
   ## DROP and re-create tables
   dbSendQuery(db, statement=sql.drop)
   dbSendQuery(db, statement=sql.create)

   ## DATA
   #fetch all forum-reads data (key-value, with JSON values)
   sql.1<-gsub("##", sql.read, fixed=T, replacement=kvsIDs[i])
   sql.1<-gsub("**", sql.1, fixed=T, replacement=paste("vpodata_",courseIDs[i],sep=""))
   kv.df<-dbGetQuery(db,sql.1)
   #extract from key-values into a data frame
   sql.hash.1<-gsub("**", sql.hash, fixed=T, replacement=paste("vpodata_",courseIDs[i],sep=""))
   sql.insert.1<-gsub("**", sql.insert, fixed=T, replacement=paste("vpodata_",courseIDs[i],sep=""))
   for(ii in 1:length(kv.df[,1])){
      kk<-unlist(strsplit(as.character(kv.df[ii,"key"]),"[\\._]"))[2:3] #gives a length 2 vector with forum id and user id
      vv<-unlist(strsplit(gsub('i:','',gsub('.*\\{(.*)\\}','\\1',as.character(kv.df[ii,"value"]))), ";", fixed=T))
      thread_ids<-vv[c(T,F)]
      datetimes<-vv[c(F,T)]
      forum_id<-kk[1]
      sql.hash.11<-gsub("##", sql.hash.1, fixed=T, replacement=kk[2])
      mappedIDs<-dbGetQuery(db,sql.hash.11)
      if(length(mappedIDs)>0){#it is possible the user was deleted
         forum_user_id<-as.character(mappedIDs["forum_user_id"])
         anon_user_id<-as.character(mappedIDs["anon_user_id"])
         # push back to the database
         for(j in 1:length(thread_ids)){
            sql.insert.11<-paste(sql.insert.1,"(",paste("\'",forum_user_id,"\',\'", anon_user_id, "\',", forum_id,",", thread_ids[j],",", datetimes[j], sep=""),")")
            dbSendQuery(db,sql.insert.11)
         }
      }
   }

}
dbDisconnect(db)