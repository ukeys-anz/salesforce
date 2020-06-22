/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaintMgt/edit/customerComplaint";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** DECLARATIONS ***/
let caseId: any;
let recordType: String = "Customer_Complaint";

describe("Customer Record Resolve", () => {
  before(() => {
    createCaseList(1, recordType, "idrlvl3").then((cases: any) => {
      caseId = cases[0].CaseNumber;
    });
  });

  it("should resolve a customer complaint case record", () => {
    CustomerComplaint.login("idrlvl3");
    CustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $("a[title='Select List View']").click();
    $("span=My Open Cases").click();
    $(`=${caseId}`).click();
    $("=Edit").click();

    CustomerComplaint.status.scrollIntoView();
    CustomerComplaint.status.click();
    $('a[role="menuitemradio"]=Resolved').click();

    $('input[title="Search Products"]').setValue("Netwealth");
    $("mark=Netwealth").click();

    CustomerComplaint.complaintOutcome.click();
    $("=In favour of customer in full").click();
    CustomerComplaint.complaintRemedy.click();
    $("=Non-financial remedy").click();

    CustomerComplaint.financialCompensation.click();
    $('a[role="menuitemradio"]=None').click();

    CustomerComplaint.descriptionOfOutcome.setValue("No compensation awarded");

    CustomerComplaint.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
