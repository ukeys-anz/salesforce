/*** BASE IMPORTS ***/
import NonCustomerComplaint from "../../../../pages/complaints/create/nonCustomerComplaint";

/*** UTILITIES IMPORTS ***/
import * as faker from "faker";

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

    NonCustomerComplaint.firstName.setValue(faker.name.firstName());
    NonCustomerComplaint.middleName.setValue(faker.name.firstName());
    NonCustomerComplaint.lastName.setValue(faker.name.lastName());

    NonCustomerComplaint.age.click();
    $(
      `span.slds-truncate=${faker.random.arrayElement([
        "Less than 18 years",
        "18 - 24 years",
        "25 - 34 years",
        "35 - 44 years",
        "45 - 54 years",
        "55 - 64 years",
        "Greater than 65 years",
        "Not known"
      ])}`
    ).click();

    NonCustomerComplaint.gender.click();
    $(
      `span.slds-truncate=${faker.random.arrayElement([
        "Male",
        "Female",
        "Other"
      ])}`
    ).click();

    NonCustomerComplaint.descent.click();
    $("span.slds-truncate=No").click();

    NonCustomerComplaint.email.setValue(faker.internet.email());
    NonCustomerComplaint.mobile.setValue(faker.phone.phoneNumber("04########"));
    NonCustomerComplaint.phone.setValue(faker.phone.phoneNumber("97######"));
    NonCustomerComplaint.street.setValue(faker.address.streetName());
    NonCustomerComplaint.suburb.setValue(faker.address.city());
    NonCustomerComplaint.postcode.setValue(faker.address.zipCode("####"));

    NonCustomerComplaint.country.click();
    $("span.slds-truncate=Australia").click();

    NonCustomerComplaint.state.click();
    $(
      `span.slds-truncate=${faker.random.arrayElement([
        "NSW",
        "VIC",
        "QLD",
        "SA",
        "WA",
        "TAS",
        "NT",
        "ACT",
        "OTHER TERRITORIES"
      ])}`
    ).click();

    NonCustomerComplaint.priority.click();
    $(
      `span.slds-truncate=${faker.random.arrayElement([
        "None",
        "Complainant experiencing financial hardship",
        "Complainant experiencing vulnerability"
      ])}`
    ).click();

    NonCustomerComplaint.caseType.click();
    $("span.slds-truncate=Product").click();

    NonCustomerComplaint.productServiceLine.click();
    $("span.slds-truncate=Credit").click();

    NonCustomerComplaint.productServiceCategory.click();
    $("span.slds-truncate=Business finance").click();

    NonCustomerComplaint.productServiceType.click();
    $("span.slds-truncate=Letter of credit").click();

    NonCustomerComplaint.description.setValue(faker.lorem.text());
    NonCustomerComplaint.desiredOutcome.setValue(faker.lorem.text());

    NonCustomerComplaint.writtenResponseNo.click();
    NonCustomerComplaint.complaintRelatingNo.click();

    NonCustomerComplaint.create.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
