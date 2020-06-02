/*** BASE IMPORTS ***/
import NonCustomerComplaint from "../../../../pages/complaints/edit/nonCustomerComplaint";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** DECLARATIONS ***/
var caseId: any;
var recordType: String = "Non_Customer_Complaint";

describe("Non Customer Record Edit", () => {
  before(() => {
    createCaseList(1, recordType).then((cases: any) => {
      caseId = cases[0].CaseNumber;
    });
  });

  it("should edit a non customer case record", () => {
    NonCustomerComplaint.login();
    NonCustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $(`.forceOutputLookup[title="${caseId}"]`).click();
    $("=Edit").click();

    NonCustomerComplaint.descent.click();
    $("=Not stated/unknown").click();
    NonCustomerComplaint.phone.setValue("0410000000");

    NonCustomerComplaint.nominatedThirdName.setValue("Test Party Name");
    NonCustomerComplaint.nominatedThirdEmail.setValue("test@test.com");
    NonCustomerComplaint.nominatedThirdStreet.setValue("1234 Test Street");
    NonCustomerComplaint.nominatedThirdSuburb.setValue("Suburbian Suburb");
    NonCustomerComplaint.nominatedThirdPostcode.setValue("7755");
    NonCustomerComplaint.nominatedThirdMobile.setValue("0410000001");
    NonCustomerComplaint.nominatedThirdPhone.setValue("97050000");

    NonCustomerComplaint.writtenResponseRequested.click();
    $("=Yes").click();
    NonCustomerComplaint.writtenResponseRequired.click();
    $("=No").click();

    NonCustomerComplaint.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
