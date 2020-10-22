/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/coachesWorkbench/coachesWorkbench";
import GeneralInquiry from "../../../../pages/coachesWorkbench/create/generalInquiry";

/*** UTILITIES IMPORTS ***/
import { jsForce } from "../../../../utilities/jsforce";

import CustomError from "../../../../utilities/customErrorHandler";

/*** OBJECT STORE IMPORTS ***/
import { getFinAccount } from "../../../../objectStore/financialAccount";

/*** DECLARATIONS ***/
let accountId: string;
let accountName: string;
let financialAccountName: string;

describe("General Inquiry Record Creation", () => {
  before(() => {
    getFinAccount().then((finAccounts: any) => {
      financialAccountName = finAccounts[0].Name;
      accountId = finAccounts[0].FinServ__PrimaryOwner__c;
      jsForce.query(
        "SELECT Id, Name FROM Account WHERE Id = '" + accountId + "' LIMIT 1",
        async function (err: any, result: any) {
          if (err) {
            throw new CustomError("Failed to retrieve Account", err);
          }
          accountName = result.records[0].Name;
        }
      );
    });
  });

  it("should create a general inquiry case record", () => {
    CoachesWorkbench.login("coach");
    CoachesWorkbench.loadApp("Coaches Workbench");
    CoachesWorkbench.navCases.click();
    GeneralInquiry.clickNewBtn();
    GeneralInquiry.fillCreateInquiryDetails(accountName, financialAccountName);
    GeneralInquiry.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
