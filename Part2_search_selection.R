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