import Auth from "../../common/Auth";
import { UserRole, Access, TransactionType } from "../../constants/enums";
import UAM from "../../common/UAM";
import { App } from "../../constants/appsDefinition";
import accountData from "../../data/accountData";
import { ReportAction, HasReportActionAccess } from "../../common/UAM";

describe("AR-13398: Salesforce UAM: AR-13404: FraudX Agent UAM", () => {
  const fraudXAgentUAM = new UAM(UserRole.FraudX_Agent);

  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();

    // login as test user
    await Auth.loginSalesforceAsRole(fraudXAgentUAM.userRole);
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  it("FraudX Agent cannot access Content Workbench", async (): Promise<void> => {
    await fraudXAgentUAM.verifyAppAccess(false, App.Content_Workbench);
  });

  it("FraudX Agent can raise a dispute (Deposit Withdrawal)", async (): Promise<void> => {
    await fraudXAgentUAM.verifyRaiseDispute(
      true,
      accountData.savingsAccountNumber,
      TransactionType.Deposit_Withdrawal
    );
  });

  it("FraudX Agent can edit existing Dispute case", async (): Promise<void> => {
    await fraudXAgentUAM.verifyCaseAccess(Access.Edit, "All Dispute Cases");
  });

  it("FraudX Agent cannot edit customer detail", async (): Promise<void> => {
    await fraudXAgentUAM.verifyAccountAccess(
      Access.Read_Only,
      accountData.ocvId
    );
  });

  it("FraudX Agent cannot edit financial account", async (): Promise<void> => {
    await fraudXAgentUAM.verifyFinancialAccountAccess(
      Access.Read_Only,
      accountData.checkAccountNumber
    );
  });

  it("FraudX Agent cannot create Knowledge article in Coaches Workbench", async (): Promise<void> => {
    await fraudXAgentUAM.verifyKnowledgeCreateAccess(false);
  });

  it("FraudX Agent cannot edit Knowledge article in Coaches Workbench", async (): Promise<void> => {
    await fraudXAgentUAM.verifyKnowledgeAccess(Access.Read_Only);
  });

  it("FraudX Agent cannot create report", async (): Promise<void> => {
    await fraudXAgentUAM.verifyReportAccess(Access.Read_Only);
  });

  it("FraudX Agent cannot export report", async (): Promise<void> => {
    const actionsToCheck: Map<ReportAction, HasReportActionAccess> = new Map([
      ["Export", false]
    ]);
    await fraudXAgentUAM.verifyReportActionsAccess(actionsToCheck);
  });

  it("FraudX Agent can open and view Apps and Reports in Analytics Studio", async (): Promise<void> => {
    const appsToCheck = ["FraudX"];
    const reportsToCheck = [
      "Fraud Daily Statistics",
      "FraudX Scam Dashboard",
      "FraudX Operational Management"
    ];

    await fraudXAgentUAM.verifyAnalyticsAppsAndReportsAccess(
      appsToCheck,
      reportsToCheck
    );
  });

  after(async (): Promise<void> => {
    // log out test user
    await Auth.logoutSalesforce();
  });
});
