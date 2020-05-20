import * as faker from "faker";
import { createAccountList } from "./account";
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
  FinServ__PrimaryOwner__c: String;
}
/**
 * @description Creates new Financial Account records depending on the amount passed and record type.
 * By default creates Non_Customer_Complaint record type complaint
 * @param connection  JSForce connection
 * @param amount  Number of Fin. Accounts to be created
 * @param recordType Record Type of the Fin. Account
 */
export async function createFinAccountList(
  connection: any,
  amount: number = 1,
  recordType: String = "SavingsAccount"
) {
  return new Promise<String>(async resolve => {
    var ownerId: String = "";
    var ownerName: String = "";
    var finAccounts = [];
    var idList: any = [];
    var recTypeId = await getRecordTypeID(
      connection,
      "FinServ__FinancialAccount__c",
      recordType
    );
    var accountList: any = await getPersonAccount(connection);
    for (var i = 0; i < amount; i++) {
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
    //Use the connection passed as a param to create the accounts
    connection
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
        connection
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

async function getPersonAccount(connection: any) {
  // Check if there are existing person accounts, if not create new ones
  return new Promise<String>(resolve => {
    connection.query(
      "SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1",
      async function(err: any, result: any) {
        if (err) {
          return console.error(err);
        }

        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          // insert an account and use the retrieved id
          var accountList: any = await createAccountList(connection, 1);

          resolve(accountList);
        }
      }
    );
  });
}
