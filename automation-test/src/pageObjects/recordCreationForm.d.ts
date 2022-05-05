import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _RecordCreationFormField from "./../pageObjects/recordCreationFormField";
import _RecordCreationFormPicklist from "./../pageObjects/recordCreationFormPicklist";

export default class RecordCreationForm extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  selectCaseRecordType(text: string): Promise<void>;
  clickNew(): Promise<void>;
  saveNew(): Promise<void>;
  getNewButton(): Promise<(_BaseUtamElement & _ClickableUtamElement) | null>;
  getCaseRecordType(
    text: string
  ): Promise<(_BaseUtamElement & _ClickableUtamElement) | null>;
  getNextButton(): Promise<(_BaseUtamElement & _ClickableUtamElement) | null>;
  getFieldByLabel(label: string): Promise<_RecordCreationFormField | null>;
  getAllFields(): Promise<_RecordCreationFormField[] | null>;
  getPicklists(): Promise<_RecordCreationFormPicklist[]>;
  getSaveButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
