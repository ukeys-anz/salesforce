import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _CoachesWorkbenchAccountRecordHomeTemplateDesktop2 from "./../pageObjects/coachesWorkbenchAccountRecordHomeTemplateDesktop2";
import _LwcPersonAccountFinancialDetails from "./../pageObjects/lwcPersonAccountFinancialDetails";
import _ChatterPanel from "./../pageObjects/chatterPanel";
import _RecordPageDecorator from "./../pageObjects/recordPageDecorator";

export default class CoachesWorkbenchAccountRecordHomeFlexipage extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getRecordHomeTemplateDesktop2(): Promise<_CoachesWorkbenchAccountRecordHomeTemplateDesktop2>;
  getFinancialDetails(): Promise<_LwcPersonAccountFinancialDetails>;
  getChatterPanel(): Promise<_ChatterPanel>;
  getDecorator(): Promise<_RecordPageDecorator>;
}
