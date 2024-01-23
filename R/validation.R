

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
#' # continuous example
#' model <- retrieve_model('nickcullen31/mixed-effects-model')
#' newdata <- climo::example_lme_data
#' results <- evaluate_model(model, newdata)
#'
#' # binary example
#' model <- retrieve_model('tuoooliu/smoking-risk-on-cvd')
#' newdata <- climo::example_glm_data
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

  if (is.numeric(newdata[[output_var]])) {
    # calculate R2 for continuous outcomes
    record <- list(
      result = cor(newdata[[1]], pred),
      metric = 'r2',
      data = tibble::tibble(
        observed = newdata[[1]],
        predicted = pred
      )
    )
  } else {
    res <- pROC::roc(newdata[[output_var]] ~ pred, quiet=T)

    # calculate accuracy for categorical endpoints
    record <- list(
      result = res$auc,
      metric = 'auc',
      data = tibble::tibble(
        observed = newdata[[output_var]],
        predicted = pred
      )
    )
  }

  class(record) <- 'climoValidation'
  return(record)
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
    metric = results$metric,
    result = results$result,
    raw_data = list(
      observed = results$data$observed,
      predicted = results$data$predicted
    )
  )

  response <- API_POST(glue('{API_URL}/users/{model$user}/models/{model$slug}/validations/'),
                       record,
                       encode='json')
  if (response$status == 201) {
    cat('Validation successfully added')
  } else {
    stop('Validation not added. Does this model already have a validation from this cohort?')
  }
}


retrieve_validation <- function(model, cohort) {
  validation_name <- glue('{model$user}__{model$slug}__{cohort}')
}


evaluate.lm <- function(model, newdata) {

    predict_fn <- handler_predict(model, ...)

    pred <- predict_fn(list(body=newdata))$.pred

    metric_value <- cor(newdata[[1]], pred)
    result <- list(
        result = metric_value,
        metric = 'r2',
        data = tibble::tibble(
          observed = newdata[[1]],
          predicted = pred)
        )
    return(result)
}




