



API_GET <- function(url) {
  token <- token()
  if (token == '') {
    response <- httr::GET(url)
  } else {
    response <- httr::GET(
      url,
      httr::add_headers('Authorization' = glue('Bearer {token}'))
    )
  }

  status <- response$status
  content <- httr::content(response, type="application/json")

  return(list(content=content, status=status))
}


API_POST <- function(url, body, encode=c('json', 'multipart', 'form', 'raw')) {
  encode <- match.arg(encode)
  token <- token()
  if (token == '') stop('Must have valid CLIMO API token to perform this action.')

  response <- httr::POST(
    url,
    body = body,
    encode = encode,
    httr::add_headers('Authorization' = glue('Bearer {token}'))
  )

  if (response$status == 500) {
    return(list(response=NULL, status=500))
  }
  # TODO: wrap in try catch because it fails on bad requests
  json_response <- httr::content(response, type="application/json")
  return(list(response=json_response, status=response$status_code))
}



