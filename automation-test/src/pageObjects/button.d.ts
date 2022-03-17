import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class Button extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  click(): Promise<void>;
  getButtonName(): Promise<string>;
  getClassAttr(): Promise<string>;
  isDisabled(): Promise<string>;
}
