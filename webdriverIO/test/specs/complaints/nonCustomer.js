import { nonCustomer } from "../../../pages/complaints";

describe("Salesforce test", () => {
  it("should nav through sf", () => {
    browser.login();
    browser.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();
    // browser.pause(2000);
    $("=New").click();
    // browser.pause(2000);

    $("span=Non-Customer Complaint").click();
    $("span=Next").click();
    // browser.pause(2000)

    $("span=Agrees").click();
    // browser.pause(2000);

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

    // const elem = $('.forceToastMessage')
    // expect(elem).toHaveText('Complaint has been created successfully.')

    // browser.debug();
    browser.pause(1500);
    expect(".toastContainer").toBeVisible();
  });
});
//toastContainer slds-notify_container slds-is-relative
// slds-theme--success slds-notify--toast slds-notify slds-notify--toast forceToastMessage
