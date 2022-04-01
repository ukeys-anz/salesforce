import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _BaseCombobox from "./../pageObjects/baseCombobox";
import _LookupDesktop from "./../pageObjects/lookupDesktop";

export default class Lookup extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getBaseCombobox(): Promise<_BaseCombobox>;
  getLookupDesktop(): Promise<_LookupDesktop>;
}
