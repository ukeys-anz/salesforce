import { ScenarioUtil } from "../utilities/scenarioUtil";

export default class SfCards {
  getCardDetails = async () => {
    // const customerPageRoot = await utam.load(LwcCustomerDetails);
    // const getCardDetailsElement = await customerPageRoot.getCardDetailButton();
    // await getCardDetailsElement[0].click();

    const getCardDetailsElement = await $(
      "//lightning-button[@data-id='get-cards-button']"
    );
    await getCardDetailsElement.scrollIntoView();
    await getCardDetailsElement.click();
    await browser.pause(6000);
  };

  verifyCardDetails = async (scenarioId: string) => {
    // const scenarioUt = new ScenarioUt();
    let cardDetails: any = {};
    cardDetails = await ScenarioUtil.getCardDetails(scenarioId);

    //Card Holder
    let cardHolderSection =
      "//article[@class='card-container']//div/p[text()='Cardholder']/following-sibling::p";
    await expect(await $$(cardHolderSection)).toHaveText(
      cardDetails.cardHolder
    );

    //Number
    let numberSection =
      "//article[@class='card-container']//div/p[text()='Last 4 Digits']/following-sibling::p";
    await expect(await $$(numberSection)).toHaveText(cardDetails.number);

    //Expiry
    let expirySection =
      "//article[@class='card-container']//div/p[text()='Expiry Date']/following-sibling::p";
    await expect(await $$(expirySection)).toHaveText(cardDetails.expiry);

    //Status
    let statusSection =
      "//article[@class='card-container']//div/p[text()='Status']/following-sibling::p";
    await expect(await $$(statusSection)).toHaveText(cardDetails.status);
  };
}
