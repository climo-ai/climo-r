

#' Title
#'
#' @param val
#'
#' @return
#' @export
#'
#' @examples
print.climo_input <- function(input) {

  if (input$type == 'continuous') {
    cat(input$label, ' (continuous) \n', sep='')
    cat(glue('Initial: {input$initial}\n\n'))
    cat('Range:', input$min, '-', input$max, '|', input$step)
  } else {
    cat(input$label, ' (categorical) \n', sep='')
    cat(glue('Initial: {input$initial}\n\n'))
    cat('Options:', paste(input$options, collapse=' | '))
  }

}




#' Title
#'
#' @param variable
#' @param label
#' @param type
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
#' input1 <- create_input('EXAMPLE', 'Example', 'continuous', min=0, max=10, step=1, initial=5)
#' input2 <- create_input('EXAMPLE2', 'Example2', 'categorical', options=c('a','b'), initial='a')
create_input <- function(variable,
                         label=NULL,
                         type=c('continuous', 'categorical'),
                         min=NULL,
                         max=NULL,
                         step=NULL,
                         options=NULL,
                         initial=NULL,
                         is_time=FALSE) {

  type = match.arg(type)

  if (type == 'continuous') {
    missing_vals <- is.null(min) || is.null(max) || is.null(step) || is.null(initial)
    if (missing_vals) stop('Continuous inputs must have a min, max, step, and initial value.')
  } else if (type == 'categorical') {
    missing_vals <- is.null(options) || is.null(initial)
    if (missing_vals) stop('Continuous inputs must have options and an initial value.')
    if (!initial %in% options) stop('The initial value must exist in the options.')
    if (length(options) == 1) options <- c(options)
  }

  if (is.null(label)) label <- variable

  val <- compact(list(
    variable = variable,
    label = label,
    type = type,
    min = min,
    max = max,
    step = step,
    options = options,
    initial = initial,
    is_time = is_time
  ))
  class(val) <- 'climo_input'
  return(val)
}
