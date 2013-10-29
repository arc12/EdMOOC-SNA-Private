Poster-Commenter Network Level Description
========================================================

The assumption of "Poster-Commenter" that a tie between individuals is defined by a comment on a post. This is a directed tie from the commenter to the poster. A tie is assumed if there are 1 or more comments and ties are **not** weighted by the number of comments. Self-commenting (loops) are ignored; self-comments may indicate a discussion with a prior commenter, which may be of interest to a more detailed look at interaction patters.

__Individuals who withdrew (were deleted) are not counted; other analysis will rely on role information, which is not available for these people.__

_Could look at setting the tie threshold >1, in which case things get a lot more sparse_










|id      | nodes |edges  | graph density |mutual dyads  | asymmetric dyads |diameter  | in degree |out degree  |
|:-------|:-----:|:------|:-------------:|:-------------|:----------------:|:---------|:---------:|:-----------|
|aiplan  |  248  | 370   |    0.0060     | 23           |        324       |11        |  0.2548   |0.1817      |
|astro   | 2281  |5160   |    0.0010     |163           |       4834       |22        |  0.0258   |0.0298      |
|crit    | 1919  |2446   |    0.0007     | 18           |       2410       |31        |  0.0270   |0.0317      |
|edc     | 1688  |3517   |    0.0012     | 77           |       3363       |26        |  0.0463   |0.0327      |
|equine  | 2491  |4940   |    0.0008     |106           |       4728       |16        |  0.0623   |0.0543      |
|intro   | 3852  |8619   |    0.0006     |269           |       8081       |31        |  0.0265   |0.0428      |


Nodes are people and edges are poster-commenter relationships. The density is the proportion of possible edges that actually exist. Dyads are node pairs; mutuality indicates commenting has been reciprocated whereas asymmetry indicates a one-way relationship. The difference between the "edges" column and the sum of mutual and asymmetric dyads is accounted for by self-commenging edges. Diameter is the longest path between two people, in this case the direction of edges is significant. The degree statistics give a relative measure (relative to the theoretical maximum for the network size, and comparable between courses) of the extent to which in-bound or out-bound ties are concentrated. A value of zero would imply all people have the same degree centrality. A value of 1 would indicate that one person is maximally central. AI Planning is remarkably centralised.
