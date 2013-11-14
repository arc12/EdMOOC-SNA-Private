source("./dbConnect.R")

courseIDs<-c("aiplan","astro","crit","edc","equine","intro")
schemaPrefix="vpodata_"
##place each statement on new line!!!!!!!!!!!!!
sql<-"ALTER TABLE `**map`.`hash_mapping` MODIFY anon_user_id varchar(120);
ALTER TABLE `**map`.`hash_mapping` MODIFY forum_user_id varchar(120);
ALTER TABLE `**map`.`hash_mapping` MODIFY session_user_id varchar(120);
ALTER TABLE `**map`.`hash_mapping` CONVERT TO CHARACTER SET utf8mb4;
CREATE INDEX forum_user_idx ON `**map`.`hash_mapping` (forum_user_id);"
# sql<-"ALTER TABLE **gen.uoe_ip_country MODIFY anon_user_id varchar(120);
# ALTER TABLE **gen.uoe_ip_country CONVERT TO CHARACTER SET utf8mb4;"

# sql<-"DROP INDEX forum_user_idx ON `**map`.`hash_mapping`"


for(sql.part in strsplit(sql,";\n")[[1]]){
   for(i in 1:length(courseIDs)){
      sql.1<-gsub("**", sql.part, fixed=T, replacement=paste(schemaPrefix,courseIDs[i],sep=""))
      print(sql.1)
      print(dbSendQuery(db, statement=sql.1))
   }
}
dbDisconnect(db)
