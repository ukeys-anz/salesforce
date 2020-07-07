/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaintMgt/create/customerComplaint";

/*** UTILITIES IMPORTS ***/
import * as faker from "faker";

/*** COMMON VALUE IMPORTS ***/
import { priority } from "../../../../pages/complaintMgt/common/customerComplaint";

describe("Customer Complaint Record Creation", () => {
  it("should create a customer complaint case record", () => {
    CustomerComplaint.login("idrlvl3");
    CustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $("=New").click();

    $("span=Customer Complaint").click();
    $("span=Next").click();

    CustomerComplaint.customerNumber.setValue("1234567891");

    CustomerComplaint.complainantType.click();
    $("span.slds-truncate=Individual").click();

    CustomerComplaint.descent.click();
    $("span.slds-truncate=No").click();

    CustomerComplaint.priority.click();
    $(`span.slds-truncate=${faker.random.arrayElement(priority)}`).click();

    CustomerComplaint.caseType.click();
    $("span.slds-truncate=Product").click();

    CustomerComplaint.productServiceName.setValue("Netwealth");
    $("strong=Netwealth").click();

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
