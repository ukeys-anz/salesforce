import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _RecordHomeTemplateDesktop2 from "./../pageObjects/recordHomeTemplateDesktop2";
import _Tabset from "./../pageObjects/tabset";
import _RecordPageDecorator from "./../pageObjects/recordPageDecorator";

export default class CoachesWorkbenchFinancialAccountRecordHomeFlexipage extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getFinancialAccountRecordPage(): Promise<_RecordHomeTemplateDesktop2>;
  getFinancialAccountTabset(): Promise<_Tabset>;
  getDecorator(): Promise<_RecordPageDecorator>;
}
