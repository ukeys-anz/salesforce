import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _CoachesWorkbenchCaseTabset2 from "./../pageObjects/coachesWorkbenchCaseTabset2";

export default class CoachesWorkbenchCaseRecordHomeTemplateDesktop2 extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getMainRegionTabset(): Promise<_CoachesWorkbenchCaseTabset2>;
}
