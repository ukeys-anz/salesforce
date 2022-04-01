import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Component2 from "./../pageObjects/component2";

export default class CoachesWorkbenchCaseTabset2 extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getDetailComponent(): Promise<_Component2>;
}
