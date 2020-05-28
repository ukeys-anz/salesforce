import { nonCustomer } from "../../../pages/complaintMgt";

describe("Non Customer Record Creation", () => {
  it("should create a non customer case record", () => {
    browser.login();
    browser.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $("=New").click();

    $("span=Non-Customer Complaint").click();
    $("span=Next").click();

    $("span=Agrees").click();

    $(nonCustomer.dropdown.complainantType.selector).click();
    $(nonCustomer.dropdown.complainantType.individualValue).click();

    $(nonCustomer.text.firstName).setValue("Peter");
    $(nonCustomer.text.middleName).setValue("James");
    $(nonCustomer.text.lastName).setValue("Charalambous");

    $(nonCustomer.dropdown.age.selector).click();
    $(nonCustomer.dropdown.age.less18Value).click();

    $(nonCustomer.dropdown.gender.selector).click();
    $(nonCustomer.dropdown.gender.maleValue).click();

    $(nonCustomer.dropdown.descent.selector).click();
    $(nonCustomer.dropdown.descent.noValue).click();

    $(nonCustomer.text.email).setValue("peter.charalambous@anz.com");
    $(nonCustomer.text.mobile).setValue("0410493503");
    $(nonCustomer.text.phone).setValue("0410493503");
    $(nonCustomer.text.street).setValue("733 Glasscocks Rd");
    $(nonCustomer.text.suburb).setValue("Narre Warren South");
    $(nonCustomer.text.postcode).setValue("3805");

    $(nonCustomer.dropdown.country.selector).click();
    $(nonCustomer.dropdown.country.australiaValue).click();

    $(nonCustomer.dropdown.state.selector).click();
    $(nonCustomer.dropdown.state.vicValue).click();

    $(nonCustomer.dropdown.priority.selector).click();
    $(nonCustomer.dropdown.priority.noneValue).click();

    $(nonCustomer.dropdown.caseType.selector).click();
    $(nonCustomer.dropdown.caseType.processValue).click();

    $(nonCustomer.dropdown.productServiceLine.selector).click();
    $(nonCustomer.dropdown.productServiceLine.creditValue).click();

    $(nonCustomer.dropdown.productServiceCategory.selector).click();
    $(nonCustomer.dropdown.productServiceCategory.guaranteeValue).click();

    $(nonCustomer.text.description).setValue(
      "This is a test description from webdriverIO"
    );
    $(nonCustomer.text.desiredOutcome).setValue(
      "This is a test desired outcome from webdriverIO"
    );

    $(nonCustomer.radio.writtenResponse.no).click();
    $(nonCustomer.radio.complaintRelating.no).click();

    $(nonCustomer.button.create).click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
