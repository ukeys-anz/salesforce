/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/coachesWorkbench/coachesWorkbench";
import GeneralInquiry from "../../../../pages/coachesWorkbench/edit/generalInquiry";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/case";
import CommonSections from "../../../../pages/complaintMgt/common/commonSections";
import helpers from "../../../../utilities/helpers";

/*** DECLARATIONS ***/
let caseNumber: string;
const recordType = "General_Inquiry";

describe("General Inquiry Record Resolved", () => {
  before(() => {
    createCaseList(1, recordType, "Coach").then((cases: any) => {
      caseNumber = cases[0].CaseNumber.toString();
    });
  });

  it("should resolve a general inquiry case record", () => {
    CoachesWorkbench.login("coach");
    GeneralInquiry.caseLink.click();
    CommonSections.goToCaseSearchPage();
    helpers.enterText(GeneralInquiry.searchText, caseNumber);
    GeneralInquiry.waitForCaseToDisplay(caseNumber);
    helpers.doJSClick($(`=${caseNumber}`));
    GeneralInquiry.editBtn.click();
    GeneralInquiry.selectCloseStatus();
    GeneralInquiry.save.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
