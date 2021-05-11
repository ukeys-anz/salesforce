/*** BASE IMPORTS ***/
import NonCustomerComplaint from "../../../../pages/complaintMgt/edit/nonCustomerComplaint";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** COMMON VALUE IMPORTS ***/
import helpers from "../../../../utilities/helpers";
import CommonSections from "../../../../pages/complaintMgt/common/commonSections";

/*** DECLARATIONS ***/
let caseId: any;
const recordType = "Non_Customer_Complaint";

describe("Non Customer Complaint Record Edit", () => {
  /* before(() => {
    createCaseList(1, recordType, "idrlvl3").then((cases: any) => {
      caseId = cases[0].CaseNumber.toString();
    });
  });*/

  before(async () => {
    const cases: any = await createCaseList(1, recordType, "idrlvl3");
    caseId = cases[0].CaseNumber.toString();
  });

  it("should edit a non customer complaint case record", () => {
    NonCustomerComplaint.login("idrlvl3");
    NonCustomerComplaint.loadApp("Complaint Mgt");
    CommonSections.goToCasePage();
    CommonSections.goToCaseSearchPage();
    NonCustomerComplaint.enterCaseInSearch(caseId);
    NonCustomerComplaint.waitForCaseToDisplay(caseId);
    helpers.doJSClick($(`=${caseId}`));
    NonCustomerComplaint.clickEdit();
    NonCustomerComplaint.fillNonComplaintEditDetails();
    NonCustomerComplaint.save.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
