import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class TwilioLogin extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getEmail(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getNext(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getPassword(): Promise<_BaseUtamElement & _EditableUtamElement>;
}
