import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionsRibbon from "./../pageObjects/actionsRibbon";
import _LwcRecordLayout from "./../pageObjects/lwcRecordLayout";

export default class LwcHighlightsPanel extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getActions(): Promise<_ActionsRibbon>;
  getRecordLayout(): Promise<_LwcRecordLayout>;
}
