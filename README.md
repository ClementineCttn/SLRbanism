# A guide and toolbox for conducting systematic literature reviews in urbanism

- [Clémentine Cottineau](https://github.com/ClementineCttn)
- [Claudiu Forgaci](https://github.com/cforgaci)
- [Kyri Janssen](https://github.com/KyriJanssen)
- [Bayi Li](https://github.com/BayiLi081)
- [Shuyu Zhang](https://github.com/hadyyu)
- [Xiaoxia Zhang](https://github.com/valaneila)

  
## Context
Literature reviews are key components of academic research. Indeed, before taking on new research, it is necessary to gather, examine and assess existing knowledge on the topic, so as to position where new findings can take place, how they compare with existing evidence, and the level of novelty they bring. Literature reviews consist in selecting relevant publications related to a particular topic and summarising, analysing and interpreting their content in an organised and critical way. 
In this guide and toolbox, we offer guidance on how to choose the optimal type of review for a given aim and which tools to use to conduct the review itself (including selection, analysis and reporting). We aim to instrumentalise our guidelines with tools, recent examplesand reusable snippets of code, which should be accessible to an audience of urbanists and urban scholars. Our tool of choice is the open-source statistical software R because of the possibilities it offers for an open and reproducible workflow. It is by no means the only option available and we often point out tools that may complement R in specific steps of the workflow. 
Oue written guidelines are to be found [here]().

## Content
This repository is composed of:
- two computational notebooks corresponding to two specific steps of systematic literature reviews: the search phase (names/links) and the analysis phase (names/links)
- the external data necessary to run the examples
- the outputs and figures generated 

## How to use this repository

This repository contains two computational notebooks, `SLRbanism_companion_search.qmd` and `SLRbanism_companion_analysis.qmd`. Computational notebooks are environments that combine:

- **narrative** written in [Markdown](https://www.markdowntutorial.com/), a markup language with a simple syntax for text formatting,
- **executable code** written in the R programming language, and
- **output**, such as plots and tables generated from data, all in one place. 

### Setup

To run the analyses in the computational notebooks on your computer, you will need to: 

1.  Install [R, RStudio Desktop](https://posit.co/download/rstudio-desktop/), [Python](https://www.python.org/downloads/) and [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) for your operating system.

2.  Create an RStudio project from `File > New Project... > Version Control > Git` with the URL `https://github.com/ClementineCttn/SLRbanism.git` and project directory name `SLRbanism`. Browse to a location of your choice on your computer and click on `Create Project`. This will create a project directory populated with the all files from this repository.

3.  Open `SLRbanism_companion_search.qmd` or `SLRbanism_companion_analysis.qmd` from the Files tab in Rstudio. These two files are the computational notebooks corresponding to the guideline chapters 2 and 3, respectively.

4.  When you first open the document, RStudio will display a message at the top of the document asking you to install missing packages. Make sure you install those packages as suggested in that message. If, for some reason, the installation of those packages fails, make sure you install each missing package by executing the command `install.packages("REPLACE_WITH_MISSING_PACKAGE_NAME")` in the R console found in the bottom left of RStudio.

5.  After all packages are installed, execute each code chunk of the computational notebook from top to bottom in sequence by clicking on the green arrow in the top right of the code chunk.

6.  If you want to see a rendered HTML version of the document, click on the Render button in RStudio.

### Scopus API keys

In order to run the [code related to the search strategy](https://clementinecttn.github.io/SLRbanism/SLRbanism_companion_search.html), you need to replace the API key with your own. To get your own Scopus API key, you need to apply for a personal key on the [Elsevier Developer Portal](https://dev.elsevier.com/) 


### Data

In order to run the [code related to the records' analysis](https://clementinecttn.github.io/SLRbanism/SLRbanism_companion_analysis.html), you need to download the example data from the [Open Science Framework](https://osf.io/ds83p) and save it in the "raw-data/" folder.


## License and citation
This repository is licensed under [CC-BY-4.0](https://creativecommons.org/licenses/by/4.0/).

It works as a companion notebook to our written [guidelines on systematic literature reviews for urbanists with R]().

Please cite the guidelines as:
Cottineau C., Forgaci C., Janssen K., Li B., Zhang S., Zhang X. (2024), Guidelines and programming toolbox for systematic literature reviews in Urbanism, Unpublished Working Paper.

Please cite this notebook as:
Cottineau C., Forgaci C., Janssen K., Li B., Zhang S., Zhang X. (2024), A guide and toolbox for conducting systematic literature reviews in urbanism,[Computer software]. https://github.com/ClementineCttn/SLRbanism

