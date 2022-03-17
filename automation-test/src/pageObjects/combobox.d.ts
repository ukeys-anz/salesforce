import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _BaseCombobox from "./../pageObjects/baseCombobox";

export default class Combobox extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getLabelText(): Promise<string>;
  isRequired(): Promise<boolean>;
  getBase(): Promise<_BaseCombobox>;
}
