/*** BASE IMPORTS ***/
import NonCustomerComplaint from "../../../../pages/complaintMgt/create/nonCustomerComplaint";

/*** COMMON VALUE IMPORTS ***/

import CommonSections from "../../../../pages/complaintMgt/common/commonSections";

describe("Non Customer Complaint Record Creation", () => {
  it("should create a non customer complaint case record", () => {
    NonCustomerComplaint.login("idrlvl3");
    NonCustomerComplaint.loadApp("Complaint Mgt");

    CommonSections.goToCasePage();
    NonCustomerComplaint.clickNewBtn();
    NonCustomerComplaint.gotoCreateNonComplaintPage();
    NonCustomerComplaint.fillCreateNonCustomerComplaintDetails();

    NonCustomerComplaint.create.click();
    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
