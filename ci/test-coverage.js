const reportJson = require('./coverage.json');

const findCodeCoverageReport = () => reportJson["result"]["details"]["runTestResult"]["codeCoverage"]

const coveredLines = (coverageReport, sum = 0) => coverageReport.reduce( (s, v) => s + +v.numLocations, sum);

const notCoveredLines = (coverageReport, sum = 0) => coverageReport.reduce( (s, v) => s + +v.numLocationsNotCovered, sum);

const codeCoverage = () => {
    const codeCoverageReport = findCodeCoverageReport()
    const coveredLinesNum = coveredLines(codeCoverageReport)
    const notCoveredLinesNum = notCoveredLines(codeCoverageReport)
    const draftPR = coveredLinesNum == 0 && notCoveredLinesNum == 0;
    return draftPR ? 'DraftPR: No Test' : ((1 - notCoveredLinesNum/(coveredLinesNum+notCoveredLinesNum)) * 100).toFixed(2);
}

process.argv.forEach(function () {
    console.log(codeCoverage());
});

