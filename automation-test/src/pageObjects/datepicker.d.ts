import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class Datepicker extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getLabelText(): Promise<string>;
  isRequired(): Promise<boolean>;
  setDateText(text: string): Promise<void>;
  getDateText(): Promise<string>;
  clearDateText(): Promise<void>;
}
