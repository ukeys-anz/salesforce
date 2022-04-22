import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class LwcFinancialGoalsDetails extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getTargetValue(): Promise<_BaseUtamElement>;
  getTotalSaved(): Promise<_BaseUtamElement>;
}
