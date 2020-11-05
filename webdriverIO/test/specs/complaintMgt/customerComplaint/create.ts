/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaintMgt/create/customerComplaint";

/*** COMMON VALUE IMPORTS ***/

import CommonSections from "../../../../pages/complaintMgt/common/commonSections";

describe("Customer Complaint Record Creation", () => {
  it("should create a customer complaint case record", () => {
    CustomerComplaint.login("idrlvl3");
    CustomerComplaint.loadApp("Complaint Mgt");

    CommonSections.goToCasePage();
    CustomerComplaint.clickNewBtn();
    CustomerComplaint.gotoCreateComplaintPage();
    CustomerComplaint.fillCustomerComplaintDetails();

    CustomerComplaint.create.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
