import SfLogin from "../common/login";

describe("Customer Verification", () => {
  it("Login", async () => {
    const sfLogin = new SfLogin();
    await sfLogin.salesForceLogin("");
  });

  it("Select Customer", () => {});

  it("Verify Customer", () => {});
});
