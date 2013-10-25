Dark Users
========================================================

Quantify the extent to which user identifiers left in activity traces (forums so far) do not appear in the hash_mapping and users tables. Main upshot is that we lack user attributes, although we could probably assume the dark users are withdrawn students and so impute access_group_id=4 without much error.

**gen.users and **map.hash_mapping are believed to correspond 1:1

The following considers forum_user_ids in threads, posts and comments. "Including dark" counts forum users as identified in the forum-specific tables, whereas "excluding dark" only counts those users with their forum_user_id also found in the hash_mapping table.


```
## Loading required package: DBI
```

```
## SELECT count(1) including_dark FROM (
##     (SELECT DISTINCT fp.forum_user_id from vpodata_aiplanfor.forum_posts fp)
##     UNION DISTINCT
##     (SELECT DISTINCT fc.forum_user_id from vpodata_aiplanfor.forum_comments fc)
##     UNION DISTINCT
##     (SELECT DISTINCT ft.forum_user_id from vpodata_aiplanfor.forum_threads ft) ) i
```

```
## SELECT count(1) excluding_dark FROM (
##     (SELECT DISTINCT fp.forum_user_id from vpodata_aiplanfor.forum_posts fp, vpodata_aiplanmap.hash_mapping m
##         WHERE fp.forum_user_id = m.forum_user_id)
##     UNION DISTINCT
##     (SELECT DISTINCT fc.forum_user_id from vpodata_aiplanfor.forum_comments fc, vpodata_aiplanmap.hash_mapping m
##         WHERE fc.forum_user_id = m.forum_user_id)
##     UNION DISTINCT
##     (SELECT DISTINCT ft.forum_user_id from vpodata_aiplanfor.forum_threads ft, vpodata_aiplanmap.hash_mapping m
##         WHERE ft.forum_user_id = m.forum_user_id) ) i
```


|id      | including_dark | excluding_dark | percent_lost |
|:-------|:--------------:|:--------------:|:------------:|
|aiplan  |       670      |       499      |      26      |
|astro   |      4398      |      3889      |      12      |
|crit    |      5139      |      4688      |       9      |
|edc     |      2941      |      2544      |      13      |
|equine  |      6412      |      6244      |       3      |
|intro   |      8145      |      6989      |      14      |


