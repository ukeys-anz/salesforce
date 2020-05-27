import { nav, generalInquiry } from "../../../pages/coachesWorkbench";

describe("Salesforce test duplicate", () => {
  it("should nav through sf duplicate", () => {
    browser.login();
    browser.loadApp("Coaches Workbench");
    $(nav.cases).click();
    $("=New").click();

    browser.pause(2000);

    $("span=General Inquiry").click();
    $("span=Next").click();

    browser.pause(3000);

    $(generalInquiry.text.subject).setValue("Test Subject");
    $(generalInquiry.text.description).setValue("Test Description");
    $(generalInquiry.lookup.accountName.selector).click();
    $(generalInquiry.lookup.accountName.firstValue).click();
    browser.debug();
  });
});
