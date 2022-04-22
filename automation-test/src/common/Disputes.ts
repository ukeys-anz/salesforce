import { TransactionType } from "constants/enums";
import RecordPage from "pageObjects/recordPage";
import FinancialAccountTab from "pageObjects/financialAccountTab";
import * as commonUtils from "utils/commonUtils";

export default class Disputes {
  protected readonly userRole: string;
  protected readonly transactionType: TransactionType;

  constructor(userRole: string, transactionType: TransactionType) {
    this.userRole = userRole;
    this.transactionType = transactionType;
  }

  async raiseDispute(): Promise<void> {
    // load Financial Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const financialAccountRecordPage =
      await recordPageRoot.getFinancialAccountRecordPage();

    const accountTabset = await financialAccountRecordPage.getAccountTabset();
    const accountTab = await commonUtils.clickTabByLabelAndGetContent(
      accountTabset,
      "Account",
      FinancialAccountTab
    );

    if (accountTab instanceof FinancialAccountTab) {
      // get Financial Account Parent lwc component
      const financialAccount = await accountTab.getFinancialAccountParent();

      // load Transaction History Board lwc component
      const board = await financialAccount.getTransactionHistoryBoard();

      // get a transaction history record of type
      const record = await board.getTransactionHistoryRecordOfType(
        this.transactionType
      );

      // click Raise Dispute button
      await record.raiseDispute();

      // wait window load case creation form
      await browser.pause(2000);
    }
  }
}
