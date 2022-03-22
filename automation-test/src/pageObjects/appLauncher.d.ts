import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

export default class AppLauncher extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  isCurrentApp(appName: string): Promise<boolean>;
  redirectToApp(appName: string): Promise<void>;
  getAppLauncher(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getSearchInput(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getSearchItemLink(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getCurrentApp(): Promise<_BaseUtamElement>;
}
