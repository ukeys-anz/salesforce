import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class LwcTransactionHistoryRecord extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getTransactionType(): Promise<string>;
  getTransactionTime(): Promise<string>;
  getTransactionDateInput(): Promise<_BaseUtamElement>;
  getTransactionDate(): Promise<string>;
  raiseDispute(): Promise<void>;
}
