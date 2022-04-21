import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Picklist from "./../pageObjects/picklist";
import _Button from "./../pageObjects/button";

export default class FormPicklist extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getPicklist(): Promise<_Picklist>;
  getEditDependencyPanel(): Promise<_Button>;
}
