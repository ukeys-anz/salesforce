import { findAllFiles,readFileLines } from "../workflows/Services/helper.mjs";

// This method will find all the @SuppressWarnings on classess and will give us an array as -
// a result for each class
const findSurpressedPMDRules = (
    classLines,
    specifidTestSymbol = "@SuppressWarnings"
) => {
    let res = [];
    for (let ind = 0; ind < classLines.length; ind++) {
        const line = classLines[ind];
        if (line.indexOf(specifidTestSymbol) > -1) {
            const surpressedLine = line.split(specifidTestSymbol)[1].replace("('", "").replace("')", "").replaceAll(" ", "");
            const surpressedOnNextLine = classLines[ind+1].replaceAll(" ", "").replaceAll("'", "")
            const pmdRuleSurpressed = surpressedLine === '(' ? surpressedOnNextLine : surpressedLine

            const surpressedRules = pmdRuleSurpressed.split(",")
            surpressedRules.forEach(r => {
                if (!res.includes(r)) res.push(r)
            })
        }
    }
    return res;
};

// this will find all the classes, will loop through each line, will find all the @SuppressWarnings
const findSurpressedClasses = (classPath = 'force-app/main/default/classes') => {
    const result = {}
    const classFiles = findAllFiles(classPath);

    classFiles.forEach(f => {
        const lines = readFileLines(f);
        const findSurpress = findSurpressedPMDRules(lines, "@SuppressWarnings")
        if (findSurpress.length) result[f] = findSurpress;
    })

    return result;
}

console.log(findSurpressedClasses())

// You should run this command to have the result: node ci/js-scripts/surpressed-classes.mjs > surpressedReport.json
// this will echo the result to surpressedReport.json file