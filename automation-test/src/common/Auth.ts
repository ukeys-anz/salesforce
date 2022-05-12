import SalesforceLogin from "pageObjects/salesforceLogin";
import SalesforceLogout from "pageObjects/salesforceLogout";
import TwilioLogin from "pageObjects/twilioLogin";
import { UserRole } from "constants/enums";

export default class Auth {
  /**
   * @description login Salesforce as test user
   * @param role role of the test user
   */
  static loginSalesforceAsRole = async (role: string): Promise<void> => {
    if (!process.env.SALESFORCE_LOGIN_URL) {
      console.error("Error: missing SALESFORCE_LOGIN_URL.");
      process.exit(-1);
    }

    // open login url
    await browser.url(process.env.SALESFORCE_LOGIN_URL!);

    // load the page object
    const salesforceLoginRoot = await utam.load(SalesforceLogin);

    switch (role) {
      case UserRole.COACH:
        if (!process.env.COACH_USERNAME || !process.env.COACH_PASSWORD) {
          console.error(
            "Error: Trying to login as Coach but missing COACH_USERNAME or COACH_PASSWORD."
          );
          process.exit(-1);
        }

        await salesforceLoginRoot.login(
          process.env.COACH_USERNAME,
          process.env.COACH_PASSWORD
        );
        break;
      case UserRole.FRAUDX_AGENT:
        if (
          !process.env.FRAUDX_AGENT_USERNAME ||
          !process.env.FRAUDX_AGENT_PASSWORD
        ) {
          console.error(
            "Error: Trying to login as FraudX Agent but missing FRAUDX_AGENT_USERNAME or FRAUDX_AGENT_PASSWORD."
          );
          process.exit(-1);
        }

        await salesforceLoginRoot.login(
          process.env.FRAUDX_AGENT_USERNAME,
          process.env.FRAUDX_AGENT_PASSWORD
        );
        break;
      case UserRole.CONTENT_WRITER:
        if (
          !process.env.CONTENT_WRITER_USERNAME ||
          !process.env.CONTENT_WRITER_PASSWORD
        ) {
          console.error(
            "Error: Trying to login as Content Writer but missing CONTENT_WRITER_USERNAME or CONTENT_WRITER_PASSWORD."
          );
          process.exit(-1);
        }

        await salesforceLoginRoot.login(
          process.env.CONTENT_WRITER_USERNAME,
          process.env.CONTENT_WRITER_PASSWORD
        );
        break;
      case UserRole.QUALITY_ANALYST:
        if (
          !process.env.QUALITY_ANALYST_USERNAME ||
          !process.env.QUALITY_ANALYST_PASSWORD
        ) {
          console.error(
            "Error: Trying to login as Quality Analyst but missing QUALITY_ANALYST_USERNAME or QUALITY_ANALYST_PASSWORD."
          );
          process.exit(-1);
        }

        await salesforceLoginRoot.login(
          process.env.QUALITY_ANALYST_USERNAME,
          process.env.QUALITY_ANALYST_PASSWORD
        );
        break;
      case UserRole.COACH_LEAD:
        if (
          !process.env.COACH_LEAD_USERNAME ||
          !process.env.COACH_LEAD_PASSWORD
        ) {
          console.error(
            "Error: Trying to login as Coach Lead but missing COACH_LEAD_USERNAME or COACH_LEAD_PASSWORD."
          );
          process.exit(-1);
        }

        await salesforceLoginRoot.login(
          process.env.COACH_LEAD_USERNAME,
          process.env.COACH_LEAD_PASSWORD
        );
        break;
      default:
        console.error(
          "Error: Cannot find any matching test user's credential, exiting..."
        );
        process.exit(-1);
    }

    // wait for page fully loaded
    const domDocument = utam.getCurrentDocument();

    await domDocument.waitFor(async () =>
      (await domDocument.getUrl()).includes("/lightning")
    );

    await browser.pause(4000);
  };

  /**
   * @description logout current test user from Salesforce
   */
  static logoutSalesforce = async (): Promise<void> => {
    await browser.pause(2000);

    // load the page object
    const salesforceLogoutRoot = await utam.load(SalesforceLogout);
    await salesforceLogoutRoot.clickProfile();
    await browser.pause(3000);
    await salesforceLogoutRoot.clickLogout();

    // open login url to force logout
    await browser.url("https://test.salesforce.com");
    await browser.reloadSession();
  };

  twilioLogin = async () => {
    //Twilio Login
    const twilioPageRoot = await utam.load(TwilioLogin);

    const twilioEmailElement = await twilioPageRoot.getEmail();
    const twilioPassElement = await twilioPageRoot.getPassword();
    const twilioSubmit = await twilioPageRoot.getNext();

    await twilioEmailElement.setText(process.env.TWILIO_USERNAME!);
    await twilioSubmit.click();
    await browser.pause(2000);
    await twilioPassElement.setText(process.env.TWILIO_PASSWORD!);
    await twilioSubmit.click();
    await browser.pause(2000);
    await twilioSubmit.click();
  };
}
