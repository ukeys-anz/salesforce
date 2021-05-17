import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { getRecordTypeID, getUserByAlias } from "./util";
import IFinAccount, { getFinAccount } from "./financialAccount";
import CustomError from "../utilities/customErrorHandler";

interface ICase {
  Description: string;
  Status: string;
  Type: string;
  Sub_Type__c: string;
  Additional_Type__c: string;
  Origin: string;
  Priority: string;
  RecordTypeId: string;
  AccountId: string;
  FinServ__FinancialAccount__c: string;
  ParentId: string;
  OwnerId?: string;
  Id?: string;
}

/**
 * @description Creates a new case records depending on the amount passed and record type.
 * creates General_Inquiry record type cases
 * @param amount  Number of cases to be created
 * @param recordType Record Type of the case
 */
export function createCaseList(
  amount = 1,
  recordType = "General_Inquiry",
  alias: string
): any {
  return new Promise(async (resolve) => {
    const finAccountList: IFinAccount[] = await getFinAccount();
    const recordTypeId: string = await getRecordTypeID("Case", recordType);
    const parentCaseList: any = await getParentCase(
      recordTypeId,
      finAccountList[0].FinServ__PrimaryOwner__c
    );
    const cases: ICase[] = [];
    const idList: string[] = [];
    const user: any = await getUserByAlias(alias);

    for (let i = 0; i < amount; i++) {
      const caseRecord: ICase = {
        Description: faker.lorem.text(),
        Status: faker.random.arrayElement([
          "Open",
          "Under Investigation",
          "On Hold",
          "Escalated"
        ]),
        Type: "App Support",
        Sub_Type__c: "App Guide;Device Support",
        Additional_Type__c: faker.random.arrayElement([
          "Bug Report & Feature",
          "Card",
          "Coaching",
          "Customer Feedback (NPS)",
          "Customer Update & Details",
          "Dispute",
          "Join / KYC",
          "My Security",
          "Product Information",
          "Transaction & Savings enquiry"
        ]),
        Origin: faker.random.arrayElement([
          "Chat",
          "Voice Call",
          "Video Call",
          "Appointment",
          "Store"
        ]),
        Priority: faker.random.arrayElement([
          "Critical",
          "High",
          "Medium",
          "Low"
        ]),
        RecordTypeId: recordTypeId,
        AccountId: finAccountList[0].FinServ__PrimaryOwner__c,
        FinServ__FinancialAccount__c: finAccountList[0].Id!,
        ParentId: parentCaseList[0].Id,
        OwnerId: user.Id
      };
      cases.push(caseRecord);
    }

    //Include headers so we can assign the user as owner of case
    jsForce.sobject("Case").create(
      cases,
      {
        headers: {
          "SForce-Auto-Assign": false
        }
      },
      (err: any, result: any) => {
        if (err) {
          throw new CustomError("Failed to create Case record", err);
        } else if (!result[0].success) {
          throw new CustomError(
            "Failed to create new Case record",
            result[0].errors[0].message
          );
        }

        //Loop through the result to create a list of ids
        result.forEach((item: any) => {
          idList.push(item.id);
        });

        //Retrieve the new cases using the created id list and return the results
        jsForce.sobject("Case").retrieve(idList, (err: any, result: any) => {
          if (err) {
            throw new CustomError("Failed to retrieve Case record", err);
          }
          resolve(result);
        });
      }
    );
  });
}

/**
 * @description extracts parent case record if is already in the system or creates new one.
 * @param recordTypeId case general inquiry record type id
 * @param accountId Account id from previous func
 */
export async function getParentCase(
  recordTypeId: string,
  accountId: string
): Promise<any> {
  if (!recordTypeId || !accountId) {
    throw new CustomError("Record Type ID or Account ID is null");
  }
  // Check if there are existing parent case, if not create new ones
  return new Promise<string>((resolve) => {
    jsForce.query(
      `SELECT Id, CaseNumber FROM Case WHERE RecordTypeId = '${recordTypeId}' and ParentId = null LIMIT 1`,
      async function (err: any, result: any) {
        if (err) {
          throw new CustomError("Failed to query case", err);
        }
        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          const cases: ICase[] = [];
          const idList: string[] = [];
          const caseRecord: ICase = {
            Description: faker.lorem.text(),
            Status: faker.random.arrayElement([
              "Open",
              "Under Investigation",
              "On Hold",
              "Escalated",
              "Closed"
            ]),
            Type: "App Support",
            Sub_Type__c: "App Guide;Device Support",
            Additional_Type__c: faker.random.arrayElement([
              "Bug Report & Feature",
              "Card",
              "Coaching",
              "Customer Feedback (NPS)",
              "Customer Update & Details",
              "Dispute",
              "Join / KYC",
              "My Security",
              "Product Information",
              "Transaction & Savings enquiry "
            ]),
            Origin: faker.random.arrayElement([
              "Chat",
              "Voice Call",
              "Video Call",
              "Appointment",
              "Store"
            ]),
            Priority: faker.random.arrayElement([
              "Critical",
              "High",
              "Medium",
              "Low"
            ]),
            RecordTypeId: recordTypeId,
            AccountId: accountId,
            FinServ__FinancialAccount__c: "",
            ParentId: ""
          };
          cases.push(caseRecord);

          //Include headers so we can assign the user as owner of case
          jsForce.sobject("Case").create(
            cases,
            {
              headers: {
                "SForce-Auto-Assign": false
              }
            },
            (err: any, result: any) => {
              if (err) {
                throw new CustomError("Failed to create Case record", err);
              } else if (!result[0].success) {
                throw new CustomError(
                  "Failed to create new Case record",
                  result[0].errors[0].message
                );
              }
              //Loop through the result to create a list of ids
              result.forEach((item: ICase) => {
                idList.push(item.Id!);
              });
              //Retrieve the new cases using the created id list and return the results
              jsForce
                .sobject("Case")
                .retrieve(idList, (err: any, result: any) => {
                  if (err) {
                    throw new CustomError("Failed to retrieve case", err);
                  }
                  resolve(result);
                });
            }
          );
        }
      }
    );
  });
}

/**
 * @description Creates a blank general inquiry case. This will be used to test edit case functionality.
 * @param amount  Number of cases to be created
 * @param recordType Record Type of the case
 */
export async function createBlankCase(
  amount = 1,
  recordType: string,
  alias: string
): Promise<any> {
  return new Promise(async (resolve) => {
    const recordTypeId: string = await getRecordTypeID("Case", recordType);
    const user: any = await getUserByAlias(alias);
    const cases: any = [];
    const idList: string[] = [];

    for (let i = 0; i < amount; i++) {
      const caseRecord = {
        RecordTypeId: recordTypeId,
        OwnerId: user.Id
      };
      cases.push(caseRecord);
    }

    //Include headers so we can assign the user as owner of case
    jsForce.sobject("Case").insert(
      cases,
      {
        headers: {
          "SForce-Auto-Assign": false
        }
      },
      (err: any, result: any) => {
        if (err) {
          throw new CustomError("Failed to insert Case record", err);
        } else if (!result[0].success) {
          throw new CustomError(
            "Failed to insert new Case record",
            result[0].errors[0].message
          );
        }

        //Loop through the result to create a list of ids
        result.forEach((item: any) => {
          idList.push(item.id);
        });

        //Retrieve the new cases using the created id list and return the results
        jsForce.sobject("Case").retrieve(idList, (err: any, result: any) => {
          if (err) {
            throw new CustomError("Failed to retrieve case record", err);
          }
          resolve(result);
        });
      }
    );
  });
}
