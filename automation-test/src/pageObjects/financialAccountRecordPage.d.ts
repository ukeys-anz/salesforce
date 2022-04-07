import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Tabset2 from "./../pageObjects/tabset2";

export default class FinancialAccountRecordPage extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getAccountTabset(): Promise<_Tabset2>;
}
