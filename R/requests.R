



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


CLIMO_POST <- function(url, body) {
  token <- token()
  if (token == '') stop('Must have valid CLIMO API token to perform this action.')

  response <- httr::POST(
    url,
    body = body,
    encode = 'multipart',
    httr::add_headers('Authorization' = glue('Bearer {token}'))
  )
  json_response <- httr::content(response, type="application/json")
  return(list(response=json_response, status=response$status_code))
}



