import { nonCustomer } from "../../pages/complaints";

describe("Salesforce test duplicate", () => {
  it("should nav through sf duplicate", () => {
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

    browser.pause(2000);

    // browser.debug();
  });
});
