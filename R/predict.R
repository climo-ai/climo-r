


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
  v_model <- load_model_from_board(name)
  predict_fn <- handler_predict(v_model)
  pred <- predict_fn(list(body=newdata))
  return(data.frame(pred))
}

load_model_from_board <- function(name) {
  board <- pins::board_s3(bucket = 'sagemaker-vetiver',
                          access_key = Sys.getenv("AWS_ACCESS_KEY_ID"),
                          secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY"),
                          region = 'us-east-2')
  v_model <- vetiver::vetiver_pin_read(board, name)
  return(v_model)
}
