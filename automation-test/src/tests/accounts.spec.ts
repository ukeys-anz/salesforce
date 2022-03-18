import Auth from "common/Auth";
import LwcCustomerDetails from "pageObjects/lwcCustomerDetails";
import SfNavigation from "common/navigation";
import SfAccounts from "common/accounts";
// import SfCustomer from "../common/customer";
import { describe } from "mocha";
import LwcFinancialAccount from "pageObjects/lwcFinancialAccount";

// describe("Cards verification", () => {
//   it("Login and search for a customer with a valid card", async () => {
//     await browser.maximizeWindow();

//     await Auth.loginSalesforce("Coach");

//     //Close all tabs
//     await browser.pause(5000);
//     await SfPageUtils.closeAllTabsMain();

//     //Search for a customer
//     const customerPageRoot = await utam.load(LwcCustomerDetails);
//     const navigationShowElement = await customerPageRoot.getNavigationShow();
//     await navigationShowElement.click();

//     let sfNavigation = new SfNavigation();
//     await sfNavigation.selectNavigation("Accounts");

//     let sfAccountView = new SfAccounts();

//     await sfAccountView.selectAccountFilter("All Accounts");
// await sfAccountView.searchAccount("scenarioCardVerification");
//   });

//   it("Verify the accounts of a customer", async () => {
//     //Get card details
//     let sfCustomer = new SfCustomer();
//     await sfCustomer.getAccounts();
//   });
// });

async function initialLoad(skipLogin: boolean) {
  if (!skipLogin) {
    await browser.maximizeWindow();

    await Auth.loginSalesforceAsRole("Coach");

    //Close all tabs
    await browser.pause(5000);
  }

  const customerPageRoot = await utam.load(LwcCustomerDetails);
  const navigationShowElement = await customerPageRoot.getNavigationShow();
  await navigationShowElement.click();

  //Navigate to our test user
  const sfNavigation = new SfNavigation();
  await sfNavigation.selectNavigation("Accounts");
  //Close all tabs
  // await SfPageUtils.closeAllTabsMain();

  const sfAccountView = new SfAccounts();
  await sfAccountView.selectAccountFilter();
  await sfAccountView.searchAccountByName("Test Automation");
}

describe("Verifies balances on the account", () => {
  before(async () => {
    await initialLoad(false);
  });

  it("Verifies the everyday account balance", async () => {
    const financialAccountRoot = await utam.load(LwcFinancialAccount);
    const everydayAccount = financialAccountRoot.getEverydayAccount();
    expect(everydayAccount).toBeExisting();
    const checkingAmount = await $("lightning-formatted-number=$18.00");
    expect(checkingAmount).toBeExisting();
  });

  it("Verifies the savings account balance", async () => {
    const financialAccountRoot = await utam.load(LwcFinancialAccount);
    const savingsAccount = financialAccountRoot.getSavingsAccount();
    expect(savingsAccount).toBeExisting();
    const savingsAmount = await $("lightning-formatted-number=$89.00");
    expect(savingsAmount).toBeExisting();
  });

  it("Verifies the total account balance", async () => {
    const financialAccountRoot = await utam.load(LwcFinancialAccount);
    const totalBalance = financialAccountRoot.getTotalBalance();
    expect(totalBalance).toBeExisting();
    const totalAmount = await $(
      "lightning-formatted-number[data-id='total-balance']=$107.00"
    );
    expect(totalAmount).toBeExisting();
  });

  it("Verifies the financial goals visible", async () => {
    const financialAccountRoot = await utam.load(LwcFinancialAccount);
    const financialGoals = financialAccountRoot.getFinancialGoals();
    expect(financialGoals).toBeExisting();
    const goalOne = await $("div=Mangoes");
    const goalTwo = await $("div=Buy a car");
    const goalThree = await $("div=Saving for the house to build");
    expect(goalOne).toBeExisting();
    expect(goalTwo).toBeExisting();
    expect(goalThree).toBeExisting();
  });
});

describe("Loads savings account", () => {
  before(async () => {
    await initialLoad(true);
  });
  it("Loads the savings financial account from goals", async () => {
    const financialAccountRoot = await utam.load(LwcFinancialAccount);
    const financialGoals = financialAccountRoot.getFinancialGoals();
    expect(financialGoals).toBeExisting();
    const viewAll = await $("a=View All");
    await viewAll.click();
    const header = await $("h1=Savings - ANZ Save Account");
    expect(header).toBeExisting();
  });
});

describe("Loads checking account", () => {
  before(async () => {
    await initialLoad(true);
  });
  it("Loads checking account from account link", async () => {
    const financialAccountRoot = await utam.load(LwcFinancialAccount);
    const everydayAccount = financialAccountRoot.getEverydayAccount();
    expect(everydayAccount).toBeExisting();
    const accountLink = await $("a=GRIMES MITCH");
    await accountLink.click();
    const header = await $("h1=Everyday - ANZ Plus Account");
    expect(header).toBeExisting();
  });
});
