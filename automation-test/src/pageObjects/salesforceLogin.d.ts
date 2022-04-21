import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class SalesforceLogin extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  login(username: string, password: string): Promise<void>;
  getUsername(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getPassword(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getLoginButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
