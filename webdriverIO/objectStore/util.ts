import { jsForce } from "../utilities/jsforce";

/**
 * @description To get record type id based on sobject type and record type name
 * @param sObject Object api name
 * @param devName Record type developer name
 */
export async function getRecordTypeID(sObject: String, devName: String) {
  return new Promise<String>(resolve => {
    jsForce.query(
      `SELECT Id FROM RecordType WHERE IsActive = TRUE AND sObjectType= '${sObject}' AND DeveloperName='${devName}'`,
      (err: any, result: any) => {
        if (err) {
          return console.error("error", err);
        }
        resolve(result.records[0].Id);
      }
    );
  });
}
