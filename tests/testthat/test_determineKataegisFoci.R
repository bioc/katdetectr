testthat::test_that("test .determineKataegisFoci(IMDcutoff = fun())", {
    # test on larger breast cancer sample
    genomicVariantsAnnotatedCPTAC <- system.file("extdata", "CPTAC_Breast.vcf", package = "katdetectr") |>
        .importGenomicVariants(refSeq = "hg19") |>
        .processGenomicVariants() |>
        .annotateGenomicVariants()
    changepointsCPTAC <- .performChangepointDetection(genomicVariantsAnnotated = genomicVariantsAnnotatedCPTAC, refSeq = "hg19", test.stat = "Exponential", penalty = "BIC", pen.value = 0, method = "PELT", minseglen = 2, BPPARAM = BiocParallel::SerialParam())
    segmentsCPTAC <- .annotateSegments(changepoints = changepointsCPTAC, genomicVariantsAnnotated = genomicVariantsAnnotatedCPTAC, refSeq = "hg19")

    modelSampleRate <- function(IMDs) {
        lambda <- log(2) / median(IMDs)

        return(lambda)
    }


    nthroot <- function(x, n) {
        y <- x^(1 / n)

        return(y)
    }


    IMDcutoffFun <- function(genomicVariantsAnnotated, segments) {
        IMDs <- genomicVariantsAnnotated$IMD
        totalVariants <- segments$totalVariants
        width <- segments |>
            dplyr::as_tibble() |>
            dplyr::pull(width)

        sampleRate <- modelSampleRate(IMDs)

        IMDthreshold <- -log(1 - nthroot(0.01 / width, ifelse(totalVariants != 0, totalVariants - 1, 1))) / sampleRate

        IMDthreshold <- replace(IMDthreshold, IMDthreshold > 1000, 1000)

        return(IMDthreshold)
    }

    IMDcutoffValues <- .determineIMDcutoffValues(IMDcutoffFun, genomicVariantsAnnotatedCPTAC, segmentsCPTAC)
    segmentsCPTAC <- .addIMDcutoffValuesToSegments(segmentsCPTAC, IMDcutoffValues)
    kataegisFociCPTAC <- .determineKataegisFoci(segmentsCPTAC, genomicVariantsAnnotatedCPTAC, minSizeKataegis = 5, IMDcutoff = IMDcutoffValues)

    testthat::expect_equal(base::length(kataegisFociCPTAC), 14)
    testthat::expect_equal(kataegisFociCPTAC$fociID[1], 1)
    testthat::expect_equal(kataegisFociCPTAC$sampleNames[1], "CPTAC")
    testthat::expect_equal(kataegisFociCPTAC$totalVariants[1], 5)
    testthat::expect_equal(kataegisFociCPTAC$firstVariantID[1], 363)
    testthat::expect_equal(kataegisFociCPTAC$lastVariantID[1], 367)
    testthat::expect_equal(round(kataegisFociCPTAC$meanIMD[1]), 247)
    testthat::expect_equal(round(kataegisFociCPTAC$IMDcutoff[1]), 1000)
})

testthat::test_that("test .determineKataegisFoci(IMDcutoff = 1000)", {
    # test on larger breast cancer sample
    genomicVariantsAnnotatedCPTAC <- system.file("extdata", "CPTAC_Breast.vcf", package = "katdetectr") |>
        .importGenomicVariants(refSeq = "hg19") |>
        .processGenomicVariants() |>
        .annotateGenomicVariants()
    changepointsCPTAC <- .performChangepointDetection(genomicVariantsAnnotated = genomicVariantsAnnotatedCPTAC, refSeq = "hg19", test.stat = "Exponential", penalty = "BIC", pen.value = 0, method = "PELT", minseglen = 2, BPPARAM = BiocParallel::SerialParam())
    segmentsCPTAC <- .annotateSegments(changepoints = changepointsCPTAC, genomicVariantsAnnotated = genomicVariantsAnnotatedCPTAC, refSeq = "hg19")
    IMDcutoffValues <- .determineIMDcutoffValues(1000, genomicVariantsAnnotatedCPTAC, segmentsCPTAC)
    segmentsCPTAC <- .addIMDcutoffValuesToSegments(segmentsCPTAC, IMDcutoffValues)
    kataegisFociCPTAC <- .determineKataegisFoci(segmentsCPTAC, genomicVariantsAnnotatedCPTAC, minSizeKataegis = 5, IMDcutoff = IMDcutoffValues)

    testthat::expect_equal(base::length(kataegisFociCPTAC), 14)
    testthat::expect_equal(kataegisFociCPTAC$fociID[1], 1)
    testthat::expect_equal(kataegisFociCPTAC$sampleNames[1], "CPTAC")
    testthat::expect_equal(kataegisFociCPTAC$totalVariants[1], 5)
    testthat::expect_equal(kataegisFociCPTAC$firstVariantID[1], 363)
    testthat::expect_equal(kataegisFociCPTAC$lastVariantID[1], 367)
    testthat::expect_equal(round(kataegisFociCPTAC$meanIMD[1]), 247)
    testthat::expect_equal(round(kataegisFociCPTAC$IMDcutoff[1]), 1000)
})

testthat::test_that("test .annotateKataegisSegments()", {
    testVariants <- GenomicRanges::GRanges(
        seqnames = c(base::rep("chr1", 539), base::rep("chrX", 113)),
        ranges = IRanges::IRanges(start = 1:652, end = 1:652),
        variantID = 1:652
    )

    testSegments <- GenomicRanges::GRanges(
        seqnames = c("chr1", "chr1", "chr1", "chr1", "chr1", "chrX"),
        ranges = IRanges::IRanges(
            start = c(11, 20, 30, 40, 50, 1000),
            end = c(11, 20, 30, 40, 50, 1000)
        ),
        segmentID = c(1, 2, 3, 4, 5, 6),
        meanIMD = c(1001, 1000, 10, 5000, 60000, 5),
        totalVariants = c(11, 15, 500, 2, 11, 113),
        sampleNames = base::rep("testSample", 6),
        firstVariantID = c(1, 12, 27, 527, 529, 540),
        lastVariantID = c(11, 26, 526, 528, 539, 652)
    )

    katSegs <- .determineKataegisSegments(segments = testSegments, IMDcutoff = 1000)
    katSegsMerged <- .mergeKataegisSegments(kataegisSegments = katSegs, minSizeKataegis = 4)
    katSegsAnno <- .annotateKataegisSegments(kataegisFoci = katSegsMerged, genomicVariantsAnnotated = testVariants)

    testthat::expect_equal(base::length(katSegsAnno), 2)
    testthat::expect_equal(katSegsAnno$fociID, c(1, 2))
    testthat::expect_equal(base::as.character(GenomicRanges::seqnames(katSegsAnno)), c("chr1", "chrX"))
    testthat::expect_equal(katSegsAnno$sampleNames, c("testSample", "testSample"))
    testthat::expect_equal(katSegsAnno$totalVariants, c(516, 113))
    testthat::expect_equal(katSegsAnno$firstVariantID, c(11, 540))
    testthat::expect_equal(katSegsAnno$lastVariantID, c(526, 652))
    testthat::expect_equal(katSegsAnno$meanIMD, c(505, 5))
})

testthat::test_that("test .mergeKataegisSegments()", {
    testSegments <- GenomicRanges::GRanges(
        seqnames = c("chr1", "chr1", "chr1", "chr1", "chr1", "chrX"),
        ranges = IRanges::IRanges(
            start = c(1, 2, 3, 4, 5, 1),
            end = c(1, 2, 3, 4, 5, 1)
        ),
        segmentID = c(1, 2, 3, 4, 5, 6),
        meanIMD = c(1001, 1000, 10, 5000, 60000, 5),
        totalVariants = c(11, 15, 500, 2, 11, 113),
        sampleNames = c("testSample", "testSample", "testSample", "testSample", "testSample", "testSample"),
        firstVariantID = c(1, 12, 27, 527, 529, 538),
        lastVariantID = c(11, 26, 526, 528, 539, 650)
    )

    katSegs <- .determineKataegisSegments(segments = testSegments, IMDcutoff = 1000)
    katSegsMerged <- .mergeKataegisSegments(kataegisSegments = katSegs, minSizeKataegis = 4)

    testthat::expect_equal(base::nrow(katSegsMerged), 2)
    testthat::expect_equal(katSegsMerged$start, c(2, 1))
    testthat::expect_equal(katSegsMerged$end, c(3, 1))
    testthat::expect_equal(katSegsMerged$meanIMD, c(505, 5))
    testthat::expect_equal(katSegsMerged$firstVariantID, c(12, 538))
    testthat::expect_equal(katSegsMerged$lastVariantID, c(526, 650))
})

testthat::test_that("test .determineKataegisSegments()", {
    testSegments <- GenomicRanges::GRanges(
        seqnames = c("chr1", "chr1", "chr1", "chr1", "chr1", "chrX"),
        ranges = IRanges::IRanges(
            start = c(1, 2, 3, 4, 5, 1),
            end = c(1, 2, 3, 4, 5, 1)
        ),
        segmentID = c(1, 2, 3, 4, 5, 6),
        meanIMD = c(1001, 1000, 10, 5000, 60000, 5),
        totalVariants = c(3, 9, 15, 500, 2, 9),
        sampleNames = c("testSample", "testSample", "testSample", "testSample", "testSample", "testSample")
    )

    katSegs <- .determineKataegisSegments(segments = testSegments, IMDcutoff = 1000)

    testthat::expect_equal(base::nrow(katSegs), 3)
    testthat::expect_equal(katSegs$meanIMD[1], 1000)
    testthat::expect_equal(katSegs$meanIMD[2], 10)
})

testthat::test_that("test .determinefociID()", {
    testFociID1 <- .determinefociID(c(1, 2, 4, 5, 6, 10))
    testFociID2 <- .determinefociID(c(1, 10))

    testthat::expect_equal(testFociID1, c(1, 1, 2, 2, 2, 3))
    testthat::expect_equal(testFociID2, c(1, 2))
})
