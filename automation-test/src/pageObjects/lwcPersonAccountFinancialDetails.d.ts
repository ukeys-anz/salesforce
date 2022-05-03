import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialGoalsPersonAccount from "./../pageObjects/lwcFinancialGoalsPersonAccount";

export default class LwcPersonAccountFinancialDetails extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getFinancialGoals(): Promise<_LwcFinancialGoalsPersonAccount>;
}
