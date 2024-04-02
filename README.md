
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Final notes

I consider this project a dead end.

## Why?

I tried to do SAEMIX models with specific diff. models, several of them
on several datasets but the runtime was prohibitive despite best
efforts.

## What was achieved?

I scourged other packages for public, actual PK data and found ~10
datasets. They are enumerated in *inst/datasets.r*

I have implemented a one compartmental model both by calculating it
stepwise and by a *desolve* routine.

## What wasn’t achieved?

Didn’t wait for the SAEMIX to converge using an 84 obs. long dataset and
a one compartmental model. It was 2+hours wwhich was well above my
tolerance. I could have parallelized the problem but that would have
only meant a 10x increase in runtime, which was not enough for my
purposes. I imagine for more complicated models, and for datasets
including 1000+ observations it wouldn’t have sufficed.

## Parting thoughts, nagging feelings

I have tried to search for closed solutions for complex PK models, like
for specific two or three compartment models and found nothing. The
example for SAEMIX is for a 1 compartment model, (sometimes erroneously
referred to as a 2-compartment model) but every example and reference I
found used the exact same model which was annoying.

Keeping the repo public for transparency, and as a prime example of how
to take on more than you can chew which would result in a lot of
non-successses.

# HUPHAR2024.PK.presentation

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/PROJECTNAME)](https://CRAN.R-project.org/package=PROJECTNAME)
<!-- badges: end -->

The goal of HUPHAR2024_PK_presentation is to investigate the vibrance of
effects of different compartmental models based on public BE datasets
using SAEMIX.

As a reminder to myself, at each version bump I nned to update:

- README file (duh)  
- devtools::build_readme()
- NEWS file (project name)  
- DESCRIPTION (depends etc.)  
- devtools::document() your project after defining new functions under
  /R  
- devtools::build_site()
- then devtools::install()  
- only then devtools::check()

Notes:

- usethis::create_project() is a great resource  
- usethis::create_tidy_package() is also great

## Installation

You can ‘install’ the development version of PROJECTNAME from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("MartynK/HUPHAR2024_PK_presentation")
```

You’d need to have R and RStudio installed on your computer for the full
experience. The *.html* outputs are (usually) available in the
*vignettes* and *docs* subfolders.

## Further template-like notes

This is a basic example which shows you how to solve a common problem:

``` r
#library(HUPHAR2024.PK.presentation)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
