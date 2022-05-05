import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class SalesforceLogout extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  clickProfile(): Promise<void>;
  clickLogout(): Promise<void>;
  getUserProfile(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getLogoutLink(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
