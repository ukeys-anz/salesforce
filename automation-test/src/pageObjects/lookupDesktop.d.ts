import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _GroupedCombobox from "./../pageObjects/groupedCombobox";

export default class LookupDesktop extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getGroupedCombobox(): Promise<_GroupedCombobox>;
}
