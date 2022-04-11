import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Datepicker from "./../pageObjects/datepicker";
import _LwcTransactionHistoryRecord from "./../pageObjects/lwcTransactionHistoryRecord";

export default class LwcTransactionHistoryBoard extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getEndDateSearch(): Promise<_Datepicker>;
  getTransactionHistoryRecordOfType(
    transactionType: string
  ): Promise<_LwcTransactionHistoryRecord>;
  getTransactionHistoryRecordsWithDate(): Promise<
    _LwcTransactionHistoryRecord[]
  >;
  getTransactionHistoryRecord(): Promise<_LwcTransactionHistoryRecord>;
}
