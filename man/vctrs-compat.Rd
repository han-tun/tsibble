% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compat-vctrs.R, R/yearmonth.R, R/yearquarter.R,
%   R/yearweek.R
\name{vctrs-compat}
\alias{vctrs-compat}
\alias{vec_cast.yearmonth}
\alias{vec_ptype2.yearmonth}
\alias{vec_arith.yearmonth}
\alias{obj_print_data.yearmonth}
\alias{vec_cast.yearquarter}
\alias{vec_ptype2.yearquarter}
\alias{vec_arith.yearquarter}
\alias{obj_print_data.yearquarter}
\alias{vec_cast.yearweek}
\alias{vec_ptype2.yearweek}
\alias{vec_arith.yearweek}
\alias{obj_print_data.yearweek}
\title{vctrs compatibility functions}
\usage{
\method{vec_cast}{yearmonth}(x, to, ...)

\method{vec_ptype2}{yearmonth}(x, y, ...)

\method{vec_arith}{yearmonth}(op, x, y, ...)

\method{obj_print_data}{yearmonth}(x, ...)

\method{vec_cast}{yearquarter}(x, to, ...)

\method{vec_ptype2}{yearquarter}(x, y, ...)

\method{vec_arith}{yearquarter}(op, x, y, ...)

\method{obj_print_data}{yearquarter}(x, ...)

\method{vec_cast}{yearweek}(x, to, ...)

\method{vec_ptype2}{yearweek}(x, y, ...)

\method{vec_arith}{yearweek}(op, x, y, ...)

\method{obj_print_data}{yearweek}(x, ...)
}
\arguments{
\item{x}{Objects.}

\item{to}{Type to cast to.}

\item{...}{Used to pass along error message information.}
}
\description{
These functions are the extensions that allow tsibble objects to
work with vctrs.
}
\keyword{internal}
