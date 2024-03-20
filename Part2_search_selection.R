### Code to exemplify Part 2 with Xiaoxia's query


# Section 1: Retrieve references from WoS and Scopus (Shuyu) 
library(wosr)
library(rscopus)

# Section 2: Combine tables, deduplicate references and summarise (Kyri?) 
library(revtools)

# Section 3: Suggest new keywords (Clementine) 

# install.packages("remotes")
# library(remotes)
# install_github("elizagrames/litsearchr", ref="main")
library(litsearchr)
library(igraph)

#Import .bib or .ris database

#### initial search expression on scopus:
# TITLE-ABS-KEY ( effect OR caus* ) AND TITLE-ABS-KEY ( urban OR neighborhood OR city OR residential OR regional OR housing ) AND ( EXCLUDE ( DOCTYPE , "re" ) )
# retrieval of 1000 first scopus results out of 735,674 documents found on 15/02/2024

### adapted from litsearchr (deprecated) documentation 
# https://elizagrames.github.io/litsearchr/introduction_vignette_v010.html

refs <- litsearchr::import_results("data")

# identify frequent terms
raked_terms <- extract_terms(text = refs, 
                             method = "fakerake",
                             min_freq=2,
                             min_n=2)

# identify frequent keywords tagged by authors
keywords <- extract_terms(text = refs, 
                          method = "tagged",
                          keywords = refs$keywords,
                          ngrams=T,
                          min_n=2)

# create document-feature matrix
dfm <- create_dfm(elements = refs$title, 
                  features = c(raked_terms, keywords))

# create network
net <- create_network(search_dfm = dfm,
                      min_studies = 3,
                      min_occ = 3)


hist(igraph::strength(net), 
     main="Histogram of node strengths", 
     xlab="Node strength")


cutoffs_cumulative <- find_cutoff(net, method = "cumulative") 

reduced_graph <- reduce_graph(net, cutoff_strength = cutoffs_cumulative)

plot(reduced_graph)

search_terms <- litsearchr::get_keywords(reduced_graph)
head(sort(search_terms), 20)

# identify isolated components of graph
components(reduced_graph)
grouped <- split(names(V(reduced_graph)), components(reduced_graph)$membership)

litsearchr::write_search(grouped,
                         API_key = NULL,
                         languages = "English",
                         exactphrase = FALSE,
                         stemming = TRUE,
                         directory = "./",
                         writesearch = FALSE,
                         verbose = TRUE,
                         closure = "left")

# Section 4: build PRISMA figure (Xiaoxia)
library(PRISMA2020)