### Code to exemplify Part 2 with Xiaoxia's query


# Section 1: Retrieve references from WoS and Scopus (Shuyu) 
# install and library packages for retrieving references from scopus
install.packages("rscopus")
library(rscopus)
install.packages("RefManageR")
library(RefManageR)
install.packages("dplyr")
library(dplyr)
install.packages("bibtex")
library(bibtex)

# Retrieving references from scopus:
# Set your API key, if you do not have, please go to the website of Elsevier Developer Portal: https://dev.elsevier.com/ to apply, and you will get the key.
options(elsevier_api_key = "2c0614ca818c346334428faf3a859374") #"Your_scopus_api_key"

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
df <- read.csv("scopus_api_results.csv")

# Example dataframe with additional fields
data <- data.frame(
  Author = df$dc.creator,
  Title = df$dc.title,
  Year = sub(".*\\s(\\d{4})$", "\\1", df$prism.coverDisplayDate),
  Journal = df$prism.publicationName,
  Volume = df$prism.volume,
  Number = df$article.number,
  Pages = df$prism.pageRange,
  DOI = df$prism.doi
)

# Convert the dataframe to a BibEntryList object
# Create a list of BibEntry objects
bib_entries <- lapply(1:nrow(data), function(i) {
  BibEntry(
    bibtype = "Article",        # Add the bibtype argument
    key = paste0(substr(data$Author[i], 1, 1), data$Year[i]),
    author = data$Author[i],    # Add author field
    title = data$Title[i],      # Add title field
    year = data$Year[i],        # Add year field
    journal = data$Journal[i],  # Add journal field
    volume = data$Volume[i],    # Add volume field
    number = data$Number[i],    # Add number field
    pages = data$Pages[i],      # Add pages field
    doi = data$DOI[i]           # Add DOI field
  )
})

# Convert each BibEntry object to BibTeX format individually
bib_texts <- lapply(bib_entries, toBibtex)

# Combine the BibTeX texts into a single character vector
bib_text <- unlist(bib_texts, use.names = FALSE)

# Write BibTeX file
writeLines(bib_text, "scopus_references.bib")


# Retrieving references from web of science:
# wors package is not working now? l tried many times with the username and password but could not connect to the server.

# l found a another solution with the python: https://github.com/clarivate/wosstarter_python_client

# Run the wosstarter_api.ipynb in the repository and you will get four api_response_page1.txt to api_response_page4.txt

# Method1: create bib file with single txt file
# Read content from the file
content <- readLines("api_response_page2.txt", warn = FALSE)

# Define regular expression patterns to extract information
author_pattern <- "DocumentNames\\(authors=\\[AuthorName\\(display_name=['\"](.*?)['\"]"
title_pattern <- " title=['\"](.*?)['\"]"
source_title_pattern <- "source_title=['\"](.*?)['\"]"
publish_year_pattern <- "publish_year=(\\d+)"
volume_pattern <- "volume=('\\d+'|None)"
article_number_pattern <- "article_number=('\\S+'|None)"
pages_pattern <- "pages=DocumentSourcePages\\(range=('\\d+-\\d+'|None)"
doi_pattern <- "doi=('\\S+'|None)"

# Extract information using regular expressions
author <- regmatches(content, gregexpr(author_pattern, content))[[1]]
title <- regmatches(content, gregexpr(title_pattern, content))[[1]]
source_title <- regmatches(content, gregexpr(source_title_pattern, content))[[1]]
publish_year <- regmatches(content, gregexpr(publish_year_pattern, content))[[1]]
volume <- regmatches(content, gregexpr(volume_pattern, content))[[1]]
article_number <- regmatches(content, gregexpr(article_number_pattern, content))[[1]]
pages <- regmatches(content, gregexpr(pages_pattern, content))[[1]]
doi <- regmatches(content, gregexpr(doi_pattern, content))[[1]]

# Combine extracted information into a data frame
bib_data <- data.frame(
  Author = gsub(author_pattern, "\\1", author),
  Title = gsub(title_pattern, "\\1", title),
  Year = gsub(source_title_pattern, "\\1", source_title),
  Journal = gsub(publish_year_pattern, "\\1", publish_year),
  Volume = gsub(volume_pattern, "\\1", volume),
  Number = gsub(article_number_pattern, "\\1", article_number),
  Pages = gsub(pages_pattern, "\\1", pages),
  DOI = gsub("doi='|'", "", doi)
)

# Delete ''in the some columns
bib_data$Volume <- gsub("'", "", bib_data$Volume)
bib_data$Number <- gsub("'", "", bib_data$Number)
bib_data$Pages <- gsub("'", "", bib_data$Pages)

# Create a list of BibEntry objects 
# (l got problems that l cannot extract title from those cases:title="'Inner-city is not the place for social housing' - State-led gentrification in Lodz" and '"Freeways without futures": Urban highway removal in the United States and Spain as socio-ecological fix?' )
bib_wos_entries <- lapply(1:nrow(bib_data), function(i) {
  BibEntry(
    bibtype = "Article",        # Add the bibtype argument
    key = paste0(substr(bib_data$Author[i], 1, 1), bib_data$Year[i]),
    author = bib_data$Author[i],    # Add author field
    title = bib_data$Title[i],      # Add title field
    year = bib_data$Year[i],        # Add year field
    journal = bib_data$Journal[i],  # Add journal field
    volume = bib_data$Volume[i],    # Add volume field
    number = bib_data$Number[i],    # Add number field
    pages = bib_data$Pages[i],      # Add pages field
    doi = bib_data$DOI[i]           # Add DOI field
  )
})

# Convert each BibEntry object to BibTeX format individually
bib_wos_texts <- lapply(bib_wos_entries, toBibtex)

# Combine the BibTeX texts into a single character vector
bib_wos_text <- unlist(bib_wos_texts, use.names = FALSE)

# Write BibTeX file
writeLines(bib_wos_text, "wos_references.bib")

# Method2: create bib file with multiple txt files
library(stringr)

# Function to read content from a text file and extract information
read_and_extract <- function(file_path) {
  # Read content from the file
  content <- readLines(file_path, warn = FALSE)
  
  # Define regular expression patterns to extract information
  author_pattern <- "DocumentNames\\(authors=\\[AuthorName\\(display_name=['\"](.*?)['\"]"
  title_pattern <- " title=['\"](.*?)['\"]"
  source_title_pattern <- "source_title=['\"](.*?)['\"]"
  publish_year_pattern <- "publish_year=(\\d+)"
  volume_pattern <- "volume=('\\d+'|None)"
  article_number_pattern <- "article_number=('\\S+'|None)"
  pages_pattern <- "pages=DocumentSourcePages\\(range=('\\d+-\\d+'|None)"
  doi_pattern <- "doi=('\\S+'|None)"
  
  # Extract information using regular expressions
  author <- regmatches(content, gregexpr(author_pattern, content))[[1]]
  title <- regmatches(content, gregexpr(title_pattern, content))[[1]]
  source_title <- regmatches(content, gregexpr(source_title_pattern, content))[[1]]
  publish_year <- regmatches(content, gregexpr(publish_year_pattern, content))[[1]]
  volume <- regmatches(content, gregexpr(volume_pattern, content))[[1]]
  article_number <- regmatches(content, gregexpr(article_number_pattern, content))[[1]]
  pages <- regmatches(content, gregexpr(pages_pattern, content))[[1]]
  doi <- regmatches(content, gregexpr(doi_pattern, content))[[1]]
  
  # Combine extracted information into a data frame
  bib_data <- data.frame(
    Author = gsub(author_pattern, "\\1", author),
    Title = gsub(title_pattern, "\\1", title),
    Year = gsub(source_title_pattern, "\\1", source_title),
    Journal = gsub(publish_year_pattern, "\\1", publish_year),
    Volume = gsub(volume_pattern, "\\1", volume),
    Number = gsub(article_number_pattern, "\\1", article_number),
    Pages = gsub(pages_pattern, "\\1", pages),
    DOI = gsub("doi='|'", "", doi)
  )
  
  # Delete '' in some columns
  bib_data$Volume <- gsub("'", "", bib_data$Volume)
  bib_data$Number <- gsub("'", "", bib_data$Number)
  bib_data$Pages <- gsub("'", "", bib_data$Pages)
  
  return(bib_data)
}

# List of file paths
file_paths <- c("api_response_page1.txt", "api_response_page2.txt", "api_response_page3.txt", "api_response_page4.txt")

# Read data from each file and combine them into one data frame
combined_data <- do.call(rbind, lapply(file_paths, read_and_extract))

# Create a list of BibEntry objects
bib_entries <- lapply(1:nrow(combined_data), function(i) {
  BibEntry(
    bibtype = "Article",
    key = paste0(substr(combined_data$Author[i], 1, 1), combined_data$Year[i]),
    author = combined_data$Author[i],
    title = combined_data$Title[i],
    year = combined_data$Year[i],
    journal = combined_data$Journal[i],
    volume = combined_data$Volume[i],
    number = combined_data$Number[i],
    pages = combined_data$Pages[i],
    doi = combined_data$DOI[i]
  )
})

# Convert each BibEntry object to BibTeX format individually
bib_texts <- lapply(bib_entries, toBibtex)

# Combine the BibTeX texts into a single character vector
bib_text <- unlist(bib_texts, use.names = FALSE)

# Write BibTeX file
writeLines(bib_text, "wos_references.bib")

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


