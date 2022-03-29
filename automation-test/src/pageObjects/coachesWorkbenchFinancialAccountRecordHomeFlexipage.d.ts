import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _CoachesWorkbenchRecordHomeTemplateDesktop2 from "./../pageObjects/coachesWorkbenchRecordHomeTemplateDesktop2";
import _LwcFinancialAccountParent from "./../pageObjects/lwcFinancialAccountParent";
import _RecordPageDecorator from "./../pageObjects/recordPageDecorator";

export default class CoachesWorkbenchFinancialAccountRecordHomeFlexipage extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getFinancialAccountRecordPage(): Promise<_CoachesWorkbenchRecordHomeTemplateDesktop2>;
  getFinancialAccount(): Promise<_LwcFinancialAccountParent>;
  getDecorator(): Promise<_RecordPageDecorator>;
}
