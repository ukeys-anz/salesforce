import SalesforceLogin from "../pageObjects/salesforceLogin";
import SalesforceLogout from "../pageObjects/salesforceLogout";
import TwilioLogin from "../pageObjects/twilioLogin";

export default class Auth {
  /**
   * @description login Salesforce as test user
   * @param role role of the test user
   */
  static loginSalesforceAsRole = async (role: string): Promise<void> => {
    if (!process.env.SALESFORCE_LOGIN_URL) {
      console.error("\nError: missing SALESFORCE_LOGIN_URL.");
      process.exit(-1);
    }

    if (!process.env.SALESFORCE_ENV_BASE) {
      console.error("Error: missing SALESFORCE_ENV_BASE.");
      process.exit(-1);
    }

    // open login url
    await browser.url(process.env.SALESFORCE_LOGIN_URL!);

    // load the page object
    const salesforceLoginRoot = await utam.load(SalesforceLogin);

    switch (role) {
      case "Coach":
        if (!process.env.COACH_USERNAME || !process.env.COACH_PASSWORD) {
          console.error(
            "Error: Trying to login as Coach but missing COACH_USERNAME or COACH_PASSWORD."
          );
          process.exit(-1);
        }

        await salesforceLoginRoot.login(
          `${process.env.COACH_USERNAME}.${process.env.SALESFORCE_ENV_BASE}`,
          process.env.COACH_PASSWORD!
        );
        break;
      case "FraudX Agent":
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
          `${process.env.FRAUDX_AGENT_USERNAME}.${process.env.SALESFORCE_ENV_BASE}`,
          process.env.FRAUDX_AGENT_PASSWORD!
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
  };

  /**
   * @description logout current test user from Salesforce
   */
  static logoutSalesforce = async (): Promise<void> => {
    // load the page object
    const salesforceLogoutRoot = await utam.load(SalesforceLogout);
    salesforceLogoutRoot.logout();
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
