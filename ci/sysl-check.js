const pantherManualDesc = require("../config/panther-manual-desc.json");

const findPantherIdsOnObject = (objectName) =>
  pantherManualDesc["pantherId"][objectName];

const allObjectFieldsWithPantherId = (objectName, allFields = []) => {
  const objectPanthers = findPantherIdsOnObject(objectName);
  for (let key in objectPanthers) {
    objectPanthers[key].forEach((e) => allFields.push(`${objectName}.${e}`));
  }
  return allFields.join(",");
};

process.argv.forEach(function (objectName) {
  console.log(allObjectFieldsWithPantherId(objectName));
});
