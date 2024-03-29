% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/function_generateSyntheticData.R
\name{generateSyntheticData}
\alias{generateSyntheticData}
\title{Generate genomic variants with pre-defined kataegis foci.}
\usage{
generateSyntheticData(
  genome = BSgenome.Hsapiens.UCSC.hg19::BSgenome.Hsapiens.UCSC.hg19,
  nBackgroundVariants = 100,
  seqnames = NULL,
  probMutationType = c(0.8, 0.1, 0.1),
  nKataegisFoci = 5,
  nKataegisVariants = 20,
  expectedIMD = 100,
  sampleName = "syntheticData",
  removeValidationColumns = TRUE
)
}
\arguments{
\item{genome}{(\link[BSgenome]{BSgenome}): The genome (DNA) which will be sampled for genomic variants.}

\item{nBackgroundVariants}{(integer): The no. of generated background genomic variants.}

\item{seqnames}{(character): The sequences on which genomic variants will be sampled. If NULL, then all human autosomes and sex chromosomes will be used.}

\item{probMutationType}{(numeric): The probability of a generated variant being an SNV, MNV, Deletion or Insertion, respectively.}

\item{nKataegisFoci}{(integer): The no. of generated and interjected kataegis foci.}

\item{nKataegisVariants}{(integer): The no. of genomic variants within each kataegis foci.}

\item{expectedIMD}{(integer): The expected mean intermutational distance (IMD) of the generated kataegis foci.}

\item{sampleName}{(character): The name of the sample}

\item{removeValidationColumns}{(logical): Include columns with extra information regarding mutation sampling?}
}
\value{
(\link[VariantAnnotation]{VRanges}): VRanges containing background genomic variants and pre-defined kataegis foci.
}
\description{
This function generates a synthetic dataset (VRanges) containing background genomic variants
and a no. of desired interjected kataegis foci.
}
\examples{
syntheticData1 <- generateSyntheticData()

syntheticData2 <- generateSyntheticData(
    genome = BSgenome.Hsapiens.UCSC.hg38::BSgenome.Hsapiens.UCSC.hg38,
    nBackgroundVariants = 75,
    seqnames = c("chr1", "chrX"),
    nKataegisFoci = 1,
    nKataegisVariants = 25,
    sampleName = "testSample",
    removeValidationColumns = FALSE
)

}
\author{
Daan Hazelaar

Job van Riet
}
