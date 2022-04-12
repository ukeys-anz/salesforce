import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcTransactionHistoryBoard from "./../pageObjects/lwcTransactionHistoryBoard";

export default class LwcFinancialAccountParent extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getTransactionHistoryBoard(): Promise<_LwcTransactionHistoryBoard>;
}
