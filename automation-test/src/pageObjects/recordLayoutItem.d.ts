import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ContainerCtor as _ContainerCtor,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";
import _Input from "./../pageObjects/input";
import _Lookup from "./../pageObjects/lookup";
import _Picklist from "./../pageObjects/picklist";
import _Datepicker from "./../pageObjects/datepicker";

export default class RecordLayoutItem extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getLabelText(): Promise<string>;
  hasLabelText(): Promise<boolean>;
  edit(): Promise<boolean>;
  getTextInput(): Promise<_Input>;
  getLookup(): Promise<_Lookup>;
  clickChangeOwnerButton(): Promise<void>;
  getPicklist(): Promise<_Picklist>;
  getStageNamePicklist(): Promise<_Picklist>;
  getDatepicker(): Promise<_Datepicker>;
  waitForOutputField(): Promise<boolean>;
  getRoot(): Promise<_BaseUtamElement>;
  getInputField<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getOutputField<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getLabel(): Promise<_BaseUtamElement>;
  getInlineEditButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
