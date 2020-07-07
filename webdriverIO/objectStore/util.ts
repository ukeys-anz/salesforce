import { jsForce } from "../utilities/jsforce";
import CustomError from "../utilities/customErrorHandler";

/**
 * @description To get record type id based on sobject type and record type name
 * @param sObject Object api name
 * @param devName Record type developer name
 */
export async function getRecordTypeID(sObject: string, devName: string) {
  return new Promise<string>((resolve) => {
    jsForce.query(
      `SELECT Id FROM RecordType WHERE IsActive = TRUE AND sObjectType= '${sObject}' AND DeveloperName='${devName}'`,
      (err: any, result: any) => {
        if (err) {
          throw new CustomError("Failed to retrieve Record Type ID", err);
        }
        resolve(result.records[0].Id);
      }
    );
  });
}

export async function getUserByAlias(alias: string) {
  return new Promise<any>((resolve) => {
    jsForce.query(
      `SELECT Id, Name FROM User WHERE Alias = '${alias}' AND IsActive = true LIMIT 1`,
      (err: any, result: any) => {
        if (err) {
          throw new CustomError("Failed to retrieve User by alias", err);
        }
        resolve(result.records[0]);
      }
    );
  });
}
