/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaints/edit/customerComplaint";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** DECLARATIONS ***/
let caseId: any;
let recordType: String = "Customer_Complaint";

describe("Customer Record Escalation", () => {
  before(() => {
    createCaseList(1, recordType).then((cases: any) => {
      caseId = cases[0].CaseNumber;
    });
  });

  it("should escalate a customer complaint case record", () => {
    CustomerComplaint.login();
    CustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $(`.forceOutputLookup[title="${caseId}"]`).click();
    $("=Edit").click();

    CustomerComplaint.status.scrollIntoView();
    CustomerComplaint.status.click();
    $('a[role="menuitemradio"]=Escalated').click();
    CustomerComplaint.escalatedReason.click();
    $("=Above Banker Discretion").click();
    CustomerComplaint.escalatedTo.click();
    $("=CRC").click();

    CustomerComplaint.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
