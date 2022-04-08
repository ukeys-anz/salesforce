import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialAccountParent from "./../pageObjects/lwcFinancialAccountParent";

export default class FinancialAccountTab extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getFinancialAccountParent(): Promise<_LwcFinancialAccountParent>;
}
