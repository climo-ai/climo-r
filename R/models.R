
API_URL <- 'http://127.0.0.1:8000'

# list all models
#' Title
#'
#' @param users
#' @param areas
#' @param tags
#'
#' @return
#' @export
#'
#' @examples
list_models <- function(users=NULL, areas=NULL, tags=NULL) {
  url <- glue('{API_URL}/models/')
  models <- CLIMO_GET(url)
  models <- tibble::tibble(
    jsonlite::fromJSON(jsonlite::toJSON(models, auto_unbox=TRUE), flatten=TRUE)
  )
  return(models)
}


# retrieve a specific model object
retrieve_model <- function(name) {

}

# create a model
create_model <- function(object, name, area, org=NULL, tags=NULL,
                         visibility=c('public', 'private')) {

}

# add details to model
add_details <- function(model, details) {

}

# add inputs to model
add_inputs <- function(model, inputs) {

}

# add display to model
add_display <- function(model, display) {

}




