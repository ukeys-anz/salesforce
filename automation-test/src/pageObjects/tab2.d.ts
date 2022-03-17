import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcDetailPanel from "./../pageObjects/lwcDetailPanel";

export default class Tab2 extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getDetailPanel(): Promise<_LwcDetailPanel>;
}
