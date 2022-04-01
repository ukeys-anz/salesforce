import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordLayoutRow from "./../pageObjects/recordLayoutRow";

export default class RecordLayoutSection extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  isOpen(): Promise<boolean>;
  hasTitle(): Promise<boolean>;
  toggleSectionCollapse(): Promise<boolean>;
  getRows(): Promise<_RecordLayoutRow[]>;
  getRow(indexStartingOne: number): Promise<_RecordLayoutRow>;
  getSectionTitle(): Promise<_BaseUtamElement>;
}
