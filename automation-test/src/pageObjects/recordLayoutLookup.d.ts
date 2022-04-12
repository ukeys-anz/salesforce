import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Lookup from "./../pageObjects/lookup";

export default class RecordLayoutLookup extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getLookup(): Promise<_Lookup>;
}
