% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/HelperFunctions.R
\name{parseExtraParams}
\alias{parseExtraParams}
\title{parse parameters passed through the ... variable}
\usage{
parseExtraParams(allParams, extraParams)
}
\arguments{
\item{allParams}{list of all parameters}

\item{extraParams}{list of parameters in ...}
}
\value{
allParams with any valid parameters in extraParams added
}
\description{
parse parameters passed through the ... variable
}
\note{
will halt with an error if any parameters in extraParams are invalid
}
\keyword{internal}
