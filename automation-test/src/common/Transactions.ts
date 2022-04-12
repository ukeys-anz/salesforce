import RecordPage from "pageObjects/recordPage";
import FinancialAccountTab from "pageObjects/financialAccountTab";
import * as commonUtils from "utils/commonUtils";

export default class Transactions {
  private financialAccountTab: FinancialAccountTab | null;

  constructor() {
    this.financialAccountTab = null;
  }

  async loadFinancialAccountTab(): Promise<void> {
    // load Financial Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const financialAccountRecordPage =
      await recordPageRoot.getFinancialAccountRecordPage();

    const accountTabset = await financialAccountRecordPage.getAccountTabset();
    const financialAccountTab = await commonUtils.clickTabByLabelAndGetContent(
      accountTabset,
      "Account",
      FinancialAccountTab
    );

    if (financialAccountTab instanceof FinancialAccountTab) {
      this.financialAccountTab = financialAccountTab;
    }
  }

  async verifyRecordsDisplayOrder() {
    const finAccountParent =
      await this.financialAccountTab!.getFinancialAccountParent();
    const finHistoryBoard = await finAccountParent.getTransactionHistoryBoard();
    const [finHistory1, finHistory2] =
      await finHistoryBoard.getTransactionHistoryRecordsWithDate();

    const finHistory1Date = Date.parse(await finHistory1.getTransactionDate());
    const finHistory2Date = Date.parse(await finHistory2.getTransactionDate());

    // assert first record transcation date is greater or equal to second record transcation date
    // to verify transaction history displays in chronological order
    expect(finHistory1Date).toBeGreaterThanOrEqual(finHistory2Date);
  }

  async verifySearchEndDate() {
    const finAccountParent =
      await this.financialAccountTab!.getFinancialAccountParent();
    const finHistoryBoard = await finAccountParent.getTransactionHistoryBoard();

    const endDateSearch = await finHistoryBoard.getEndDateSearch();
    // date format: dd/mm/yyyy
    const defaultEndDate = await endDateSearch.getDateText();

    // use the same logic defined in transactionHistoryBoard lwc to create default date
    // date format: yyyy-mm-dd
    const defaultDate = new Date().toISOString().slice(0, 10);
    const [year, month, day] = defaultDate.split("-");
    // convert to date format: dd/mm/yyyy
    const formattedDefaultDate = [day, month, year].join("/");

    expect(defaultEndDate).toEqual(formattedDefaultDate);
  }

  async verifyTransactionTime() {
    const finAccountParent =
      await this.financialAccountTab!.getFinancialAccountParent();
    const finHistoryBoard = await finAccountParent.getTransactionHistoryBoard();
    const finHistory = await finHistoryBoard.getTransactionHistoryRecord();
    const transactionTime = await finHistory.getTransactionTime();

    const regexp = new RegExp("^(1[0-2]|0?[1-9]):[0-5][0-9] (A|P|a|p)(M|m)");
    const isTransactionTimeFormatted = regexp.test(transactionTime);

    // assert transaction time displays in 12 Hour format
    expect(isTransactionTimeFormatted).toBeTruthy();
  }

  async verifyLoadMore() {
    const finAccountParent =
      await this.financialAccountTab!.getFinancialAccountParent();
    const finHistoryBoard = await finAccountParent.getTransactionHistoryBoard();

    const recordsBeforeLoadMore = (
      await finHistoryBoard.getTransactionHistoryRecords()
    ).length;

    // click load more button
    await finHistoryBoard.loadMore();

    const recordsAfterLoadMore = (
      await finHistoryBoard.getTransactionHistoryRecords()
    ).length;

    expect(recordsBeforeLoadMore).toBeLessThan(recordsAfterLoadMore);
  }

  async verifyDetails() {
    const finAccountParent =
      await this.financialAccountTab!.getFinancialAccountParent();
    const finHistoryBoard = await finAccountParent.getTransactionHistoryBoard();

    const finHistoryRecord =
      await finHistoryBoard.getTransactionHistoryRecord();
    await finHistoryRecord.showDetails();

    const transactionType = await finHistoryRecord.getTransactionType();
    expect(transactionType).toBeTruthy();

    const merchantName = await finHistoryRecord.getMerchantName();
    expect(merchantName).toBeTruthy();

    const convertedCurrencyCode =
      await finHistoryRecord.getConvertedCurrencyCode();
    expect(convertedCurrencyCode).toBeTruthy();

    const cardScheme = await finHistoryRecord.getCardScheme();
    expect(cardScheme).toBeTruthy();
  }
}
