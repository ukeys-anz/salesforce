import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { createFinAccountList } from "./financialAccount";
import CustomError from "../utilities/customErrorHandler";

interface IFinGoal {
  Name: string;
  Financial_Account__c: string;
  Start_Date__c: Date;
  FinServ__TargetDate__c: Date;
  FinServ__ActualValue__c: number;
  FinServ__TargetValue__c: number;
  FinServ__PrimaryOwner__c: string;
}

/**
 * @description Creates new Financial Goal records depending on the count passed.
 * @param amount  Number of Fin. Goals to be created
 */
export async function createFinGoalList(
  amount = 1,
  primaryOwner: any
): Promise<any> {
  return new Promise<string>(async (resolve) => {
    const finGoals: IFinGoal[] = [];
    const idList: string[] = [];

    // Create Savings Accounts to map to new Goals being created
    createFinAccountList(amount, "SavingsAccount", primaryOwner).then(
      (savingsAccList: any) => {
        for (let i = 0; i < savingsAccList.length; i++) {
          const finGoal: IFinGoal = {
            Name: faker.random.arrayElement([
              "Buy New Car",
              "Build a Home",
              "Buy a Home",
              "Vaccation",
              "Overseas Trip",
              "Cruise Ship Tour",
              "Buy a Caravan",
              "Save for Retirement",
              "Euro Trip"
            ]),
            Financial_Account__c: savingsAccList[i].Id,
            Start_Date__c: faker.date.past(2),
            FinServ__TargetDate__c: faker.date.future(2),
            FinServ__ActualValue__c: savingsAccList[i].FinServ__Balance__c,
            FinServ__TargetValue__c: parseFloat(
              faker.commerce.price(55000, 80000, 2)
            ),
            FinServ__PrimaryOwner__c: primaryOwner.Id
          };
          finGoals.push(finGoal);
        }

        jsForce
          .sobject("FinServ__FinancialGoal__c")
          .create(finGoals, (err: any, result: any) => {
            if (err) {
              throw new CustomError("Failed to create Financial Goal", err);
            } else if (!result[0].success) {
              throw new CustomError(
                "Failed to create new Financial Goal",
                result[0].errors[0].message
              );
            }
            //Loop through the result to create a list of ids
            result.forEach((item: any) => {
              if (item.success) {
                idList.push(item.id);
              }
            });
            //Retrieve the new Financial Goals using the created id list and return the results
            jsForce
              .sobject("FinServ__FinancialGoal__c")
              .retrieve(idList, (err: any, result: any) => {
                if (err) {
                  throw new CustomError(
                    "Failed to retrieve Financial Goals",
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
 * @description extracts financial Goal record if it is already in the system or creates new one.
 */
export async function getFinGoal(): Promise<any> {
  // Check if there are existing financial goals, if not create new ones
  return new Promise<string>((resolve) => {
    jsForce.query(
      "SELECT Id, Name, Financial_Account__c, Start_Date__c, FinServ__TargetDate__c, FinServ__ActualValue__c, FinServ__TargetValue__c, FinServ__PrimaryOwner__c FROM FinServ__FinancialGoal__c LIMIT 1",
      async function (err: any, result: any) {
        if (err) {
          throw new CustomError("Failed to query Financial Goal", err);
        }
        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          const finGoalList: any = await createFinGoalList(1, null);
          resolve(finGoalList);
        }
      }
    );
  });
}
