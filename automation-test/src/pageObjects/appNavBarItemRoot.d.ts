import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class AppNavBarItemRoot extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getItemText(): Promise<string>;
  clickAndWaitForUrl(url: string): Promise<boolean>;
  getRoot(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getItemLink(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
