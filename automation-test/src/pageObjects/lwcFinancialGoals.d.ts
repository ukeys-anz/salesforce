import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialGoalsDetails from "./../pageObjects/lwcFinancialGoalsDetails";

export default class LwcFinancialGoals extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getGoals(): Promise<_LwcFinancialGoalsDetails[]>;
}
