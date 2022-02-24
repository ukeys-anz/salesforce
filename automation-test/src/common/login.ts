import LwcLogin from "../pageObjects/lwcLogin";
import TwilioLogin from "../pageObjects/twilioLogin";

export default class SfLogin {
  salesForceLogin = async (role: string) => {
    //Open Url and login
    await browser.url(process.env.SALESFORCE_LOGIN_URL!);

    const loginFormRoot = await utam.load(LwcLogin);

    switch (role) {
      case "coach":
        await loginFormRoot.submitForm(
          process.env.COACH_USERNAME!,
          process.env.COACH_PASSWORD!
        );
        break;

      case "supportcoach":
        await loginFormRoot.submitForm(
          process.env.SUPPORT_COACH_USERNAME!,
          process.env.SUPPORT_COACH_PASSWORD!
        );
        break;
    }
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
