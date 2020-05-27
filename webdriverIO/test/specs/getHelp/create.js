import { nav } from "../../../pages/coachesWorkbench";

describe("Salesforce test duplicate", () => {
  it("should nav through sf duplicate", () => {
    browser.login();
    console.log(nav.cases);
    // browser.loadApp("Coaches Workbench");
    // $("span=Cases").click();
    $(nav.cases).waitForClickable();
    $(nav.cases).click();

    browser.pause(2000);

    browser.debug();
  });
});
