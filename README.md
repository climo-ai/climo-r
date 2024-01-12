
<!-- README.md is generated from README.Rmd. Please edit that file -->

# climo

<!-- badges: start -->
<!-- badges: end -->

The climo package is the R interface to the climo.ai platform. With the
climo package, you can create, evaluate, share, and collaborate on
clinical models directly from the R language. The climo.ai platform
follows the belief that individuals, labs, and companies can contribute
a great deal to building better clinical prediction models by sharing
models rather than entire datasets.

## Installation

You can install the development version of climo with the following
statement:

``` r
devtools::install_github("climo-ai/climo-r")
```

Additionally, to use most of the climo R functions you will need to
retrieve your API key from the climo.ai platform and set it in your R
environment. After signing in at climo.ai, you can go to Home \> Profile
at climo.ai and copy the API key. Then, run the following command to set
your key in R:

``` r
Sys.setenv('CLIMO_API_KEY' = '__your key__')
```

If you want the key to persist between R sessions, you can set the key
in your R environment by running `usethis::edit_r_environ()` and adding
the line `CLIMO_API_KEY="__your key__"` to the `.Renviron` file. Now,
you wont have to set the API key every time you start R.

You can check that your API key is correctly set by running
`Sys.getenv('CLIMO_API_KEY')`

## Create your own model

A model can be created for the climo.ai platform directly from the climo
R package by using the `create_model` function. A basic example could be
that you have just fit a mixed-effects model with the `nlme` package and
want to share it on the climo.ai platform.

First, you fit the model with your method of choice (here, the `nlme`
package):

``` r
library(nlme)
model <- lme(x ~ y, data)
```

Now, you can upload the model to climo.ai using the climo R package. To
create a climo model, you need at least three things: a fitted object
(e.g., lme object), a name for your climo model, and a clinical area.

``` r
library(climo)
climo::create_model(model, name="example-model', area='Alzheimers Disease')
```

It’s that simple! Now the model will exist on climo.ai and you can
navigate to it on the web via the URL
`climo.ai/{your_username}/example-model`.

To note, there are other parameters that can be set in the
`create_model()` functions – things like giving your model some tags,
setting the model visibility to private, or assigning your model to an
organization.

### Add details

### Add inputs

### Add display

## Evaluate another user’s model

## Contribute data to a federation

## Fit a federated model

## List all models
