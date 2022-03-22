import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Picklist from "./../pageObjects/picklist";
import _FormPicklist from "./../pageObjects/formPicklist";

export default class RecordPicklist extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getBasePicklist(): Promise<_Picklist>;
  getFormPicklist(): Promise<_FormPicklist>;
}
