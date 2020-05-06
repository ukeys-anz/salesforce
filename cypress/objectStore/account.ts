import * as faker from "faker";
interface IAccount {
  RecordTypeId: String;
  Name: String;
  FinServ__Status__c: String;
  FinServ__ClientCategory__c: String;
  FinServ__MarketingSegment__c: String;
  FinServ__PersonalInterests__c: String;
  FinServ__FinancialInterests__c: String;
  OCV_ID__c: Number;
  FinServ__ServiceModel__c: String;
  FinServ__ReviewFrequency__c: String;
  FinServ__LastReview__c: Date;
  FinServ__NextReview__c: Date;
  FinServ__LastInteraction__c: Date;
  FinServ__NextInteraction__c: Date;
  FinServ__InvestmentExperience__c: String;
  FinServ__InvestmentObjectives__c: String;
  FinServ__TimeHorizon__c: String;
  FinServ__RiskTolerance__c: String;
  FinServ__NetWorth__c: String;
  BillingStreet: String;
  BillingCity: String;
  BillingState: String;
  BillingPostalCode: String;
  BillingCountry: String;
}
export async function createAccountList(
  connection: any,
  amount: number = 1,
  recordType: String = "PersonAccount"
) {
  return new Promise(async resolve => {
    var accounts = [];
    var idList: any = [];
    var recTypeId = await getRecordTypeID(connection, recordType);
    for (var i = 0; i < amount; i++) {
      let account: IAccount = {
        RecordTypeId: recTypeId,
        Name: faker.name.firstName() + " " + faker.name.lastName(),
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
    //Use the connection passed as a param to create the accounts
    connection.sobject("Account").create(accounts, (err: any, result: any) => {
      if (err) {
        return console.log("error", err);
      }
      //Loop through the result to create a list of ids
      result.forEach((item: any, index: any) => {
        idList.push(item.id);
      });
      //Retrieve the new accounts using the created id list and return the results
      connection
        .sobject("Account")
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
      "SELECT Id FROM RecordType WHERE IsActive = TRUE AND sObjectType= 'Account' AND DeveloperName='" +
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
