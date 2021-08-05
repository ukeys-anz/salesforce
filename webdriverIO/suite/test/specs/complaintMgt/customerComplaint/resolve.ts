/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaintMgt/edit/customerComplaint";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";
import CommonSections from "../../../../pages/complaintMgt/common/commonSections";

import helpers from "../../../../utilities/helpers";

/*** DECLARATIONS ***/
let caseId: any;
const recordType = "Customer_Complaint";

describe("Customer Complaint Record Resolve", () => {
  /*before(() => {
    createCaseList(1, recordType, "idrlvl3").then((cases: any) => {
      caseId = cases[0].CaseNumber.toString();
    });
  });*/
  before(async () => {
    const cases: any = await createCaseList(1, recordType, "idrlvl3");
    caseId = cases[0].CaseNumber.toString();
  });

  it("should resolve a customer complaint case record", () => {
    CustomerComplaint.login("idrlvl3");
    CustomerComplaint.loadApp("Complaint Mgt");
    CommonSections.goToCasePage();
    CommonSections.goToCaseSearchPage();
    CustomerComplaint.enterCaseInSearch(caseId);
    CustomerComplaint.waitForCaseToDisplay(caseId);
    helpers.doJSClick($(`=${caseId}`));
    CustomerComplaint.clickEdit();
    CustomerComplaint.fillComplaintResolveDetails();
    CustomerComplaint.save.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
