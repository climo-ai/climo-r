
#API_URL <- 'https://climo-api-1253e7067c8b.herokuapp.com'
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
  models <- API_GET(url)
  models <- tibble::tibble(
    jsonlite::fromJSON(jsonlite::toJSON(models, auto_unbox=TRUE), flatten=TRUE)
  )
  return(models)
}


#' Title
#'
#' @param model
#'
#' @return
#' @export
#'
#' @examples
print.climo <- function(model) {
  cat('\n')
  cat(model$user, '/', model$slug, '\n', sep='')
  cat('------------------', '\n')
  cat('created:', model$created_date, '\n')
  cat('area:', model$area, '\n')
  cat('tags:', paste(model$tags, collapse=', '), '\n')
  cat('inputs:', length(model$inputs), '\n')
  cat('\n')
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

  response <- API_POST(glue('{API_URL}/models/'), record)

  file.remove(tmp_file)

  # TODO: return a climo model
  if (response$status != 201) {
    if (response$status == 400) {
      stop(paste('Error with:',
                 paste(names(response$response), collapse=', '),
                 '\n',
                 paste(response$response, collapse='\n')))
    }
    if (response$status == 500) {
      stop('Model with same user / name combination already exists')
    }
  }

  user <- response$response$user
  slug <- response$response$slug

  # now retrieve the model back
  model <- retrieve_model(glue('{user}/{slug}'))
  return(model)
}

#' Title
#'
#' @param user
#' @param name
#'
#' @return
#' @export
#'
#' @examples
#' model <- retrieve_model('nickcullen31/test-r-api-model2')
retrieve_model <- function(name) {
  str <- stringr::str_split_1(name, '/')
  user <- str[1]
  name <- str[2]
  url <- glue('{API_URL}/users/{user}/models/{name}/')
  response <- API_GET(url)

  if (response$status == 404) {
    stop('Model does not exist')
  }
  if (response$status == 403) {
    stop('CLIMO_API_KEY is not set or is not valid.')
  }
  if (response$status != 200) {
    stop('Error retrieving model.')
  }
  model <- response$content
  class(model) <- 'climo'

  # convert all inputs to climoInputs
  for (idx in seq_along(model$inputs)) {
    class(model$inputs[[idx]]) <- 'climoInput'
  }
  names(model$inputs) <- sapply(model$inputs, function(x) x$variable)
  return(model)
}


retrieve_vetiver_model <- function(user, name) {
  token <- token()
  response <- httr::GET(glue('{API_URL}/users/{user}/models/{name}/download'),
                        httr::add_headers('Authorization' = glue('Bearer {token}')))
  status <- response$status
  if (status == 403) stop('You must be authenticated to perform this action.
                          Have you set CLIMO_API_KEY with your token from climo.ai?')
  tmp <- tempfile(fileext = '.Rds')
  on.exit(unlink(tmp))
  writeBin(response$content, tmp)
  v_model <- readRDS(tmp)

  return(v_model)
}

