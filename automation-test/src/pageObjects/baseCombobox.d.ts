import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject,
  EditableUtamElement as _EditableUtamElement
} from "@utam/core";
import _BaseComboboxItem from "./../pageObjects/baseComboboxItem";

export default class BaseCombobox extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  searchLookupAndSelect(lookupText: string): Promise<void>;
  expand(): Promise<void>;
  expandForDisabledInput(): Promise<void>;
  pickItem(indexStartingOne: number): Promise<void>;
  getRoot(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getFirstSearchedResult(): Promise<_BaseComboboxItem>;
  getGroups(): Promise<_BaseUtamElement[]>;
  getItems(): Promise<_BaseComboboxItem[]>;
  getItem(indexStartingOne: number): Promise<_BaseComboboxItem>;
  getSelectedItemInput(): Promise<_BaseUtamElement & _EditableUtamElement>;
}
