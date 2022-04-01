import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _RecordHomeTemplateDesktop2 from "./../pageObjects/recordHomeTemplateDesktop2";
import _LwcHighlightsPanel from "./../pageObjects/lwcHighlightsPanel";
import _Tabset from "./../pageObjects/tabset";
import _RecordPageDecorator from "./../pageObjects/recordPageDecorator";

export default class RecordHomeFlexipage2 extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getRecordHomeTemplateDesktop2(): Promise<_RecordHomeTemplateDesktop2>;
  getHighlights(): Promise<_LwcHighlightsPanel>;
  getContactTabset(): Promise<_Tabset>;
  getDecorator(): Promise<_RecordPageDecorator>;
}
