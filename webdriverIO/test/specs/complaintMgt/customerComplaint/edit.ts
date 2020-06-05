/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaints/edit/customerComplaint";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** DECLARATIONS ***/
let caseId: any;
let recordType: String = "Customer_Complaint";

describe("Customer Record Edit", () => {
  before(() => {
    createCaseList(1, recordType).then((cases: any) => {
      caseId = cases[0].CaseNumber;
    });
  });

  it("should edit a customer complaint case record", () => {
    CustomerComplaint.login();
    CustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $(`.forceOutputLookup[title="${caseId}"]`).click();
    $("=Edit").click();

    CustomerComplaint.nominatedThirdName.setValue("John Smith");
    CustomerComplaint.nominatedThirdEmail.setValue("johnsmith@test.com");
    CustomerComplaint.nominatedThirdStreet.setValue("86 That St");
    CustomerComplaint.nominatedThirdSuburb.setValue("Suburbian Suburb");
    CustomerComplaint.nominatedThirdPostcode.setValue("3323");

    CustomerComplaint.nominatedThirdMobile.setValue("0410000300");
    CustomerComplaint.nominatedThirdPhone.setValue("97058888");

    CustomerComplaint.description.setValue("Edited description");
    CustomerComplaint.desiredOutcome.setValue("Edited outcome");

    CustomerComplaint.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
