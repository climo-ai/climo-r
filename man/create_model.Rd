% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/models.R
\name{create_model}
\alias{create_model}
\title{Title}
\usage{
create_model(
  object,
  name,
  area,
  org = NULL,
  tags = NULL,
  visibility = c("public", "private")
)
}
\arguments{
\item{visibility}{}
}
\description{
Title
}
\examples{
model <- readRDS('~/Desktop/model.RDS')
create_model(model, 'test-r-api-model', area="Alzheimer's Disease")
}
