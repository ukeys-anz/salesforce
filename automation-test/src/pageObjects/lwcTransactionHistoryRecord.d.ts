import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class LwcTransactionHistoryRecord extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getTransactionType(): Promise<string>;
  raiseDispute(): Promise<void>;
}
