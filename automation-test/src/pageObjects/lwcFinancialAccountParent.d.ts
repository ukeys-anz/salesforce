import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialGoals from "./../pageObjects/lwcFinancialGoals";
import _LwcTransactionHistoryBoard from "./../pageObjects/lwcTransactionHistoryBoard";

export default class LwcFinancialAccountParent extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getFinancialGoals(): Promise<_LwcFinancialGoals>;
  getTransactionHistoryBoard(): Promise<_LwcTransactionHistoryBoard>;
}
