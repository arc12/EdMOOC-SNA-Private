## ****************************************************
## Created: Adam Cooper, Cetis, Oct 2013
## This source code was produced for The University of
## Edinburgh DEI as part of their MOOC initiative.
## Use saved igraph data (graphml)
## to calculate various network-level statistics
## including distributions of degree
## ****************************************************

# this is meant to be used from RStudio wit knitr but should work separately
# test if courseIDs has already been defined (in Rmd), otherwise default
if(!exists("courseIDs")){
   courseIDs<-c("aiplan","astro","crit","edc","equine","intro")
   net.type="P-C"
}

## @knitr INIT
library("igraph")
store.dir<-"~/R Projects/Edinburgh MOOC/EdMOOC-SNA/Network Data/" #where to store the extracted network to

# load graphml into igraph objects
igraphList<-lapply(courseIDs, function(x){read.graph(paste(store.dir,net.type," ", x,".graphml",sep=""), format="graphml")})
# igraphList<-list()
# for(i in 1:length(courseIDs)){
#    igraphList[[i]]<-read.graph(paste(store.dir,net.type," ", courseIDs[i],".graphml",sep=""), format="graphml")
# }

## @knitr SINGLES
# these are single stats for the each graph, rather than distributions
singles.df<-data.frame(rep(numeric(),8))
for(i in 1:length(courseIDs)){
   dyads<-dyad.census(igraphList[[i]])
   #    #graph level degree centrality is normalised relative to the max possible for #nodes and #vertices
   singles.df<-rbind(singles.df,c(
      nodes=vcount(igraphList[[i]]),
      ecount(igraphList[[i]]),
      1000*graph.density(igraphList[[i]], loops=FALSE),
      dyads$mut,
      dyads$asym,
      diameter(igraphList[[i]]),
      centralization.degree(igraphList[[i]], mode="in", loops=FALSE, normalized=TRUE)$centralization, #in degree
      centralization.degree(igraphList[[i]], mode="out", loops=FALSE, normalized=TRUE)$centralization #out degree)
   ))
}
colnames(singles.df)<-c("nodes","edges","graph density*1000","mutual dyads","asymmetric dyads","diameter","in degree","out degree")
row.names(singles.df)<-courseIDs

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
