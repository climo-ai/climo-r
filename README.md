
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
environment. After signing in at climo.ai, navigate to Home \> Profile
and copy the API key. Then, run the following command in R to make your
key available for the climo package:

``` r
Sys.setenv('CLIMO_API_KEY' = '__your key__')
```

If you want the key to persist between R sessions, you can set the key
in your R environment by running `usethis::edit_r_environ()` and adding
the line `CLIMO_API_KEY="__your key__"` to the `.Renviron` file which
gets opened. That way you wont have to set the API key every time you
start R.

You can check that your API key is correctly set by running
`Sys.getenv('CLIMO_API_KEY')`

## Create your own model

Let’s say that you want to fit a mixed-effects model on data from
Alzheimer’s disease patients and then share it on the climo.ai platform.

First, you fit the model with your method of choice (here, the `nlme`
package):

``` r
library(nlme)
model <- lme(x ~ y, data)
```

Now, you can upload the model to climo.ai using the
`climo::create_model()` function. To create a climo model, you need at
least three things: a fitted object (e.g., lme object), a name for your
climo model, and a clinical area.

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

However, you won’t be able to actually see your model’s output at
climo.ai until you create the model signature which tells climo.ai how
to build the user interface which allows users to interact with your
model. We’ll show that next:

### Create model inputs

The model inputs make up the interactive user interface to your model on
the climo.ai platform. They’re necessary if you want users to be able to
interact with your model at climo.ai.

There are two types of model inputs: continuous inputs and categorical
inputs.

Continuous inputs are represented by sliders for numeric variables.

# slide image

There are a couple of continuous input variables in our model:

Categorical inputs, on the other hand, are represented by dropdowns for
discrete variables.

# dropdown image

<figure>
<img src="man/figures/dropdown.png" alt="dropdown image" />
<figcaption aria-hidden="true">dropdown image</figcaption>
</figure>

There is also one categorical input variable in the model:

You may have noticed that the `time` variable from the model was not
assigned an input. That’s by design – for longitudinal models, you
usually want to fix the time values in order to display a disease
progression curve over time. Therefore, you should add the time variable
as a continuous input, but give it multiple values and specify that it
represents the time variable.

``` r
```

### Add model display

### Add model details

## Evaluate another user’s model

## Contribute data to a federation

## Fit a federated model

## List all models
