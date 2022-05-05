import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialAccount from "./../pageObjects/lwcFinancialAccount";
import _LwcFinancialGoalsPersonAccount from "./../pageObjects/lwcFinancialGoalsPersonAccount";

export default class LwcPersonAccountFinancialDetails extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  refresh(): Promise<void>;
  getEverydayAccount(): Promise<_LwcFinancialAccount>;
  getSavingsAccount(): Promise<_LwcFinancialAccount>;
  getFinancialGoals(): Promise<_LwcFinancialGoalsPersonAccount>;
}
