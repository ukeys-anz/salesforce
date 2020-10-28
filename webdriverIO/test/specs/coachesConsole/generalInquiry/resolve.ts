/*** BASE IMPORTS ***/
import GeneralInquiry from "../../../../pages/coachesConsole/edit/generalInquiry";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/case";
import CommonSections from "../../../../pages/complaintMgt/common/commonSections";
import helpers from "../../../../utilities/helpers";

/*** DECLARATIONS ***/
let caseId: string;
const recordType = "General_Inquiry";

describe("General Inquiry Record Resolved", () => {
  before(() => {
    createCaseList(1, recordType, "Coach").then((cases: any) => {
      caseId = cases[0].CaseNumber.toString();
    });
  });

  it("should resolve a general inquiry case record", () => {
    GeneralInquiry.login("coach");
    GeneralInquiry.loadApp("Coaches Console");
    CommonSections.goToCasePage();
    CommonSections.goToCaseSearchPage();
    GeneralInquiry.enterCaseInSearch(caseId);
    GeneralInquiry.waitForCaseToDisplay(caseId);
    helpers.doJSClick($(`=${caseId}`));
    GeneralInquiry.clickEdit();
    GeneralInquiry.selectCloseStatus();
    GeneralInquiry.save.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
