import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcPersonAccountFinancialDetails from "./../pageObjects/lwcPersonAccountFinancialDetails";
import _LwcViewCards from "./../pageObjects/lwcViewCards";
import _LstRelatedListSingleContainer from "./../pageObjects/lstRelatedListSingleContainer";
import _ChatterPanel from "./../pageObjects/chatterPanel";

export default class AccountRecordPage extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getPersonAccountFinancialDetails(): Promise<_LwcPersonAccountFinancialDetails>;
  getViewCards(): Promise<_LwcViewCards>;
  getCaseRelatedList(): Promise<_LstRelatedListSingleContainer>;
  getQualityAssessmentsRelatedList(): Promise<_LstRelatedListSingleContainer>;
  getChatterPanel(): Promise<_ChatterPanel>;
}
