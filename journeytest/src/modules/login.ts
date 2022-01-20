import LwcLogin from "../pageObjects/lwcLogin";
import lwcLoginPage from "../pageObjects/lwcLoginPage";
import TwilioLogin from "../pageObjects/twilioLogin";
import data from "../../testdata.json";

export default class SfLogin {
  salesForceLogin = async (env: string, role: string) => {
    require("dotenv").config();

    await browser.url(process.env.TESTURL || "defaultString");

    const loginFormRoot = await utam.load(LwcLogin);

    await loginFormRoot.submitForm(
      process.env.USERNAME || "defaultString",
      process.env.PASSWORD || "defaultString"
    );
  };

  twilioLogin = async () => {
    //Twilio Login
    const twilioPageRoot = await utam.load(TwilioLogin);

    const twilioEmailElement = await twilioPageRoot.getEmail();
    const twilioPassElement = await twilioPageRoot.getPassword();
    const twilioSubmit = await twilioPageRoot.getNext();

    await twilioEmailElement.setText(data.twilio[0].user);
    await twilioSubmit.click();
    await browser.pause(2000);
    await twilioPassElement.setText(data.twilio[0].pwd);
    await twilioSubmit.click();
    await browser.pause(2000);
    await twilioSubmit.click();
  };
}
