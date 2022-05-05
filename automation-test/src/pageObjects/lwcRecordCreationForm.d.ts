import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _BaseRecordForm from "./../pageObjects/baseRecordForm";

export default class LwcRecordCreationForm extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getModalBaseRecordForm(): Promise<_BaseRecordForm>;
  getRelatedListBaseRecordForm(): Promise<_BaseRecordForm>;
}
