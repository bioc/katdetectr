% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/function_constructKatdetect.R
\name{constructKatdetect}
\alias{constructKatdetect}
\title{constructKatdetect}
\usage{
constructKatdetect(
  genomicVariants = VariantAnnotation::VRanges(),
  segments = GenomicRanges::GRanges(),
  kataegisFoci = GenomicRanges::GRanges(),
  info = list()
)
}
\arguments{
\item{genomicVariants}{(\link[VariantAnnotation]{VRanges})}

\item{segments}{(\link[GenomicRanges]{GRanges})}

\item{kataegisFoci}{(\link[GenomicRanges]{GRanges})}

\item{info}{(list)}
}
\value{
(KatDetect): Returns a KatDetect object.
}
\description{
Constructor function for a KatDetect object.
}
\examples{
constructKatdetect()

}
\author{
Daan Hazelaar
}
