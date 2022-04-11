import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordLayoutItem from "./../pageObjects/recordLayoutItem";

export default class RecordLayoutRow extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getItems(): Promise<_RecordLayoutItem[]>;
  getItem(indexStartingOne: number): Promise<_RecordLayoutItem>;
}
