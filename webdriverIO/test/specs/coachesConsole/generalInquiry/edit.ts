/*** BASE IMPORTS ***/
import GeneralInquiry from "../../../../pages/coachesConsole/edit/generalInquiry";

/*** UTILITIES IMPORTS ***/
import { jsForce } from "../../../../utilities/jsforce";
import CustomError from "../../../../utilities/customErrorHandler";
import helpers from "../../../../utilities/helpers";

/*** OBJECT STORE IMPORTS ***/
import { getFinAccount } from "../../../../objectStore/financialAccount";
import { createBlankCase } from "../../../../objectStore/case";
import CommonSections from "../../../../pages/complaintMgt/common/commonSections";

/*** DECLARATIONS ***/
let caseId: string;
let accountId: string;
let accountName: string;
let financialAccountName: string;

describe("General Inquiry Record Edit", () => {
  before(() => {
    createBlankCase(1, "General_Inquiry", "Coach").then((cases: any) => {
      caseId = cases[0].CaseNumber.toString();
    });

    getFinAccount().then((finAccounts: any) => {
      financialAccountName = finAccounts[0].Name;
      accountId = finAccounts[0].FinServ__PrimaryOwner__c;
      jsForce.query(
        `SELECT Id, Name FROM Account WHERE Id = '${accountId}' LIMIT 1`,
        async function (err: any, result: any) {
          if (err) {
            throw new CustomError("Failed to retrieve Account", err);
          }
          accountName = result.records[0].Name;
        }
      );
    });
  });

  it("should edit a general inquiry case record", () => {
    GeneralInquiry.login("coach");
    GeneralInquiry.loadApp("Coaches Console");
    CommonSections.goToCasePage();
    CommonSections.goToCaseSearchPage();
    GeneralInquiry.enterCaseInSearch(caseId);
    GeneralInquiry.waitForCaseToDisplay(caseId);
    helpers.doJSClick($(`=${caseId}`));
    GeneralInquiry.clickEdit();
    GeneralInquiry.fillEditGeneralInquiryDetails(
      accountName,
      financialAccountName
    );
    GeneralInquiry.save.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
