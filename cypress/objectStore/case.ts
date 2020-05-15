import * as faker from "faker";
import { getRecordTypeID } from "./complaint";
import { createAccountList } from "./account";
import { createFinAccountList } from "./financialAccount";
import { any } from "bluebird";

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
  // Check if there are existing person accounts, if not create new ones
  var accOwnerId: String = "";
  /*
  connection.query(
    "SELECT Id FROM Account WHERE RecordType.DeveloperName = 'PersondAccount' LIMIT 1",
    async function(err: any, result: any) {
      if (err) {
        return console.error(err);
      }

      if (result.records.length > 0) {
        accOwnerId = result.records[0].Id;
      } else {
        // insert an account and use the retrieved id
        var accountList: any = await createAccountList(connection, 1);
        accOwnerId = accountList[0].Id;
      }
    }
  );
  */
  // Check if there are existing financial accounts, if not create new ones
  var finAccOwnerId: String = "";
  connection.query(
    "SELECT Id, FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c WHERE RecordType.DeveloperName = 'SavingshAccount' LIMIT 1",
    async function(err: any, result: any) {
      if (err) {
        return console.error(err);
      }
      if (result.records.length > 0) {
        finAccOwnerId = result.records[0].Id;
        accOwnerId = result.records[0].FinServ__PrimaryOwner__c;
      } else {
        // insert an account and use the retrieved id
        console.log(
          await createFinAccountList(connection, 1, "SavingsAccount")
        );
        //finAccOwnerId = accountList[0].Id;
        //accOwnerId = accountList[0].FinServ__PrimaryOwner__c;
      }
    }
  );
  return new Promise(async resolve => {
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
        AccountId: accOwnerId,
        FinServ__FinancialAccount__c: finAccOwnerId
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
