import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _BaseRecordForm from "./../pageObjects/baseRecordForm";

export default class LwcDetailPanel extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getRoot(): Promise<_BaseUtamElement>;
  getBaseRecordForm(): Promise<_BaseRecordForm>;
}
