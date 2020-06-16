import { jsForce } from "../utilities/jsforce";
import * as faker from "faker";
import { getRecordTypeID, getUserByAlias } from "./util";

interface ICase {
  IDR_Complainant_Type__c: String;
  IDR_NC_First_Name__c: String;
  IDR_NC_Last_Name__c: String;
  IDR_NC_Email__c: String;
  IDR_NC_Mobile__c: String;
  IDR_NC_Street__c: String;
  IDR_NC_Suburb__c: String;
  IDR_NC_Postcode__c: String;
  IDR_NC_Age__c: String;
  IDR_NC_Gender__c: String;
  IDR_NC_Descent__c: String;
  IDR_NC_State__c: String;
  Type: String;
  IDR_Is_Common__c: Boolean;
  Description: String;
  IDR_Complainant_Desired_Outcome__c: String;
  RecordTypeId: String;
  IDR_Customer_Number__c: String;
  IDR_Is_Written_Resp_Requested__c: String;
  IDR_Is_Written_Resp_Required__c: String;
  IDR_NC_Is_Consent_Obtained__c: Boolean;
  OwnerId?: String;
}

/**
 * @description Creates a new case records depending on the amount passed and record type.
 * By default creates Non_Customer_Complaint record type complaint
 * @param amount  Number of cases to be created
 * @param recordType Record Type of the case
 */
export function createCaseList(
  amount: number = 1,
  recordType: String = "Non_Customer_Complaint",
  alias: string
) {
  return new Promise(async resolve => {
    let cases: ICase[] = [];
    let user: any = await getUserByAlias(alias);

    let idList: any = [];
    for (let i = 0; i < amount; i++) {
      let mockCase: ICase = {
        IDR_Complainant_Type__c: "1",
        Type: "2",
        IDR_Is_Common__c: faker.random.boolean(),
        Description: faker.lorem.text(),
        IDR_Complainant_Desired_Outcome__c: faker.lorem.text(),
        RecordTypeId: await getRecordTypeID("Case", recordType),
        IDR_NC_First_Name__c: "",
        IDR_NC_Last_Name__c: "",
        IDR_NC_Email__c: "",
        IDR_NC_Mobile__c: "",
        IDR_NC_Street__c: "",
        IDR_NC_Suburb__c: "",
        IDR_NC_Postcode__c: "",
        IDR_NC_Age__c: "",
        IDR_NC_Gender__c: "",
        IDR_NC_Descent__c: "1",
        IDR_NC_State__c: "",
        IDR_Customer_Number__c: "",
        IDR_Is_Written_Resp_Requested__c: "No",
        IDR_Is_Written_Resp_Required__c: "No",
        IDR_NC_Is_Consent_Obtained__c: true,
        OwnerId: user.Id
      };

      if (recordType === "Customer_Complaint") {
        mockCase.IDR_Customer_Number__c = faker.finance.account(10).toString();
      } // future record types have else if or switch
      else {
        mockCase.IDR_NC_First_Name__c = faker.name.firstName();
        mockCase.IDR_NC_Last_Name__c = faker.name.lastName();
        mockCase.IDR_NC_Email__c = faker.internet.email();
        mockCase.IDR_NC_Mobile__c = faker.phone.phoneNumber("04########");
        mockCase.IDR_NC_Street__c = faker.address.streetName();
        mockCase.IDR_NC_Suburb__c = faker.address.city();
        mockCase.IDR_NC_Postcode__c = faker.address.zipCode("####");
        mockCase.IDR_NC_Age__c = "2";
        mockCase.IDR_NC_Gender__c = "1";
        mockCase.IDR_NC_State__c = "2";
      }
      cases.push(mockCase);
    }

    //Include headers so we can assign the user as owner of case
    jsForce.sobject("Case").create(
      cases,
      {
        headers: {
          "SForce-Auto-Assign": false
        }
      },
      (err: any, result: any) => {
        if (!result[0].success) {
          return console.log("error", result[0].errors);
        }
        //Loop through the result to create a list of ids
        result.forEach((item: any) => {
          if (item.success) {
            idList.push(item.id);
          }
        });
        //Retrieve the new accounts using the created id list and return the results
        jsForce.sobject("Case").retrieve(idList, (err: any, result: any) => {
          if (err) {
            return console.log("error", err);
          }
          resolve(result);
        });
      }
    );
  });
}

//This will be used for new scenario
export const getCase = (devName: String) => {
  return new Promise<string>(resolve => {
    jsForce.query(
      `SELECT Max(CaseNumber) ID FROM Case where Status='Open' and RecordTypeId IN (SELECT Id FROM RecordType WHERE IsActive = TRUE AND sObjectType='Case' AND DeveloperName='${devName}')`,
      (err: any, result: any) => {
        if (err) {
          return console.error(err);
        }
        resolve(result.records[0].ID);
      }
    );
  });
};
