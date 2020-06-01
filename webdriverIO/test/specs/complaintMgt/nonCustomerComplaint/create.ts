import NonCustomerComplaint from "../../../../pages/complaints/nonCustomerComplaint";

describe("Non Customer Record Creation", () => {
  it("should create a non customer case record", () => {
    NonCustomerComplaint.login();
    NonCustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $("=New").click();

    $("span=Non-Customer Complaint").click();
    $("span=Next").click();

    $("span=Agrees").click();

    NonCustomerComplaint.complainantType.click();
    $("span=Individual").click();

    NonCustomerComplaint.firstName.setValue("Peter");
    NonCustomerComplaint.middleName.setValue("James");
    NonCustomerComplaint.lastName.setValue("Charalambous");

    NonCustomerComplaint.age.click();
    $("span=18 - 24 years").click();

    NonCustomerComplaint.gender.click();
    $("span=Male").click();

    NonCustomerComplaint.descent.click();
    $("span=No").click();

    NonCustomerComplaint.email.setValue("peter.charalambous@anz.com");
    NonCustomerComplaint.mobile.setValue("0410493503");
    NonCustomerComplaint.phone.setValue("0410493503");
    NonCustomerComplaint.street.setValue("733 Glasscocks Rd");
    NonCustomerComplaint.suburb.setValue("Narre Warren South");
    NonCustomerComplaint.postcode.setValue("3805");

    NonCustomerComplaint.country.click();
    $("span=Australia").click();

    NonCustomerComplaint.state.click();
    $("span=VIC").click();

    NonCustomerComplaint.priority.click();
    $("span=None").click();

    NonCustomerComplaint.caseType.click();
    $("span=Product").click();

    NonCustomerComplaint.productServiceLine.click();
    $("span=Credit").click();

    NonCustomerComplaint.productServiceCategory.click();
    $("span=Business finance").click();

    NonCustomerComplaint.productServiceType.click();
    $("span=Letter of credit").click();

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
