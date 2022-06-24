import Survey from "../common/Survey";
import Auth from "../common/Auth";
import { UserRole } from "../constants/enums";
import { APIResult } from "../types/survey";
import { cleanupTestData } from "../utils/wdioUtils";

describe("AR-11402: Salesforce NPS", async (): Promise<void> => {
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

  describe("AR-13669: Create Survey Response and Automatic Case Creation", async (): Promise<void> => {
    const survey = new Survey();
    let apiResult: APIResult | void;

    it("Create Survey Record through API", async (): Promise<void> => {
      apiResult = await survey.createSurveyResponse()!;
    });

    it("Go to Auto Created Case", async (): Promise<void> => {
      // Login as test user
      await Auth.loginSalesforceAsRole(UserRole.Coach);

      // Open case record
      await survey.openCase(apiResult!.CaseId);
    });

    it("Verify Case Fields", async (): Promise<void> => {
      // Verify case fields
      await survey.verifyCase();
    });

    it("Verify Einstein Advocacy Rating Component on Account Page", async (): Promise<void> => {
      await survey.verifyAccount();
    });

    it("Verify Open Survey Response from Account Page", async (): Promise<void> => {
      await survey.verifySurveyResponse(apiResult!.SurveyResId);
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });

  after(async (): Promise<void> => {
    await cleanupTestData(UserRole.Qualtrics_Automation_User, [
      "Case",
      "qualtrics__Survey_Response__c"
    ]);
  });
});
