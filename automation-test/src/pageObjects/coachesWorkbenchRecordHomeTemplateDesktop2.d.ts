import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _CoachesWorkbenchTabset2 from "./../pageObjects/coachesWorkbenchTabset2";

export default class CoachesWorkbenchRecordHomeTemplateDesktop2 extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getMainRegionTabset(): Promise<_CoachesWorkbenchTabset2>;
}
