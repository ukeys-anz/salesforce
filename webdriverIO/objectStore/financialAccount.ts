import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { getPersonAccount } from "./account";
import { getRecordTypeID } from "./util";

interface IFinAccount {
  RecordTypeId: String;
  Name: String;
  FinServ__FinancialAccountType__c: String;
  FinServ__Status__c: String;
  FinServ__Ownership__c: String;
  FinServ__Balance__c: Number;
  FinServ__OpenDate__c: Date;
  FinServ__FinancialAccountNumber__c: String;
  // FinServ__PrimaryOwner__c: String;
}
/**
 * @description Creates new Financial Account records depending on the amount passed and record type.
 * By default creates Non_Customer_Complaint record type complaint
 * @param amount  Number of Fin. Accounts to be created
 * @param recordType Record Type of the Fin. Account
 */
export async function createFinAccountList(
  amount: number = 1,
  recordType: String = "SavingsAccount"
) {
  return new Promise<String>(async resolve => {
    let ownerId: String = "";
    let ownerName: String = "";
    let finAccounts = [];
    let idList: any = [];
    let recTypeId = await getRecordTypeID(
      "FinServ__FinancialAccount__c",
      recordType
    );
    let accountList: any = await getPersonAccount();
    for (let i = 0; i < amount; i++) {
      let finAccount: IFinAccount = {
        RecordTypeId: recTypeId,
        Name: accountList[0].Name + " Savings",
        FinServ__FinancialAccountType__c: faker.random.arrayElement([
          "Savings"
        ]),
        FinServ__Status__c: faker.random.arrayElement([
          "Open",
          "Closed",
          "On Hold",
          "Pending"
        ]),
        FinServ__Ownership__c: faker.random.arrayElement(["Individual"]),
        FinServ__Balance__c: parseFloat(faker.commerce.price(99, 9999, 2)),
        FinServ__OpenDate__c: faker.date.past(2),
        FinServ__FinancialAccountNumber__c: faker.finance.account(9),
        FinServ__PrimaryOwner__c: accountList[0].Id
      };
      finAccounts.push(finAccount);
    }

    jsForce
      .sobject("FinServ__FinancialAccount__c")
      .create(finAccounts, (err: any, result: any) => {
        if (err) {
          return console.log("error", err);
        } else if (!result[0].success) {
          return console.log("error", result[0].errors[0].message);
        }
        //Loop through the result to create a list of ids
        result.forEach((item: any) => {
          if (item.success) {
            idList.push(item.id);
          }
        });
        //Retrieve the new Financial Accounts using the created id list and return the results
        jsForce
          .sobject("FinServ__FinancialAccount__c")
          .retrieve(idList, (err: any, result: any) => {
            if (err) {
              return console.log("error", err);
            }
            resolve(result);
          });
      });
  });
}

/**
 * @description extracts financial account record if is already in the system or creates new one.
 */
export async function getFinAccount() {
  // Check if there are existing financial accounts, if not create new ones
  return new Promise<String>(resolve => {
    jsForce.query(
      "SELECT Id, Name, FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c WHERE RecordType.DeveloperName = 'SavingsAccount' LIMIT 1",
      async function(err: any, result: any) {
        if (err) {
          return console.error(err);
        }
        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          let finAccountList: any = await createFinAccountList(
            1,
            "SavingsAccount"
          );
          resolve(finAccountList);
        }
      }
    );
  });
}
