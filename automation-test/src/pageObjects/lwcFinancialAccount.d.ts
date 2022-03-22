import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

export default class LwcFinancialAccount extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getEverydayAccount(): Promise<_BaseUtamElement>;
  getSavingsAccount(): Promise<_BaseUtamElement>;
  getFinancialGoals(): Promise<_BaseUtamElement>;
  getTotalBalance(): Promise<_BaseUtamElement>;
}
