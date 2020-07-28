import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { getPersonAccount } from "./account";
import { getRecordTypeID } from "./util";
import CustomError from "../utilities/customErrorHandler";

interface IFinAccount {
  RecordTypeId: string;
  Name: string;
  FinServ__FinancialAccountType__c: string;
  FinServ__Status__c: string;
  FinServ__Ownership__c: string;
  FinServ__Balance__c: number;
  FinServ__CurrentPostedBalance__c: number;
  Interest_Accrued__c: number;
  FinServ__OpenDate__c: Date;
  FinServ__FinancialAccountNumber__c: string;
  FinServ__PrimaryOwner__c: string;
  Id?: string;
}

/**
 * @description Creates new Financial Account records depending on the amount passed and record type.
 * By default creates Non_Customer_Complaint record type complaint
 * @param amount  Number of Fin. Accounts to be created
 * @param recordType Record Type of the Fin. Account
 */
export async function createFinAccountList(
  amount = 1,
  recordType = "CheckingAccount",
  owner = null
): Promise<any> {
  return new Promise(async (resolve) => {
    const finAccounts = [];
    const idList: string[] = [];
    const recTypeId = await getRecordTypeID(
      "FinServ__FinancialAccount__c",
      recordType
    );

    let accountList: any = [];
    if (owner) {
      accountList.push(owner);
    } else {
      accountList = await getPersonAccount();
    }

    for (let i = 0; i < amount; i++) {
      const finAccount: IFinAccount = {
        RecordTypeId: recTypeId,
        Name:
          accountList[0].Name +
          (recordType == "CheckingAccount"
            ? " Everyday Account"
            : " Savings Account"),
        FinServ__FinancialAccountType__c:
          recordType == "CheckingAccount" ? "Checking" : " Savings",
        FinServ__Status__c: faker.random.arrayElement([
          "Open",
          "Closed",
          "On Hold",
          "Pending"
        ]),
        FinServ__Ownership__c: faker.random.arrayElement(["Individual"]),
        FinServ__Balance__c: parseFloat(faker.commerce.price(99, 9999, 2)),
        FinServ__CurrentPostedBalance__c: parseFloat(
          faker.commerce.price(99, 5999, 2)
        ),
        Interest_Accrued__c: parseFloat(faker.commerce.price(10, 999, 2)),
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
          throw new CustomError("Failed to create Financial Account", err);
        } else if (!result[0].success) {
          throw new CustomError(
            "Failed to create new Financial Account",
            result[0].errors[0].message
          );
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
              throw new CustomError(
                "Failed to retrieve Financial Account",
                err
              );
            }
            resolve(result);
          });
      });
  });
}

/**
 * @description extracts financial account record if is already in the system or creates new one.
 */
export async function getFinAccount(): Promise<any> {
  // Check if there are existing financial accounts, if not create new ones
  return new Promise<string>((resolve) => {
    jsForce.query(
      "SELECT Id, Name, FinServ__PrimaryOwner__c FROM FinServ__FinancialAccount__c WHERE RecordType.DeveloperName = 'CheckingAccount' ORDER BY CreatedDate LIMIT 1",
      async function (err: any, result: any) {
        if (err) {
          throw new CustomError("Failed to query Financial Account", err);
        }
        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          const finAccountList: any = await createFinAccountList(
            1,
            "CheckingAccount",
            null
          );
          resolve(finAccountList);
        }
      }
    );
  });
}

export default IFinAccount;
