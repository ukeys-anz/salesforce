export default class SfTransactions {
  regExp: any;
  currRegExp: any;
  numRegExp: any;

  constructor() {
    this.regExp = new RegExp("^[ A-Za-z0-9_@.$:/&,+-]*$");
    this.currRegExp = new RegExp("^$[0-9]+(.[0-9][0-9])?$");
    this.numRegExp = new RegExp("/^d+$/");
  }

  getFirstTransactionRowNumber = async (type: string) => {
    let rowNumber;
    let trxs;
    let trxType;
    const loadMore = await $(
      "//button[@c-transactionhistoryboard_transactionhistoryboard and text()='Load More']"
    );
    rowNumber = 1;
    do {
      trxType = await $(
        `(//article[contains(@class,'transaction-item')]//div[text()='Transaction Type']/following-sibling::div)[${rowNumber}]`
      );
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
    return;
  };

  viewTransactionDetails = async (type: string) => {
    const rowNumber = await this.getFirstTransactionRowNumber(type);

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
    // let rowNumber: any;

    //Open transaction
    const rowNumber: any = await this.viewTransactionDetails(type);

    //transaction details
    await this.verifyTrxDetails(rowNumber, type);

    //Merchant Details
    await this.verifyMerchantDetails(rowNumber);

    //International Exchange details
    await this.verifyIntlExchDetails(rowNumber);

    //Card details
    if (type == "Card") {
      await this.verifyCardDetails(rowNumber);
    }
  };

  verifyTrxDetails = async (rowNumber: number, type: string) => {
    // let trxName, trxType, shrtDesc, status, lngDesc, amount, trxTime, trxId;

    const trxName = await $(
      `(//article[contains(@class,'transaction-item')]//div[text()='Name']/following-sibling::div)[${rowNumber}]`
    );
    const trxType = await $(
      `(//article[contains(@class,'transaction-item')]//div[text()='Transaction Type']/following-sibling::div)[${rowNumber}]`
    );

    //Shop Name
    await expect(await this.regExp.test(await trxName.getText())).toBe(true);

    //Transaction Type
    await expect(await trxType.getText()).toBe(type);

    //Transaction time
    const trxTime = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${rowNumber}]//div[text()='Transaction Time']/following-sibling::div`
    );
    await expect(await this.regExp.test(await trxTime.getText())).toBe(true);

    //Short Desc
    const shrtDesc = await $(
      `(//article[contains(@class,'transaction-item')]//div[text()='Short Description']/following-sibling::div)[${rowNumber}]`
    );
    await expect(await this.regExp.test(await shrtDesc.getText())).toBe(true);

    //Amount
    const amount = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${rowNumber}]//div[text()='Amount']/following-sibling::div`
    );

    await expect(await this.regExp.test(await amount.getText())).toBe(true);

    //Status
    const status = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 1
      }]//div[text()='Status']/following-sibling::div`
    );
    await expect(await this.regExp.test(await status.getText())).toBe(true);

    //Long Description
    const lngDesc = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 1
      }]//div[text()='Status']/following-sibling::div`
    );
    await expect(await this.regExp.test(await lngDesc.getText())).toBe(true);

    //Transaction ID
    const trxId = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 1
      }]//div[text()='Transaction ID']/following-sibling::div`
    );
    await expect(await this.regExp.test(await trxId.getText())).toBe(true);

    //Currency Code
    const currCode = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 1
      }]//div[text()='Currency Code']/following-sibling::div`
    );
    await expect(await currCode.getText()).toBe("AUD");
  };

  verifyMerchantDetails = async (rowNumber: number) => {
    // let emailRegExp = new RegExp(
    //   '/^(([^<>()[]\\.,;:s@"]+(.[^<>()[]\\.,;:s@"]+)*)|(".+"))@(([[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}])|(([a-zA-Z-0-9]+.)+[a-zA-Z]{2,}))$/'
    // );
    const webRegExp = new RegExp(
      "(http|ftp|https)://[w-]+(.[w-]+)+([w.,@?^=%&amp;:/~+#-]*[w@?^=%&amp;/~+#-])?"
    );

    //Name
    const merchName = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 2
      }]//div[text()='Name']/following-sibling::div`
    );
    await expect(await this.regExp.test(await merchName.getText())).toBe(true);

    //Address
    const merchAddress = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 2
      }]//div[text()='Address']/following-sibling::div`
    );
    await expect(await this.regExp.test(await merchAddress.getText())).toBe(
      true
    );

    //Phone
    const phNumber = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 2
      }]//div[text()='Phone']/following-sibling::div`
    );
    await expect(await this.regExp.test(await phNumber.getText())).toBe(true);

    //Website
    const website = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 2
      }]//div[text()='Website']/following-sibling::div`
    );
    await expect(await webRegExp.test(await website.getText())).toBe(true);

    //Email
    const emailEle = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 2
      }]//div[text()='Email']/following-sibling::div`
    );
    await console.log(await emailEle.getText());
    await expect(await this.regExp.test(await emailEle.getText())).toBe(true);
  };

  verifyIntlExchDetails = async (rowNumber: number) => {
    //Converted Amount
    const convAm = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 3
      }]//div[text()='Converted Amount']/following-sibling::div`
    );
    await expect(await this.regExp.test(await convAm.getText())).toBe(true);

    //Converted Currency Code
    const currCode = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 3
      }]//div[text()='Converted Currency Code']/following-sibling::div`
    );
    await expect(await this.regExp.test(await currCode.getText())).toBe(true);

    //Exchange Rate
    const exhRate = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 3
      }]//div[text()='Exchange Rate']/following-sibling::div`
    );
    await expect(await this.regExp.test(await exhRate.getText())).toBe(true);
  };

  verifyCardDetails = async (rowNumber: number) => {
    //Card Scheme
    const crdScheme = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 4
      }]//div[text()='Card Scheme']/following-sibling::div`
    );
    await expect(await this.regExp.test(await crdScheme.getText())).toBe(true);

    //Last 4 digits
    // let fourDigRegEx = new RegExp("/^[0-9]{4}$/");
    const lastDigits = await $(
      `(//article[contains(@class,'transaction-item')]/div)[${
        rowNumber + 4
      }]//div[text()='Card Last 4 Digits']/following-sibling::div`
    );
    await expect(await this.regExp.test(await lastDigits.getText())).toBe(true);
  };
}
