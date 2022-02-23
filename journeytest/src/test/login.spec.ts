import data from "../../testdata.json";
import SfLogin from "../modules/login";

describe("Case Creation - General Enquiry", () => {
  it("Login as a Coach User", async () => {
    browser.maximizeWindow();

    let sfLogin = new SfLogin();
    await sfLogin.salesForceLogin(data.envToTest, "coach");
  });
});
