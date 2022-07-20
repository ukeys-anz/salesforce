import Survey from "../common/Survey";
import Auth from "../common/Auth";
import { UserRole } from "../constants/enums";

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
    const survey = new Survey({
      id: process.env.SURVEY_ID,
      caseId: process.env.SURVEY_CASE_ID
    });

    it("Go to Case Record Created from Survey Response", async (): Promise<void> => {
      // Login as test user
      await Auth.loginSalesforceAsRole(UserRole.Coach);

      // Open case record
      await survey.openCase(survey.caseId!);
    });

    it("Verify Case Fields", async (): Promise<void> => {
      await survey.verifyCase();
    });

    it("Verify Einstein Advocacy Rating Component on Account Page", async (): Promise<void> => {
      await survey.verifyAccount();
    });

    it("Verify Open Survey Response from Account Page", async (): Promise<void> => {
      await survey.verifySurveyResponse(survey.id!);
    });

    it("Logout", async (): Promise<void> => {
      await Auth.logoutSalesforce();
    });
  });
});
