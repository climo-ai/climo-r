


#' Perform prediction / inference on a climo model
#'
#' @param model
#' @param newdata
#'
#' @return
#' @export
#'
#' @examples
#' model <- retrieve_model('nickcullen31/mixed-effects-model')
#' newdata <- data.frame(AGE = 75,
#'                       CDRSB_bl = 2.5,
#'                       PTGENDER = 'Male',
#'                       time = c(0,1,2))
#' result <- predict(model, newdata)
predict.climo <- function(model, newdata) {
  name <- glue('{model$user}__{model$slug}')
  v_model <- retrieve_vetiver_model(model$user, model$slug)
  predict_fn <- handler_predict(v_model)
  pred <- predict_fn(list(body=newdata))
  return(data.frame(pred))
}
