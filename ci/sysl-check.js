const pantherManualDesc = require("../config/panther-manual-desc.json");

const findInfoOnObject = (objectName, info) =>
  pantherManualDesc[info][objectName];

const allObjectInfo = (objectName, info, allFields = []) => {
  const obj = findInfoOnObject(objectName, info);
  for (let key in obj) {
    info === "pantherId"
      ? obj[key].forEach((e) => allFields.push(`${objectName}.${e}`))
      : allFields.push(`${objectName}.${key}`);
  }
  return allFields.join(",");
};

const args = process.argv;
console.log(allObjectInfo(args[2], args[3]));
