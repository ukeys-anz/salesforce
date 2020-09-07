/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaintMgt/edit/customerComplaint";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** DECLARATIONS ***/
var caseId: any;
const recordType = "Customer_Complaint";

describe("Customer Record Escalation", () => {
  before(async () => {
    console.log("Before execution start");
    const cases: any = await createCaseList(1, recordType, "idrlvl3");
    /* createCaseList(1, recordType, "idrlvl3").then((cases: any) => {*/
    console.log("result:" + JSON.stringify(cases[0].CaseNumber));
    caseId = JSON.stringify(cases[0].CaseNumber);
    console.log("caseId:" + caseId);
    /* });*/
  });

  it("should escalate a customer complaint case record", () => {
    console.log("after:" + caseId);
    CustomerComplaint.login("idrlvl3");
    CustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $("a[title='Select List View']").click();
    $("span=My Open Cases").click();
    $("span=Case Number").click();
    $("span=Case Number").click();

    $("a[title=" + caseId + "]").click();

    $("=Edit").click();

    CustomerComplaint.status.scrollIntoView();
    CustomerComplaint.status.click();
    $('a[role="menuitemradio"]=Escalated').click();

    $('input[title="Search Products"]').setValue("Netwealth");
    $("mark=Netwealth").click();

    CustomerComplaint.escalatedReason.click();
    $('a[role="menuitemradio"]=Remediation').click();

    CustomerComplaint.escalatedTo.click();
    $('a[role="menuitemradio"]=CRC').click();

    CustomerComplaint.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
