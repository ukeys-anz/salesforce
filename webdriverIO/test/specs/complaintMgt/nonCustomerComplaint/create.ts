/*** BASE IMPORTS ***/
import NonCustomerComplaint from "../../../../pages/complaints/create/nonCustomerComplaint";

describe("Non Customer Record Creation", () => {
  it("should create a non customer complaint case record", () => {
    NonCustomerComplaint.login();
    NonCustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $("=New").click();

    $("span=Non-Customer Complaint").click();
    $("span=Next").click();

    $("span=Agrees").click();

    NonCustomerComplaint.complainantType.click();
    $("span.slds-truncate=Individual").click();

    NonCustomerComplaint.firstName.setValue("Peter");
    NonCustomerComplaint.middleName.setValue("James");
    NonCustomerComplaint.lastName.setValue("Charalambous");

    NonCustomerComplaint.age.click();
    $("span.slds-truncate=18 - 24 years").click();

    NonCustomerComplaint.gender.click();
    $("span.slds-truncate=Male").click();

    NonCustomerComplaint.descent.click();
    $("span.slds-truncate=No").click();

    NonCustomerComplaint.email.setValue("peter.charalambous@anz.com");
    NonCustomerComplaint.mobile.setValue("0410000000");
    NonCustomerComplaint.phone.setValue("0410000000");
    NonCustomerComplaint.street.setValue("733 That Rd");
    NonCustomerComplaint.suburb.setValue("Warren Narre");
    NonCustomerComplaint.postcode.setValue("3805");

    NonCustomerComplaint.country.click();
    $("span.slds-truncate=Australia").click();

    NonCustomerComplaint.state.click();
    $("span.slds-truncate=VIC").click();

    NonCustomerComplaint.priority.click();
    $("span.slds-truncate=None").click();

    NonCustomerComplaint.caseType.click();
    $("span.slds-truncate=Product").click();

    NonCustomerComplaint.productServiceLine.click();
    $("span.slds-truncate=Credit").click();

    NonCustomerComplaint.productServiceCategory.click();
    $("span.slds-truncate=Business finance").click();

    NonCustomerComplaint.productServiceType.click();
    $("span.slds-truncate=Letter of credit").click();

    NonCustomerComplaint.description.setValue(
      "This is a test description from webdriverIO"
    );
    NonCustomerComplaint.desiredOutcome.setValue(
      "This is a test desired outcome from webdriverIO"
    );

    NonCustomerComplaint.writtenResponseNo.click();
    NonCustomerComplaint.complaintRelatingNo.click();

    NonCustomerComplaint.create.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
