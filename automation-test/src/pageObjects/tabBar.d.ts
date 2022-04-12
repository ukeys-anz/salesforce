import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class TabBar extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getActiveTabText(): Promise<string>;
  clickTab(label: string): Promise<void>;
  getTabByLabel(
    label: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getTabs(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
}
