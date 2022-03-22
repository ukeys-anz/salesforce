import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Datepicker from "./../pageObjects/datepicker";

export default class Input extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  hasLabel(): Promise<boolean>;
  hasFocus(): Promise<boolean>;
  getLabelText(): Promise<string>;
  getValueText(): Promise<string>;
  setText(text: string): Promise<void>;
  toggleCheckbox(): Promise<void>;
  getCheckedState(): Promise<string>;
  selectRadio(): Promise<void>;
  getErrorText(): Promise<string>;
  hasError(): Promise<boolean>;
  isReadonly(): Promise<string>;
  isEnabled(): Promise<boolean>;
  isSelectable(): Promise<boolean>;
  scrollToCenter(): Promise<void>;
  hasDatetimepicker(): Promise<boolean>;
  getRequired(): Promise<_BaseUtamElement>;
  getError(): Promise<_BaseUtamElement>;
  getDatepicker(): Promise<_Datepicker | null>;
}
