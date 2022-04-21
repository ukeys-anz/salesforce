import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _BaseCombobox from "./../pageObjects/baseCombobox";

export default class GroupedCombobox extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getBaseCombobox(): Promise<_BaseCombobox>;
}
