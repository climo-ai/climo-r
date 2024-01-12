

#' Title
#'
#' @param val
#'
#' @return
#' @export
#'
#' @examples
print.climoInput <- function(input) {

  if (input$variable_type == 'numeric') {
    cat('\n')
    cat(input$label, ' (numeric) \n', sep='')
    cat(glue('Initial: {input$num_value}\n\n'))
    cat('Range:', input$min_value, '-', input$max_value, '|', input$step_value, '\n')
    cat('\n')
  } else {
    cat('\n')
    cat(input$label, ' (character) \n', sep='')
    cat(glue('Initial: {input$str_value}\n\n'))
    cat('Options:', paste(input$options, collapse=' | '), '\n')
    cat('\n')
  }

}


#' Title
#'
#' @param model
#' @param ...
#' @param replace
#'
#' @return
#' @export
#'
#' @examples
#' model <- retrieve_model('nickcullen31/test-r-api-model32233')
#' input1 <- create_input('EXAMPLE', 'Example', 'numeric', min_value=0, max_value=10, step_value=1, initial_value=5)
#' input2 <- create_input('EXAMPLE2', 'Example2', 'character', options=c('a','b'), initial_value='a')
#' model <- model %>% add_inputs(input1, input2, replace=TRUE)
add_inputs <- function(model, ..., replace=FALSE) {
  inputs <- list(...)

  # have to remove climoInput class because jsonlite errors:
  for (idx in seq_along(inputs)) {
    class(inputs[[idx]]) <- 'list'
  }

  user <- model$user
  slug <- model$slug

  if (replace) {
    url <- glue('{API_URL}/users/{user}/models/{slug}/inputs/?replace=true')
  } else {
    url <- glue('{API_URL}/users/{user}/models/{slug}/inputs/')
  }

  response <- API_POST(url, body = inputs)

  if (response$status == 400) {
    cat('Error:\n')
    print(response$response)
    stop('See above error')
  }

  # add inputs to model objects
  #names(inputs) <- sapply(inputs, function(x) x$variable)
  #model$inputs <- c(model$inputs, inputs)
  model <- retrieve_model('nickcullen31/test-r-api-model32233')

  return(model)
}



#' Title
#'
#' @param variable
#' @param label
#' @param variable_type
#' @param min
#' @param max
#' @param step
#' @param options
#' @param initial
#' @param is_time
#'
#' @return
#' @export
#'
#' @examples
#' input1 <- create_input('EXAMPLE', 'Example', 'numeric', min_value=0,
#' max_value=10, step_value=1, initial_value=5)
#' input2 <- create_input('EXAMPLE2', 'Example2', 'character',
#' options=c('a','b'), initial_value='a')
create_input <- function(variable,
                         label=NULL,
                         variable_type=c('numeric', 'character'),
                         min_value=NULL,
                         max_value=NULL,
                         step_value=NULL,
                         options=NULL,
                         initial_value=NULL,
                         is_time=FALSE) {

  variable_type = match.arg(variable_type)

  if (variable_type == 'numeric') {
    missing_vals <- is.null(min_value) || is.null(max_value) ||
                    is.null(step_value) || is.null(initial_value)
    if (missing_vals) stop('Continuous inputs must have a min, max, step, and initial value.')
    num_value <- initial_value
    str_value <- NULL
  } else if (variable_type == 'character') {
    missing_vals <- is.null(options) || is.null(initial_value)
    if (missing_vals) stop('Continuous inputs must have options and an initial value.')
    if (!initial_value %in% options) stop('The initial value must exist in the options.')
    if (length(options) == 1) options <- c(options)
    str_value <- initial_value
    num_value <- NULL
  }

  if (is.null(label)) label <- variable

  val <- compact(list(
    variable = variable,
    label = label,
    variable_type = variable_type,
    min_value = min_value,
    max_value = max_value,
    num_value = num_value,
    step_value = step_value,
    options = options,
    str_value = str_value,
    grid_value = NULL,
    is_time = is_time
  ))
  class(val) <- 'climoInput'
  return(val)
}
