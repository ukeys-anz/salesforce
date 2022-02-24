import SfLogin from "../common/login";

describe("Case Creation - General Enquiry", () => {
  it("Login as a Coach User", async () => {
    browser.maximizeWindow();

    let sfLogin = new SfLogin();
    await sfLogin.salesForceLogin("coach");
  });
});
