import {
  By as _By,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement
} from "@utam/core";
export default class LwcLogin extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  submitForm(userName: string, passWord: string): Promise<void>;
  getLoginForm(): Promise<_BaseUtamElement>;
  getUsername(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getPassword(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getLoginButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
