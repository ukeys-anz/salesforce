import * as faker from "faker";
import { createAccountList } from "./account";
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
  // Check if there are existing person accounts, if not create new ones
  var ownerId: String = "";
  var ownerName: String = "";
  connection.query(
    "SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1",
    function(err: any, result: any) {
      if (err) {
        return console.error(err);
      }
      ownerId = result.records[0].Id;
      ownerName = result.records[0].Name;
    }
  );
  if (!ownerId) {
    // insert an account and use the retrieved id
    var accountList: any = await createAccountList(connection, 1);
    ownerId = accountList[0].Id;
    ownerName = accountList[0].Name;
  }
  return new Promise(async resolve => {
    var finAccounts = [];
    var idList: any = [];
    var recTypeId = await getRecordTypeID(connection, recordType);
    for (var i = 0; i < amount; i++) {
      let finAccount: IFinAccount = {
        RecordTypeId: recTypeId,
        Name: ownerName + " Savings",
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
        FinServ__PrimaryOwner__c: ownerId.toString()
      };
      finAccounts.push(finAccount);
    }
    //Use the connection passed as a param to create the accounts
    connection
      .sobject("FinServ__FinancialAccount__c")
      .create(finAccounts, (err: any, result: any) => {
        if (err) {
          return console.log("error", err);
        }
        //Loop through the result to create a list of ids
        result.forEach((item: any, index: any) => {
          idList.push(item.id);
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
async function getRecordTypeID(connection: any, devName: String) {
  return new Promise<String>(resolve => {
    //Todo make this query better using JSforce methods if possible
    connection.query(
      "SELECT Id FROM RecordType WHERE IsActive = TRUE AND sObjectType= 'FinServ__FinancialAccount__c' AND DeveloperName='" +
        devName +
        "'",
      (err: any, result: any) => {
        if (err) {
          return console.error("error", err);
        }
        resolve(result.records[0].Id);
      }
    );
  });
}
