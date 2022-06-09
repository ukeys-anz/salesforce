import Auth from "../common/Auth";
import { UserRole } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import Knowledge from "../common/Knowledge";

describe("AR-4502: Knowledge & Release Notes", () => {
  // pre test steps
  before(async (): Promise<void> => {
    // max viewport
    await browser.maximizeWindow();
  });

  beforeEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  afterEach(async (): Promise<void> => {
    await browser.takeScreenshot();
    await browser.pause(500);
  });

  describe("AR-10345: Content Writer creates, edits, and publishes an article", async (): Promise<void> => {
    const knowledge = new Knowledge();

    it("Login as Content Writer", async (): Promise<void> => {
      await Auth.loginSalesforceAsRole(UserRole.Content_Writer);
    });

    it("Go to Content Workbench and Knowledge tab", async (): Promise<void> => {
      await navigateToAppAndTab(App.Content_Workbench, AppTab.Knowledge);
    });

    it("Create New Article", async (): Promise<void> => {
      await knowledge.create();
    });

    it("Submit Article for Approval", async (): Promise<void> => {
      await knowledge.submit();
    });

    it("Verify Approval History", async (): Promise<void> => {
      await knowledge.verifyApprovalHistory();
    });

    it("Approve Article", async (): Promise<void> => {
      await knowledge.approve();
    });

    it("Publish Article", async (): Promise<void> => {
      await knowledge.publish();
    });

    it("Edit Article as Draft", async (): Promise<void> => {
      await knowledge.editDraft();
    });

    it("Publish New Version", async (): Promise<void> => {
      await knowledge.publish();
    });

    it("Logout as Content Writer", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });
});
