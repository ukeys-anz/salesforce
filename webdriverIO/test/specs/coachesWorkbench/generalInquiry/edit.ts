/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/coachesWorkbench/coachesWorkbench";
import GeneralInquiry from "../../../../pages/coachesWorkbench/edit/generalInquiry";

/*** UTILITIES IMPORTS ***/
import { jsForce } from "../../../../utilities/jsforce";
import * as faker from "faker";
import CustomError from "../../../../utilities/customErrorHandler";
import helpers from "../../../../utilities/helpers";

/*** OBJECT STORE IMPORTS ***/
import { getFinAccount } from "../../../../objectStore/financialAccount";
import { createBlankCase } from "../../../../objectStore/case";
import CommonSections from "../../../../pages/complaintMgt/common/commonSections";

/*** DECLARATIONS ***/
let caseNumber: string;
let accountId: string;
let accountName: string;
let financialAccountName: string;

describe("General Inquiry Record Edit", () => {
  before(() => {
    createBlankCase(1, "General_Inquiry", "Coach").then((cases: any) => {
      caseNumber = cases[0].CaseNumber.toString();
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
    CoachesWorkbench.login("coach");
    CoachesWorkbench.loadApp("Coaches Workbench");
    GeneralInquiry.caseLink.click();
    CommonSections.goToCaseSearchPage();
    helpers.enterText(GeneralInquiry.searchText, caseNumber);
    GeneralInquiry.waitForCaseToDisplay(caseNumber);
    helpers.doJSClick($(`=${caseNumber}`));
    GeneralInquiry.editBtn.click();
    GeneralInquiry.fillEditGeneralInquiryDetails(
      accountName,
      financialAccountName
    );
    GeneralInquiry.save.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
