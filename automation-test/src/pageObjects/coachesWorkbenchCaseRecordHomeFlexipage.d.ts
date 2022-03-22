import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _CoachesWorkbenchCaseRecordHomeTemplateDesktop2 from "./../pageObjects/coachesWorkbenchCaseRecordHomeTemplateDesktop2";
import _LwcDetailPanel from "./../pageObjects/lwcDetailPanel";
import _RecordPageDecorator from "./../pageObjects/recordPageDecorator";

export default class CoachesWorkbenchCaseRecordHomeFlexipage extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getCaseRecordPage(): Promise<_CoachesWorkbenchCaseRecordHomeTemplateDesktop2>;
  getMainRegionActiveTabDetailPanel(): Promise<_LwcDetailPanel>;
  getDecorator(): Promise<_RecordPageDecorator>;
}
