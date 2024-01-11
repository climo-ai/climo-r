
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
#' Title
#'
#' @param object
#' @param name
#' @param area
#' @param org
#' @param tags
#' @param visibility
#'
#' @return
#' @export
#'
#' @examples
#' model <- readRDS('~/Desktop/model.RDS')
#' create_model(model, 'test-r-api-model', area="Alzheimer's Disease")
create_model <- function(object, name, area, org=NULL, tags=NULL,
                         visibility=c('public', 'private')) {
  visibility = match.arg(visibility)

  tmp_file <- tempfile(fileext = '.RDS')
  saveRDS(object, tmp_file)

  record <- list(
    name = name,
    area = area,
    language = 'R',
    org = org,
    visibility = stringr::str_to_title(visibility),
    file = httr::upload_file(tmp_file)
  )
  # tags must be split in list but have same name (`tags`)
  tags <- do.call(c, tags %>% purrr::map(~list(tags=.x)))
  record <- c(record, tags)

  response <- CLIMO_POST(glue('{API_URL}/models/'), record)

  file.remove(tmp_file)

  # TODO: return a climo model
  if (response$status != 201) {
    stop(paste('Error with:',
               paste(names(response$response), collapse=', '),
               '\n',
               paste(response$response, collapse='\n')))
  }

  return(response)
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




