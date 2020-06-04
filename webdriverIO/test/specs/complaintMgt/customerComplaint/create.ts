/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaints/create/customerComplaint";

/*** UTILITIES IMPORTS ***/
import * as faker from "faker";

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
    $(
      `span.slds-truncate=${faker.random.arrayElement([
        "None",
        "Complainant experiencing financial hardship",
        "Complainant experiencing vulnerability"
      ])}`
    ).click();

    CustomerComplaint.caseType.click();
    $(
      `span.slds-truncate=${faker.random.arrayElement([
        "Service Quality",
        "Rates, Fees and Charges",
        "Financial Difficulty",
        "Product",
        "Process",
        "Transaction and Payments",
        "Privacy and Confidentiality",
        "Disclosure",
        "Advice",
        "Insurance Claims"
      ])}`
    ).click();

    CustomerComplaint.productServiceLine.click();
    $("span.slds-truncate=Credit").click();

    CustomerComplaint.productServiceCategory.click();
    $("span.slds-truncate=Business finance").click();

    CustomerComplaint.productServiceType.click();
    $("span.slds-truncate=Business credit card").click();

    CustomerComplaint.accountCardPolicyNumber.setValue("12345");

    CustomerComplaint.description.setValue(faker.lorem.text());

    CustomerComplaint.complainantDesiredOutcome.setValue(faker.lorem.text());

    CustomerComplaint.writtenResponseNo.click();
    CustomerComplaint.complaintRelatingNo.click();

    CustomerComplaint.create.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
