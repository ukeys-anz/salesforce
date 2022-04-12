import { TransactionType } from "constants/enums";
import FinancialAccountRecordHomeFlexipage from "pageObjects/coachesWorkbenchFinancialAccountRecordHomeFlexipage";

export default class Disputes {
  protected readonly userRole: string;
  protected readonly transactionType: TransactionType;

  constructor(userRole: string, transactionType: TransactionType) {
    this.userRole = userRole;
    this.transactionType = transactionType;
  }

  async raiseDispute(): Promise<void> {
    // load Financial Account flexi page
    const financialAccountRecordHomeFlexipageRoot = await utam.load(
      FinancialAccountRecordHomeFlexipage
    );

    // load Financial Account Parent lwc component
    const financialAccount = await financialAccountRecordHomeFlexipageRoot.getFinancialAccount();

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
