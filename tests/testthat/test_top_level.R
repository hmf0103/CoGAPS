context("CoGAPS")

no_na_in_result <- function(gapsResult)
{
    sum(is.na(gapsResult@featureLoadings)) +
        sum(is.na(gapsResult@loadingStdDev)) +
        sum(is.na(gapsResult@sampleFactors)) +
        sum(is.na(gapsResult@factorStdDev)) == 0
}

test_that("Valid Top-Level CoGAPS Calls",
{
    data(GIST)
    testDataFrame <- GIST.data_frame
    testMatrix <- GIST.matrix

    gistCsvPath <- system.file("extdata/GIST.csv", package="CoGAPS")
    gistTsvPath <- system.file("extdata/GIST.tsv", package="CoGAPS")
    gistMtxPath <- system.file("extdata/GIST.mtx", package="CoGAPS")
    gistGctPath <- system.file("extdata/GIST.gct", package="CoGAPS")

    # data types
    res <- list()
    res[[1]] <- CoGAPS(testDataFrame, nIterations=100, outputFrequency=50, seed=1, messages=FALSE)
    res[[2]] <- CoGAPS(testMatrix, nIterations=100, outputFrequency=50, seed=1, messages=FALSE)
    res[[3]] <- CoGAPS(gistCsvPath, nIterations=100, outputFrequency=50, seed=1, messages=FALSE)
    res[[4]] <- CoGAPS(gistTsvPath, nIterations=100, outputFrequency=50, seed=1, messages=FALSE)
    res[[5]] <- CoGAPS(gistMtxPath, nIterations=100, outputFrequency=50, seed=1, messages=FALSE)
    res[[6]] <- CoGAPS(gistGctPath, nIterations=100, outputFrequency=50, seed=1, messages=FALSE)
    expect_true(all(sapply(res, no_na_in_result)))
    
    expect_equal(nrow(res[[1]]@featureLoadings), 1363)
    expect_equal(ncol(res[[1]]@featureLoadings), 7)
    expect_equal(nrow(res[[1]]@sampleFactors), 9)
    expect_equal(ncol(res[[1]]@sampleFactors), 7)
#    expect_true(all(sapply(1:5, function(i)
#        res[[i]]@featureLoadings == res[[i+1]]@featureLoadings)))
#    expect_true(all(sapply(1:5, function(i)
#        res[[i]]@sampleFactors == res[[i+1]]@sampleFactors)))

    # transposing data
    res <- list()
    res[[1]] <- CoGAPS(testDataFrame, transposeData=TRUE, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE)
    res[[2]] <- CoGAPS(testMatrix, transposeData=TRUE, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE)
    res[[3]] <- CoGAPS(gistCsvPath, transposeData=TRUE, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE)
    res[[4]] <- CoGAPS(gistTsvPath, transposeData=TRUE, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE)
    res[[5]] <- CoGAPS(gistMtxPath, transposeData=TRUE, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE)
    res[[6]] <- CoGAPS(gistGctPath, transposeData=TRUE, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE)
    expect_true(all(sapply(res, no_na_in_result)))
    
    expect_equal(nrow(res[[1]]@featureLoadings), 9)
    expect_equal(ncol(res[[1]]@featureLoadings), 7)
    expect_equal(nrow(res[[1]]@sampleFactors), 1363)
    expect_equal(ncol(res[[1]]@sampleFactors), 7)
#    expect_true(all(sapply(1:5, function(i)
#        res[[i]]@featureLoadings == res[[i+1]]@featureLoadings)))
#    expect_true(all(sapply(1:5, function(i)
#        res[[i]]@sampleFactors == res[[i+1]]@sampleFactors)))

    # passing uncertainty
    expect_error(res <- CoGAPS(testDataFrame, uncertainty=as.matrix(GIST.uncertainty),
        nIterations=100, outputFrequency=50, seed=1, messages=FALSE), NA)    
    expect_true(no_na_in_result(res))

    # multiple threads
    expect_error(res <- CoGAPS(testDataFrame, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE, nThreads=2), NA)
    expect_true(no_na_in_result(res))

    expect_error(res <- CoGAPS(testDataFrame, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE, nThreads=6), NA)
    expect_true(no_na_in_result(res))

    expect_error(res <- CoGAPS(testDataFrame, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE, nThreads=12), NA)
    expect_true(no_na_in_result(res))

    # genome-wide CoGAPS 
    expect_error(res <- CoGAPS(gistTsvPath, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE, distributed="genome-wide"), NA)
    expect_true(no_na_in_result(res))

    expect_equal(nrow(res@featureLoadings), 1363)
    expect_equal(nrow(res@sampleFactors), 9)
    #expect_equal(rownames(res@featureLoadings), rownames(GIST.matrix))
    expect_equal(rownames(res@sampleFactors), colnames(GIST.matrix))

    expect_error(res <- CoGAPS(gistTsvPath, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE, distributed="genome-wide"), NA)
    expect_true(no_na_in_result(res))

    expect_equal(nrow(res@featureLoadings), 1363)
    expect_equal(nrow(res@sampleFactors), 9)

    # single-cell CoGAPS
    expect_error(res <- CoGAPS(gistCsvPath, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE, distributed="single-cell",
        transposeData=TRUE), NA)
    expect_true(no_na_in_result(res))

    expect_equal(nrow(res@featureLoadings), 9)
    expect_equal(nrow(res@sampleFactors), 1363)
    expect_equal(rownames(res@featureLoadings), colnames(GIST.matrix))
#    expect_equal(rownames(res@sampleFactors), rownames(GIST.matrix))

    expect_error(res <- CoGAPS(gistMtxPath, nIterations=100,
        outputFrequency=50, seed=1, messages=FALSE, distributed="single-cell",
        transposeData=TRUE), NA)
    expect_true(no_na_in_result(res))

    expect_equal(nrow(res@featureLoadings), 9)
    expect_equal(nrow(res@sampleFactors), 1363)

    # test running with fixed matrix
    nPat <- 3
    fixedA <- matrix(runif(nrow(testMatrix) * nPat, 1, 10), ncol=nPat)
    fixedP <- matrix(runif(ncol(testMatrix) * nPat, 1, 10), ncol=nPat)
    params <- CogapsParams()
    params <- setFixedPatterns(params, fixedA, "A")
    res <- CoGAPS(testMatrix, params, nIterations=100, outputFrequency=100,
        seed=42, messages=FALSE, nPatterns=nPat)
    
    expect_true(all(dim(res@featureLoadings) == dim(fixedA)))
    for (i in 1:ncol(fixedA))
        fixedA[,i] <- fixedA[,i] * (res@featureLoadings[1,i] / fixedA[1,i])
    all.equal(unname(res@featureLoadings), fixedA, tolerance=0.001)

    params <- CogapsParams()
    params <- setFixedPatterns(params, fixedP, "P")
    res <- CoGAPS(gistCsvPath, params, nIterations=100, outputFrequency=100, seed=42,
        messages=FALSE, nPatterns=nPat)

    expect_true(all(dim(res@sampleFactors) == dim(fixedP)))
    for (i in 1:ncol(fixedP))
        fixedP[,i] <- fixedP[,i] * (res@sampleFactors[1,i] / fixedP[1,i])
    all.equal(unname(res@sampleFactors), fixedP, tolerance=0.001)

    # make sure that "none" gets converted to NULL for distributed
    res <- CoGAPS(gistCsvPath, nIterations=100, outputFrequency=100, seed=42,
        messages=FALSE, nPatterns=3, distributed="none")
    expect_true(is.null(res@metadata$params@distributed))    

    params <- CogapsParams()
    params <- setParam(params, "distributed", "none")
    res <- CoGAPS(gistCsvPath, params, nIterations=100, outputFrequency=100, seed=42,
        messages=FALSE, nPatterns=3)
    expect_true(is.null(res@metadata$params@distributed))

    # test using RDS file for parameters
    matP <- getSampleFactors(GIST.result)
    params <- CogapsParams(nPatterns=ncol(matP), nIterations=175, seed=42,
        sparseOptimization=TRUE, distributed="genome-wide",
        explicitSets=list(1:200, 201:400, 401:600, 601:800, 801:1000))
    params <- setDistributedParams(params, nSets=5, cut=ncol(matP) + 1)
    params <- setFixedPatterns(params, matP, "P")
    saveRDS(params, file="temp_params.rds")

    res1 <- CoGAPS(gistMtxPath, params)
    res2 <- CoGAPS(gistMtxPath, "temp_params.rds")
    file.remove("temp_params.rds")
    
    expect_true(all(res1@featureLoadings == res2@featureLoadings))
    expect_true(all(res1@loadingStdDev == res2@loadingStdDev))
    expect_true(all(res1@sampleFactors == res2@sampleFactors))
    expect_true(all(res1@factorStdDev== res2@factorStdDev))
})

