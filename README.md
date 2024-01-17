
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

## Quickstart

This short overview of the climo package will go through installation
and creating a model that can be visualized at climo.ai.

To start, you can install the development version of climo with the
following statement:

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

Now, let’s create a model that can be uploaded to climo.ai using the
example dataset included in the climo package:

``` r
library(climo)
library(nlme)

model <- nlme::lme(CDRSB ~ CDRSB_bl + AGE + GENDER + TIME*CDRSB_bl,
                   random = ~ TIME | ID,
                   control = nlme::lmeControl(
                      maxIter = 1e10,
                      msMaxIter = 1000,
                      opt = "optim"
                   ),
                   data = climo::example,
                   na.action = stats::na.omit)
```

This `lme` model can then be used to create a climo model. All that is
needed is to call the `create_model` function and pass in the minimum
required arguments of the model object, a name for the model, and the
clinical area to which the model belongs (here, Alzheimer’s Disease):

``` r
climo_model <- climo::create_model(model, name="example-model', area='Alzheimers Disease')
```

And just like that, we now have a model upload to climo.ai. To visualize
the model interactively, we can go to climo.ai and visit our model page,
where we are able to add model inputs from the settings page.
Alternatively, we can add inputs directly from the climo package as
shown in the `Create your own model` exmaple.

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
climo_model <- climo::create_model(model, name="example-model', area='Alzheimers Disease')
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

### Add model inputs

The model inputs make up the interactive user interface to your model on
the climo.ai platform. They’re necessary if you want users to be able to
interact with your model at climo.ai.

There are two types of model inputs: continuous inputs and categorical
inputs.

Continuous inputs are represented by sliders for numeric variables, as
shown here:

![](man/figures/slider.png)

There are a couple of continuous input variables in our model (`AGE` and
`CDRSB_bl`), so we can create them as follows:

``` r
age_input <- climo::create_input('AGE', label='Age', type='continuous', min=50, max=90, step=1, initial=70)

cdrsb_input <- climo::create_input('CDRSB_bl', label='Baseline CDR-SB', type='continuous', min=0, max=10, step=0.5, initial=2.5)
```

Categorical inputs, on the other hand, are represented by dropdowns for
discrete variables.

![](man/figures/dropdown.png)

There is also one categorical input variable in the model which we can
create in a similar way:

``` r
gender_input <- climo::create_input('PTGENDER', label='Gender', type='categorical', options=c('Male','Female'), initial='Female')
```

You may have noticed that the `time` variable from the model was not
assigned an input. That’s by design – for longitudinal models, you
usually want to fix the time values in order to display a disease
progression curve over time. Therefore, you should add the time variable
as a continuous input, but give it multiple values and specify that it
represents the time variable.

``` r
time_input <- climo::create_input('time', label='Years from baseline', type='continuous', options=c(0, 0.5, 1, 1.5, 2), is_time=TRUE)
```

Finally, we have the inputs for all of the five variables in the model
and we can actually add them to the model.

``` r
climo_model %>% add_inputs(
    age_input,
    cdrsb_input,
    gender_input,
    time_input
)
```

By adding the inputs to the model, they will actually show up at
climo.ai and users can interact with the model. You can see the example
at climo.ai/climo/example-r-lme

And just to note, if you ever lose track of your model then you can
always retrieve it back from the platform:

``` r
climo_model <- climo::retrieve_model('climo/example-r-lme')
```

The platform is smart enough to know which models are yours and which
aren’t based on your API key – so no one else besides you can edit your
models in any way.

### Add model display

Now that the model has inputs, it is time to specify the display. The
display parameters control how the acutal figure that gets plotted looks
like. At this time, there is only one parameter available: the output
label which will serve as the y-axis label. Adding the display is
simple:

``` r
climo_model %>% add_display(output_label = 'CDR-SB')
```

Now, when the figure is plotted it will show the correct output label
rather than the default value of “Output”.

### Add model details

The model visualization is now complete, but there is still more to do.
It’s important to provide details about an uploaded model so that other
users can get an idea of how the model was fit, what its limitations
are, and what the appropriate context for the model is. This information
can be provided in the model details, which is by default composed of
four sections:

- Participants
- Outcome
- Predictors
- Methods

The participants section should fully describe the number and
characteristics of the individuals whose data was used when fitting the
model, along with any other important information about the study
cohort. The outcome section should describe how the outcome variable was
collected and its relevance for the disease. Similarly, the predictors
section should describe how all of the predictors (or inputs or
covariates - however you would like to call them) were collected.
Finally, the methods section should give a full description of the model
itself – how it was fit and evaluated, and what software packages were
used.

Following the same pattern as before, the model details can be added
like this:

``` r
climo_model %>% add_details(
  participants = "This is the participants section",
  outcome = "This is the outcome section",
  predictors = "This is the predictors section",
  methods = "This is the methods section",
)
```

Now, we have a model on the climo.ai platform which is available for
users to interactive visualize and which also includes key details about
the model. The final model can be visited at
`www.climo.ai/{your_username}/example-model`.

## Evaluate another user’s model

## Contribute data to a federation

## Fit a federated model

## List all models
