EdMOOC-SNA
==========
_This repo is a store of my messy work in progress of SNA and related bits, shared with David and Edinburgh Uni folks for visibility._

See the wiki for a notepad on analysis ideas (very rough).

In general, files of type ... are ...:
* html - output reports, notebooks etc (include code fragments to document process)
* rmd - mixed R code and markdown intended to be put through _knitr_ to generate the html file with the same stem
* md - markdown file auto-generated by knitr in most cases
* R - R code, likely to be for pre-processing or including in rmd
* RData - typically one or more dataframes with some metadata, the stored result of executing the R or rmd with the same filename stem

Basic Forum Stats
---------
Looks at macro-level stats for forums per course: aggregate descriptive quantities and high level structural features. Some of this also appears in the 1st MOOC Report; this is partially a database familiarisation activity augmented by some processing to get some more basic numbers to inform next-steps and contextualise results.

Dark Users
----------

Quantify the extent to which user identifiers left in activity traces (forums so far) do not appear in the hash_mapping and users tables. These are assumed to be withdrawn users.

At present, it considers forum_user_ids in threads, posts and comments.

Network Extractors
-----------------

Contains code to build networks based on different assumptions of what a tie is. These are plain R code and output - for each course separately - .RData containing the network (using the data structure from the "network" package) and a graphml file (created using the "igraph" package). Gephi can consume the graphml file, or it may be read in using the igraph package. NB igraph and network packages are not mutually compatible.

### Poster-Commenter Network
The assumption of the following that a tie between individuals is defined by a comment on a post. This is a directed tie from the commenter to the poster.

ERGM Models
--------------------

Apply the ERGM approach to a network....