#' Title
#'
#' @param vetiver_model
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
handler_predict.lme <- function(vetiver_model, ...) {

  ptype <- vetiver_model$prototype
  function(req) {
    newdata <- req$body
    if (!purrr::is_null(ptype)) {
      newdata <- vetiver::vetiver_type_convert(newdata, ptype)
      newdata <- hardhat::scream(newdata, ptype)
    }

    vetiver_model$model$call$fixed <- formula(vetiver_model$model)
    model <- vetiver_model$model

    newdata$.pred <- nlme:::predict.lme(model, newdata = newdata, level = 0)

    if (!purrr::is_null(ptype)) {
      Designmat <- model.matrix(formula(model)[-2], newdata)
      predvar <- diag(Designmat %*% vcov(model) %*% t(Designmat))
      newdata$SE <- sqrt(predvar + model$sigma^2)
      newdata$.conf_lo = newdata$.pred - 1.96*newdata$SE
      newdata$.conf_hi = newdata$.pred + 1.96*newdata$SE

      res <- list(.pred = newdata$.pred,
                  .conf_lo = newdata$.conf_lo,
                  .conf_hi = newdata$.conf_hi)
    } else {
      res <- list(.pred = newdata$.pred)
    }

    return(res)
  }
}
