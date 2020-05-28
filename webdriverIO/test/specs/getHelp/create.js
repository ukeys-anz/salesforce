import { nav, generalInquiry } from "../../../pages/coachesWorkbench";

describe("General Inquiry Record Creation", () => {
  it("should create a general inquiry case record", () => {
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

    $(generalInquiry.dropdown.status.selector).click();
    $("=Under Investigation").click();

    $(generalInquiry.dropdown.type.selector).click();
    $("=App Support").click();

    $("span=App Guide").click();
    $(generalInquiry.button.subTypeAdd).click();
    $("span=Device Support").click();
    $(generalInquiry.button.subTypeAdd).click();

    $("span=Bug Report & Feature").scrollIntoView();
    $("span=Bug Report & Feature").click();
    $(generalInquiry.button.additionalTypeAdd).click();

    $(generalInquiry.dropdown.channelReceived.selector).click();
    $("=Voice Call").click();

    $(generalInquiry.dropdown.caseReason.selector).click();
    $("=Existing problem").click();

    $(generalInquiry.dropdown.priority.selector).click();
    $("=Low").click();

    $(generalInquiry.button.save).click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
