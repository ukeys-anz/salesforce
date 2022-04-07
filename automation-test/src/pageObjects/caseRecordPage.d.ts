import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcHighlightsPanel from "./../pageObjects/lwcHighlightsPanel";
import _Tabset2 from "./../pageObjects/tabset2";

export default class CaseRecordPage extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getHighlights(): Promise<_LwcHighlightsPanel>;
  getDetailsTabset(): Promise<_Tabset2>;
  getCaseNotesTabset(): Promise<_Tabset2>;
  getChatsTabset(): Promise<_Tabset2>;
  getKnowledgeTabset(): Promise<_Tabset2>;
}
