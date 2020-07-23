/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/coachesWorkbench/coachesWorkbench";
import GeneralInquiry from "../../../../pages/coachesWorkbench/edit/generalInquiry";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/case";

/*** DECLARATIONS ***/
let caseNumber: string;
const recordType = "General_Inquiry";

describe("General Inquiry Record Resolved", () => {
  before(() => {
    createCaseList(1, recordType, "Coach").then((cases: any) => {
      caseNumber = cases[0].CaseNumber;
    });
  });

  it("should resolve a general inquiry case record", () => {
    CoachesWorkbench.login("coach");
    CoachesWorkbench.loadApp("Coaches Workbench");
    CoachesWorkbench.navHome.click();

    $(`=${caseNumber}`).click();
    $("=Edit").click();

    GeneralInquiry.status.click();
    $('a[role="menuitemradio"]=Closed').click();

    GeneralInquiry.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
