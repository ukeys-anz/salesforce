import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { createFinAccountList } from "./financialAccount";
import CustomError from "../utilities/customErrorHandler";

interface IFinCard {
  Name: string;
  FinServ__FinancialAccount__c: string;
  FinServ__BinNumber__c: string;
  Card_Activation_Status__c: string;
  Card_Delivery_Status__c: string;
  FinServ__AccountHolder__c: string;
  FinServ__OwnershipType__c: string;
  FinServ__Active__c: boolean;
  Pin_Set__c: boolean;
  Temporary_Lock__c: string;
  FinServ__ValidUntil__c: Date;
}

/**
 * @description Creates new Financial Card records depending on the count passed.
 * @param amount  Number of Fin. Cards to be created
 */
export async function createFinCardsList(amount = 1, primaryOwner: any) {
  return new Promise<string>(async (resolve) => {
    const finCards: any = [];
    const idList: any = [];

    // Create Savings Accounts to map to new cards being created
    createFinAccountList(amount, "SavingsAccount", primaryOwner).then(
      (savingsAccList: any) => {
        for (let i = 0; i < savingsAccList.length; i++) {
          const finCard: IFinCard = {
            Name: faker.random.arrayElement([
              "ANZ Rewards Black",
              "ANZ Rewards Platinum",
              "ANZ Rewards",
              "ANZ Platinum",
              "ANZ First",
              "ANZ Low Rate",
              "ANZ Frequent Flyer Black",
              "ANZ Frequent Flyer Platinum",
              "ANZ Frequent Flyer"
            ]),
            FinServ__FinancialAccount__c: savingsAccList[i].Id,
            FinServ__BinNumber__c: faker.finance.account(16),
            Card_Activation_Status__c: faker.random.arrayElement([
              "Activated",
              "Not Activated"
            ]),
            Card_Delivery_Status__c: faker.random.arrayElement([
              "Created",
              "Posted",
              "Delivered"
            ]),
            FinServ__AccountHolder__c: primaryOwner.Id,
            FinServ__OwnershipType__c: faker.random.arrayElement([
              "Primary",
              "Authorized",
              "Other"
            ]),
            FinServ__Active__c: faker.random.boolean(),
            Pin_Set__c: faker.random.boolean(),
            Temporary_Lock__c: faker.random.arrayElement([
              "ATM withdrawal",
              "Contactless",
              "Gambling",
              "Online"
            ]),
            FinServ__ValidUntil__c: faker.date.past(2)
          };
          finCards.push(finCard);
        }

        jsForce
          .sobject("FinServ__Card__c")
          .create(finCards, (err: any, result: any) => {
            if (err) {
              throw new CustomError("Failed to create Financial Cards", err);
            } else if (!result[0].success) {
              throw new CustomError(
                "Failed to create new Financial Card",
                result[0].errors[0].message
              );
            }
            //Loop through the result to create a list of ids
            result.forEach((item: any) => {
              if (item.success) {
                idList.push(item.id);
              }
            });
            //Retrieve the new Financial Cards using the created id list and return the results
            jsForce
              .sobject("FinServ__Card__c")
              .retrieve(idList, (err: any, result: any) => {
                if (err) {
                  throw new CustomError(
                    "Failed to retrieve Financial Cards",
                    err
                  );
                }
                resolve(result);
              });
          });
      }
    );
  });
}

/**
 * @description extracts financial Cards record if it is already in the system or creates new one.
 */
export async function getFinCard() {
  // Check if there are existing financial cards, if not create new ones
  return new Promise<string>((resolve) => {
    jsForce.query(
      "SELECT Id, Name, FinServ__AccountHolder__c, FinServ__Active__c, FinServ__BinNumber__c, Card_Activation_Status__c, Card_Delivery_Status__c, FinServ__FinancialAccount__c, FinServ__OwnershipType__c, Pin_Set__c, Temporary_Lock__c, FinServ__ValidUntil__c FROM FinServ__Card__c LIMIT 1",
      async function (err: any, result: any) {
        if (err) {
          throw new CustomError("Failed to query Financial Card", err);
        }
        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          const finCardsList: any = await createFinCardsList(1, null);
          resolve(finCardsList);
        }
      }
    );
  });
}
