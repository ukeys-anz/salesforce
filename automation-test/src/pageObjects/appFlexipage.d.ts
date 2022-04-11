import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Component2 from "./../pageObjects/component2";

export default class AppFlexipage extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  waitForLoad(): Promise<this>;
  getFlexipageComponent2(): Promise<_Component2>;
}
