import LwcFinancialAccount from "pageObjects/lwcFinancialAccount";
import RecordPage from "pageObjects/recordPage";

type FinancialAccountType = "Everyday" | "Savings";

export default class FinancialAccount {
  type: FinancialAccountType;
  financialAccount: LwcFinancialAccount | undefined;

  constructor(type: FinancialAccountType) {
    this.type = type;
    this.financialAccount = undefined;
  }

  async load(): Promise<void> {
    // load Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();

    // get Person Account Financial Details lwc component
    const financialDetails =
      await accountRecordPage.getPersonAccountFinancialDetails();

    if (this.type === "Everyday") {
      this.financialAccount = await financialDetails.getEverydayAccount();
    } else if (this.type === "Savings") {
      this.financialAccount = await financialDetails.getSavingsAccount();
    }
  }

  async verifyDetails() {
    // verify Last Updated timestamp is correct
    const lastUpdatedTime = await this.financialAccount!.getLastUpdatedTime();
    this.verifyFinancialAccountTimestamp(lastUpdatedTime!);

    // // verify balance is visible
    const balance = await this.financialAccount!.getBalance();
    expect(balance).toBeTruthy();
  }

  getLastUpdatedTime(): string {
    // same string formatting logic as in Financial Accountlwc component
    const nowTime = new Date();

    const lastUpdated =
      "Last Updated " +
      nowTime.getDate() +
      " " +
      nowTime.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      nowTime.getFullYear() +
      " | " +
      nowTime.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });

    return lastUpdated;
  }

  verifyFinancialAccountTimestamp(lastUpdatedTime: string): void {
    // there are 1/60 chance in which execution time passed current min and UI stays in last min
    // for example:
    // Expected: "Last Updated 26 April 2022 | 2:32 pm"
    // Received: "Last Updated 26 April 2022 | 2:31 pm"
    // only verify substring like "Last Updated 26 April 2022 | 2:3" and "pm"  to get across above issue
    const expectedTimestamp = this.getLastUpdatedTime();

    expect(lastUpdatedTime.substring(0, lastUpdatedTime.length - 4)).toEqual(
      expectedTimestamp.substring(0, lastUpdatedTime.length - 4)
    );

    expect(lastUpdatedTime.substring(lastUpdatedTime.length - 2)).toEqual(
      expectedTimestamp.substring(lastUpdatedTime.length - 2)
    );
  }
}
