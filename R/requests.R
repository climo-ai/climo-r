


CLIMO_GET <- function(url) {
  token <- token()
  if (token == '') {
    response <- httr::GET(url)
  } else {
    response <- httr::GET(
      url,
      httr::add_headers('Authorization' = glue('Bearer {token}'))
    )
  }

  response <- httr::content(response, type="application/json")
  return(response)
}
