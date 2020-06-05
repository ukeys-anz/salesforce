/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaints/create/customerComplaint";

describe("Customer Complaint Record Creation", () => {
  it("should create a customer complaint case record", () => {
    CustomerComplaint.login();
    CustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $("=New").click();

    $("span=Customer Complaint").click();
    $("span=Next").click();

    CustomerComplaint.customerNumber.setValue("12345");

    CustomerComplaint.complainantType.click();
    $("span.slds-truncate=Individual").click();

    CustomerComplaint.descent.click();
    $("span.slds-truncate=No").click();

    CustomerComplaint.priority.click();
    $("span.slds-truncate=None").click();

    CustomerComplaint.caseType.click();
    $("span.slds-truncate=Product").click();

    CustomerComplaint.productServiceLine.click();
    $("span.slds-truncate=Credit").click();

    CustomerComplaint.productServiceCategory.click();
    $("span.slds-truncate=Business finance").click();

    CustomerComplaint.productServiceType.click();
    $("span.slds-truncate=Business credit card").click();

    CustomerComplaint.accountCardPolicyNumber.setValue("12345");

    CustomerComplaint.description.setValue("Test description");

    CustomerComplaint.complainantDesiredOutcome.setValue(
      "Test desired outcome"
    );

    CustomerComplaint.writtenResponseNo.click();
    CustomerComplaint.complaintRelatingNo.click();

    CustomerComplaint.create.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
