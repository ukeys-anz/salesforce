import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcTransactionHistoryRecord from "./../pageObjects/lwcTransactionHistoryRecord";

export default class LwcTransactionHistoryBoard extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getTransactionHistoryRecordByType(
    transcationType: string
  ): Promise<_LwcTransactionHistoryRecord>;
  getTransactionHistoryRecords(
    transcationType: string
  ): Promise<_LwcTransactionHistoryRecord>;
}
