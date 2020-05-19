import * as faker from "faker";
import { getRecordTypeID } from "./complaint";
import { createFinAccountList } from "./financialAccount";

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
}

/**
 * @description Creates a new case records depending on the amount passed and record type.
 * creates General_Inquiry record type cases
 * @param connection  JSForce connection
 * @param amount  Number of cases to be created
 * @param recordType Record Type of the case
 */
export function createCaseList(
  connection: any,
  amount: number = 1,
  recordType: String = "General_Inquiry"
) {
  return new Promise(async resolve => {
    var finAccountList: any = await getFinAccount(connection);
    var cases: ICase[] = [];

    var idList: any = [];
    for (var i = 0; i < amount; i++) {
      let caseRecord: ICase = {
        Description: faker.lorem.text(),
        Status: "New",
        Type: "Other Enquiries",
        Sub_Type__c: "",
        Additional_Type__c: "Card;Coaching",
        Origin: "Phone",
        Priority: "Medium",
        RecordTypeId: await getRecordTypeID(connection, recordType),
        AccountId: finAccountList[0].FinServ__PrimaryOwner__c,
        FinServ__FinancialAccount__c: finAccountList[0].Id
      };
      cases.push(caseRecord);
    }

    //Use the connection passed as a param to create the accounts
    connection.sobject("Case").create(cases, (err: any, result: any) => {
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
      connection.sobject("Case").retrieve(idList, (err: any, result: any) => {
        if (err) {
          return console.log("error", err);
        }
        resolve(result);
      });
    });
  });
}

async function getFinAccount(connection: any) {
  // Check if there are existing person accounts, if not create new ones
  return new Promise<String>(resolve => {
    connection.query(
      "SELECT Id, FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c WHERE RecordType.DeveloperName = 'SavingsAccount' LIMIT 1",
      async function(err: any, result: any) {
        if (err) {
          return console.error(err);
        }
        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          var finAccountList: any = await createFinAccountList(
            connection,
            1,
            "SavingsAccount"
          );
          resolve(finAccountList);
        }
      }
    );
  });
}
