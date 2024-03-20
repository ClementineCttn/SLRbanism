### Code to exemplify Part 2 with Xiaoxia's query


# Section 1: Retrieve references from WoS and Scopus (Shuyu) 
# install and library packages for retrieving references from scopus (l did not find the wosr or rwos package for web of science.)
install.packages("rscopus")
library(rscopus)
install.packages("RefManageR")
library(RefManageR)
install.packages("dplyr")
library(dplyr)

# Set your API key, if you do not have, please go to the website of Elsevier Developer Portal: https://dev.elsevier.com/ to apply, and you will get the key.
options(elsevier_api_key = "Your_scopus_api_key")

# Set your research query
query <- "( ( ( TITLE ( govern* OR state OR decision-making OR policy-making OR stakeholder OR participat* ) ) AND ( TITLE-ABS-KEY ( impact OR outcome OR result OR differentiation OR consequence OR change OR transformation OR role ) ) ) OR ( TITLE-ABS-KEY ( governance W/0 ( mode OR model OR process ) ) ) ) AND 
          ( TITLE-ABS-KEY ( effect OR caus* OR explain* OR influence OR affect OR mechanism OR restrict OR create OR impact OR drive OR role OR transform* OR relation* OR led OR improve OR interven* OR respon* ) ) AND 
          ( TITLE-ABS-KEY ( effect OR caus* OR explain* OR influence OR affect OR mechanism OR restrict OR create OR impact OR drive OR role OR transform* OR relation* OR led OR improve OR interven* OR respon* ) ) AND 
          ( TITLE-ABS-KEY ( urban OR neighborhood OR city OR residential OR regional OR housing ) W/0 ( development OR redevelopment OR regeneration OR restructuring OR revitalization OR construction OR governance ) ) AND 
          ( LIMIT-TO ( DOCTYPE , \"ar\" ) ) AND 
          ( LIMIT-TO ( LANGUAGE , \"English\" ) )"

# search on scopus if you get the api key, you can modify the max_count for each searching
if (have_api_key()) {
  res <- scopus_search(query = query, max_count = 200, count = 10)
  search_results <- gen_entries_to_df(res$entries)
}

# Create an empty list to store search results
ids <- search_results$df$pii
search_results_list <- list()
for (id in ids) {
  search_results_list[[id]] <- search_results$df
}

# Convert the list to a data frame
results_df <- do.call(rbind, search_results$df)
transposed_results_df <- t(results_df)

# Write the details to a CSV file
write.csv(transposed_results_df, "scopus_api_results.csv", row.names = FALSE)

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


## ----prisma--------------------------------------------------------------
#install.packages("PRISMAstatement")
library(PRISMAstatement)

prisma(found = 750,
       found_other = 123,
       no_dupes = 776, 
       screened = 776, 
       screen_exclusions = 13, 
       full_text = 763,
       full_text_exclusions = 17, 
       qualitative = 746, 
       quantitative = 319,
       width = 800, height = 800)

## ----prismadupesbox------------------------------------------------------ Ideally, you will stick closely to the PRISMA statement, but small deviations are common. PRISMAstatement gives the option of adding a box which simply calculates the number of duplicates removed.
prisma(found = 750,
       found_other = 123,
       no_dupes = 776, 
       screened = 776, 
       screen_exclusions = 13, 
       full_text = 763,
       full_text_exclusions = 17, 
       qualitative = 746, 
       quantitative = 319,
       extra_dupes_box = TRUE)

## ----labels-------------------------------------------------------------- You can also change the labels, but you will have to insert the number for any label you chang
prisma(1000, 20, 270, 270, 10, 260, 20, 240, 107,
       labels = list(found = "FOUND", found_other = "OTHER"))

## ----errors and warnings-------------------------------------------------
tryCatch(
  prisma(1, 2, 3, 4, 5, 6, 7, 8, 9),
  error = function(e) e$message)
prisma(1000, 20, 270, 270, 10, 260, 19, 240, 107, 
       width = 100, height = 100)
prisma(1000, 20, 270, 270, 269, 260, 20, 240, 107, 
       width = 100, height = 100)

## ----font_size-----------------------------------------------------------
prisma(1000, 20, 270, 270, 10, 260, 20, 240, 107, font_size = 6)
prisma(1000, 20, 270, 270, 10, 260, 20, 240, 107, font_size = 60)

## ----prismadpi1, fig.cap="just set width and height"---------------------
prisma(found = 750,
       found_other = 123,
       no_dupes = 776, 
       screened = 776, 
       screen_exclusions = 13, 
       full_text = 763,
       full_text_exclusions = 17, 
       qualitative = 746, 
       quantitative = 319,
       width = 200, height = 200)

## ----prismadpi2, fig.cap="same width and height but DPI increased to 300"----
prisma(found = 750,
       found_other = 123,
       no_dupes = 776, 
       screened = 776, 
       screen_exclusions = 13, 
       full_text = 763,
       full_text_exclusions = 17, 
       qualitative = 746, 
       quantitative = 319,
       width = 200, height = 200,
       dpi = 300)

## ----prismadpi3, fig.cap="same width and height but DPI decreased to 36"----
prisma(found = 750,
       found_other = 123,
       no_dupes = 776, 
       screened = 776, 
       screen_exclusions = 13, 
       full_text = 763,
       full_text_exclusions = 17, 
       qualitative = 746, 
       quantitative = 319,
       width = 200, height = 200,
       dpi = 36)

## ----prismapdf, echo = TRUE, eval = FALSE--------------------------------
#  prsm <- prisma(found = 750,
#                 found_other = 123,
#                 no_dupes = 776,
#                 screened = 776,
#                 screen_exclusions = 13,
#                 full_text = 763,
#                 full_text_exclusions = 17,
#                 qualitative = 746,
#                 quantitative = 319,
#                 width = 200, height = 200,
#                 dpi = 36)
#  tmp_pdf <- tempfile()
#  PRISMAstatement:::prisma_pdf(prsm, tmp_pdf)
#  knitr::include_graphics(path = tmp_pdf)
#  unlink(tmp_pdf)


