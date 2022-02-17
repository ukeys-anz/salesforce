import { jsonObject } from "expect-webdriverio";

export default class SfTransactions {
  getFirstTransactionRowNumber = async (type: string) => {
    let rowNumber;
    let trxs;
    let trxType;
    const loadMore = await $(
      "//button[@c-transactionhistoryboard_transactionhistoryboard and text()='Load More']"
    );
    rowNumber = 1;
    do {
      await console.log(await rowNumber);
      trxType = await $(
        `(//article[contains(@class,'transaction-item')]//div[text()='Transaction Type']/following-sibling::div)[${rowNumber}]`
      );
      await console.log(await trxType.getText());
      trxs = await $$("//article[contains(@class,'transaction-item')]");

      if ((await trxs.length) == rowNumber && (await loadMore.isExisting())) {
        await loadMore.click();
        await browser.pause(2000);
      }

      if ((await trxType.getText()) == type) {
        return rowNumber;
      }
      rowNumber++;
    } while ((await trxType.getText()) != type);
  };

  viewTransactionDetails = async (type: string) => {
    let rowNumber = await this.getFirstTransactionRowNumber(type);

    const transactionItem = await $(
      `(//article[contains(@class,'transaction-item')]//button)[${rowNumber}]`
    );
    await transactionItem.click();

    const menuItem = await $("//a/span[text()='Show Details']");
    await menuItem.click();
    await browser.pause(5000);
    return rowNumber;
  };

  verifyTransactions = async (type: string) => {
    let rowNumber: any;

    //Open transaction
    rowNumber = await this.viewTransactionDetails(type);

    //transaction details
    await this.verifyTrxDetails(rowNumber, type);

    //Merchant Details
    await this.verifyMerchantDetails();

    //International Exchange details
    await this.verifyIntlExchDetails();

    //Card details
    if (type == "Card") {
      await this.verifyCardDetails();
    }

    //Tags
    await this.verifyTags();

    //Map
    await this.verifyMap();
  };

  verifyTrxDetails = async (rowNumber: number, type: string) => {
    let trxName, trxType;

    trxName = await $(
      `(//article[contains(@class,'transaction-item')]//div[text()='Name']/following-sibling::div)[${rowNumber}]`
    );
    trxType = await $(
      `(//article[contains(@class,'transaction-item')]//div[text()='Transaction Type']/following-sibling::div)[${rowNumber}]`
    );

    //Shop Name
    let regexp = new RegExp('[w~@#$%^&*+=`|{}:;!.?"()[]-]{0,100}');
    await expect(await regexp.test(await trxName.getText())).toBe(true);

    //Transaction Type
    await expect(await regexp.test(await trxType.getText())).toBe(type);

    //Transaction time

    //Short Desc

    //Amount

    //Status

    //Long Description

    //Transaction ID

    //Error Reason

    //Currency Code
  };

  verifyMerchantDetails = async () => {
    //Name
    //Address
    //Phone
    //Website
    //Email
  };

  verifyIntlExchDetails = async () => {
    //Converted Amount
    //Coverted Currency Code
    //Exchange Rate
  };

  verifyCardDetails = async () => {
    //Card Scheme
    //Last 4 digits
  };

  verifyTags = async () => {
    //Tags
  };

  verifyMap = async () => {};
}
