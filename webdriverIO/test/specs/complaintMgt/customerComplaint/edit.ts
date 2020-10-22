/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaintMgt/edit/customerComplaint";

/*** UTILITIES IMPORTS ***/

import helpers from "../../../../utilities/helpers";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

import CommonSections from "../../../../pages/complaintMgt/common/commonSections";

/*** DECLARATIONS ***/
let caseId: any;
const recordType = "Customer_Complaint";

describe("Customer Complaint Record Edit", () => {
  before(() => {
    createCaseList(1, recordType, "idrlvl3").then((cases: any) => {
      caseId = cases[0].CaseNumber.toString();
    });
  });

  it("should edit a customer complaint case record", () => {
    CustomerComplaint.login("idrlvl3");
    CustomerComplaint.loadApp("Complaint Mgt");
    CommonSections.goToCasePage();
    CommonSections.goToCaseSearchPage();
    CustomerComplaint.enterCaseInSearch(caseId);
    CustomerComplaint.waitForCaseToDisplay(caseId);
    helpers.doJSClick($(`=${caseId}`));
    CustomerComplaint.clickEdit();
    CustomerComplaint.fillComplaintEditDetails();
    CustomerComplaint.save.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
