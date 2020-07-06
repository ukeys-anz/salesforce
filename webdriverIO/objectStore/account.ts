import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { getRecordTypeID } from "./util";
import CustomError from "../utilities/customErrorHandler";

interface IAccount {
  RecordTypeId: string;
  FirstName: string;
  LastName: string;
  FinServ__Status__c: string;
  FinServ__ClientCategory__c: string;
  FinServ__MarketingSegment__c: string;
  FinServ__PersonalInterests__c: string;
  FinServ__FinancialInterests__c: string;
  OCV_ID__c: number;
  FinServ__ServiceModel__c: string;
  FinServ__ReviewFrequency__c: string;
  FinServ__LastReview__c: Date;
  FinServ__NextReview__c: Date;
  FinServ__LastInteraction__c: Date;
  FinServ__NextInteraction__c: Date;
  FinServ__InvestmentExperience__c: string;
  FinServ__InvestmentObjectives__c: string;
  FinServ__TimeHorizon__c: string;
  FinServ__RiskTolerance__c: string;
  FinServ__NetWorth__c: string;
  BillingStreet: string;
  BillingCity: string;
  BillingState: string;
  BillingPostalCode: string;
  BillingCountry: string;
}

/**
 * @description Creates a new account depending on the amount passed and record type.
 * creates PersonAccount record type account
 * @param amount  Number of accounts to be created
 * @param recordType Record Type of the account
 */
export async function createAccountList(
  amount: number = 1,
  recordType: string = "PersonAccount"
) {
  return new Promise(async (resolve) => {
    let accounts = [];
    let idList: any = [];
    let recTypeId = await getRecordTypeID("Account", recordType);
    for (let i = 0; i < amount; i++) {
      let account: IAccount = {
        RecordTypeId: recTypeId,
        FirstName: faker.name.firstName(),
        LastName: faker.name.lastName(),
        FinServ__Status__c: faker.random.arrayElement([
          "Active",
          "Closed",
          "Deceased",
          "Deliquent",
          "Dormant",
          "Inactive",
          "Onboarding",
          "Prospect"
        ]),
        FinServ__ClientCategory__c: faker.random.arrayElement([
          "Platinum",
          "Gold",
          "Silver",
          "Bronze"
        ]),
        FinServ__MarketingSegment__c: faker.random.arrayElement([
          "Mass Affluent",
          "High Net Worth",
          "Female Investor",
          "Milennial"
        ]),
        FinServ__PersonalInterests__c: faker.random.arrayElement([
          "Cooking",
          "College Basketball",
          "Environment",
          "Hiking",
          "Biking",
          "Wine"
        ]),
        FinServ__FinancialInterests__c: faker.random.arrayElement([
          "Municipal Bonds",
          "Fixed Income",
          "Energy",
          "Technology",
          "Retirement",
          "College Planning"
        ]),
        OCV_ID__c: faker.random.number(),
        FinServ__ServiceModel__c: faker.random.arrayElement([
          "Tier 1",
          "Tier 2",
          "Tier 3"
        ]),
        FinServ__ReviewFrequency__c: faker.random.arrayElement([
          "Monthly",
          "Quarterly",
          "Annually"
        ]),
        FinServ__LastReview__c: faker.date.recent(60),
        //TODO: faker soon will be used instead of a negative value here
        //once released properly
        FinServ__NextReview__c: faker.date.recent(-60),
        FinServ__LastInteraction__c: faker.date.recent(100),
        //TODO: faker soon will be used instead of a negative value here
        //once released properly
        FinServ__NextInteraction__c: faker.date.recent(-100),
        FinServ__InvestmentExperience__c: faker.random.arrayElement([
          "Experienced",
          "Moderately Experienced",
          "Moderately Inexperienced",
          "Inexperienced"
        ]),
        FinServ__InvestmentObjectives__c: faker.random.arrayElement([
          "Conservative Income",
          "Income",
          "Balanced",
          "Growth",
          "Aggressive Growth"
        ]),
        FinServ__TimeHorizon__c: faker.random.arrayElement([
          "Long Term",
          "Medium Term",
          "Short Term"
        ]),
        FinServ__RiskTolerance__c: faker.random.arrayElement([
          "Aggressive",
          "Conservative",
          "Moderate",
          "None"
        ]),
        FinServ__NetWorth__c: faker.commerce.price(99, 9999, 2),
        BillingStreet: faker.address.streetAddress(),
        BillingCity: faker.address.city(),
        BillingState: faker.address.state(),
        BillingPostalCode: faker.address.zipCode(),
        BillingCountry: faker.address.country()
      };
      accounts.push(account);
    }

    jsForce.sobject("Account").create(accounts, (err: any, result: any) => {
      if (err) {
        throw new CustomError("Failed to create Account", err);
      }

      //Loop through the result to create a list of ids
      result.forEach((item: any, index: any) => {
        idList.push(item.id);
      });

      //Retrieve the new accounts using the created id list and return the results
      jsForce.sobject("Account").retrieve(idList, (err: any, result: any) => {
        if (err) {
          throw new CustomError("Failed to retrieve Account", err);
        }
        resolve(result);
      });
    });
  });
}

/**
 * @description extracts person account record if is already in the system or creates new one.
 */
export async function getPersonAccount() {
  // Check if there are existing person accounts, if not create new ones
  return new Promise<string>((resolve) => {
    jsForce.query(
      "SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'PersonAccount' LIMIT 1",
      async function (err: any, result: any) {
        if (err) {
          throw new CustomError("Failed to query Record Type", err);
        }

        if (result.records.length > 0) {
          resolve(result.records);
        } else {
          // insert an account and use the retrieved id
          let accountList: any = await createAccountList(1);

          resolve(accountList);
        }
      }
    );
  });
}
