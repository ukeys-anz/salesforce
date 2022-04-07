import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ChatterPanel from "./../pageObjects/chatterPanel";

export default class CaseNotesTab extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getChatterPanel(): Promise<_ChatterPanel>;
}
