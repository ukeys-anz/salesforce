import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcPersonAccountFinancialDetails from "./../pageObjects/lwcPersonAccountFinancialDetails";
import _ChatterPanel from "./../pageObjects/chatterPanel";

export default class CoachesWorkbenchAccountRecordHomeTemplateDesktop2 extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getFinancialDetails(): Promise<_LwcPersonAccountFinancialDetails>;
  getChatterPanel(): Promise<_ChatterPanel>;
}
