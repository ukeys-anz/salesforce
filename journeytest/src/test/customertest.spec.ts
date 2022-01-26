import SfLogin from "modules/login";

describe("Customer Verification", () => {
  it("Login", async () => {
    const sfLogin = new SfLogin();
    await sfLogin.salesForceLogin("testsandbox", "");
  });

  it("Select Customer", () => {});

  it("Verify Customer", () => {});
});
