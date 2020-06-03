import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { getRecordTypeID } from "./util";
import { getFinAccount } from "./financialAccount";

interface ICase {
  Description: String;
  Status: String;
  Type: String;
  Sub_Type__c: String;
  Additional_Type__c: String;
  Origin: String;
  Priority: String;
  RecordTypeId: String;
  AccountId: String;
  FinServ__FinancialAccount__c: String;
  ParentId: String;
}

/**
 * @description Creates a new case records depending on the amount passed and record type.
 * creates General_Inquiry record type cases
 * @param amount  Number of cases to be created
 * @param recordType Record Type of the case
 */
export function createCaseList(
  amount: number = 1,
  recordType: String = "General_Inquiry"
) {
  return new Promise(async resolve => {
    var finAccountList: any = await getFinAccount();
    var recordTypeId: String = await getRecordTypeID("Case", recordType);
    var parentCaseList: any = await getParentCase(
      recordTypeId,
      finAccountList[0].FinServ__PrimaryOwner__c
    );
    var cases: ICase[] = [];
    var idList: any = [];

    for (var i = 0; i < amount; i++) {
      let caseRecord: ICase = {
        Description: faker.lorem.text(),
        Status: faker.random.arrayElement([
          "Open",
          "Under Investigation",
          "On Hold",
          "Escalated",
          "Re-opened"
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
        FinServ__FinancialAccount__c: finAccountList[0].Id,
        ParentId: parentCaseList[0].Id
      };
      cases.push(caseRecord);
    }

    jsForce.sobject("Case").create(cases, (err: any, result: any) => {
      if (err) {
        return console.log("error", err);
      } else if (!result[0].success) {
        return console.log("error", result[0].errors[0].message);
      }
      //Loop through the result to create a list of ids
      result.forEach((item: any, index: any) => {
        idList.push(item.id);
      });
      //Retrieve the new cases using the created id list and return the results
      jsForce.sobject("Case").retrieve(idList, (err: any, result: any) => {
        if (err) {
          return console.log("error", err);
        }
        resolve(result);
      });
    });
  });
}

/**
 * @description extracts parent case record if is already in the system or creates new one.
 * @param recordTypeId case general inquiry record type id
 * @param accountId Account id from previous func
 */
export async function getParentCase(recordTypeId: any, accountId: any) {
  if (!recordTypeId || !accountId) {
    console.error("Record Type ID or Account ID is null");
    return null;
  }
  // Check if there are existing parent case, if not create new ones
  return new Promise<String>(resolve => {
    jsForce.query(
      `SELECT Id, CaseNumber FROM Case WHERE RecordTypeId = '${recordTypeId}' and ParentId = null LIMIT 1`,
      async function(err: any, result: any) {
        if (err) {
          return console.error(err);
        }
        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          var cases: ICase[] = [];
          var idList: any = [];
          let caseRecord: ICase = {
            Description: faker.lorem.text(),
            Status: faker.random.arrayElement([
              "Open",
              "Under Investigation",
              "On Hold",
              "Escalated",
              "Closed",
              "Re-opened"
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

          jsForce.sobject("Case").create(cases, (err: any, result: any) => {
            if (err) {
              return console.log("error", err);
            } else if (!result[0].success) {
              return console.log("error", result[0].errors[0].message);
            }
            //Loop through the result to create a list of ids
            result.forEach((item: any, index: any) => {
              idList.push(item.id);
            });
            //Retrieve the new cases using the created id list and return the results
            jsForce
              .sobject("Case")
              .retrieve(idList, (err: any, result: any) => {
                if (err) {
                  return console.log("error", err);
                }
                resolve(result);
              });
          });
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
export async function createBlankCase(amount: number = 1, recordType: String) {
  return new Promise(async resolve => {
    var recordTypeId: String = await getRecordTypeID("Case", recordType);
    var cases: any = [];
    var idList: any = [];

    for (var i = 0; i < amount; i++) {
      let caseRecord = {
        RecordTypeId: recordTypeId
      };
      cases.push(caseRecord);
    }

    jsForce.sobject("Case").create(cases, (err: any, result: any) => {
      if (err) {
        return console.log("error", err);
      } else if (!result[0].success) {
        return console.log("error", result[0].errors[0].message);
      }

      //Loop through the result to create a list of ids
      result.forEach((item: any, index: any) => {
        idList.push(item.id);
      });

      //Retrieve the new cases using the created id list and return the results
      jsForce.sobject("Case").retrieve(idList, (err: any, result: any) => {
        if (err) {
          return console.log("error", err);
        }
        resolve(result);
      });
    });
  });
}
