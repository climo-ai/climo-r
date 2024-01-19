

#' Title
#'
#' @param validation
#'
#' @return
#' @export
#'
#' @examples
print.climoValidation <- function(validation) {
  cat('\n')
  cat('Validation of climo model')
  cat('\n')
  cat(validation$metric, ' : ', validation$result)
}

#' Evaluate a climo model on new data
#'
#' @param model
#' @param newdata
#'
#' @return
#' @export
#'
#' @examples
#' model <- retrieve_model('nickcullen31/mixed-effects-model')
#' newdata <- climo::example_data
#' results <- evaluate_model(model, newdata)
evaluate_model <- function(model, newdata) {
  v_model <- retrieve_vetiver_model(model$user, model$slug)
  predict_fn <- handler_predict(v_model)

  if (!is.null(v_model$prototype)) {
    input_vars <- colnames(v_model$prototype)
  } else {
    input_vars <- all.vars(formula(v_model$model))[-1]
  }

  output_var <- all.vars(formula(v_model$model))[1]
  newdata <- newdata %>%
    dplyr::select(all_of(c(output_var, input_vars))) %>%
    dplyr::filter(complete.cases(.))

  pred <- predict_fn(list(body=newdata[,-1]))$.pred

  metric_value <- cor(newdata[[1]], pred)

  result <- list(
    result = metric_value,
    metric = 'r2',
    data = tibble::tibble(
      observed = newdata[[1]],
      predicted = pred
    )
  )
  class(result) <- 'climoValidation'
  return(result)
}



#' Submit a model validation to climo.ai
#'
#' @param model
#' @param validation
#' @param cohort
#' @param internal
#'
#' @return
#' @export
#'
#' @examples
add_validation <- function(model, validation, cohort, internal) {

  validation$cohort <- cohort
  validation$internal <- internal

  # upload validation to aws
  tmp_file <- tempfile(fileext = '.RDS')
  saveRDS(validation, tmp_file)

  record <- list(
    cohort = cohort,
    internal = internal,
    file = httr::upload_file(tmp_file)
  )

  response <- API_POST(glue('{API_URL}/users/{model$user}/models/{model$slug}/validations/'), record)
  print(response)

}


retrieve_validation <- function(model, cohort) {
  validation_name <- glue('{model$user}__{model$slug}__{cohort}')
}





