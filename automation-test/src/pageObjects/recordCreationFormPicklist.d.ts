import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordCreationFormPicklistOption from "./../pageObjects/recordCreationFormPicklistOption";

export default class RecordCreationFormPicklist extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  selectOptionByIndex(ptionIndex: number): Promise<void>;
  getOptionByIndex(
    ptionIndex: number
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getOptionByTitle(
    optionTitle: string
  ): Promise<_RecordCreationFormPicklistOption | null>;
}
