import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class ObjectHome extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  searchListView(listViewName: string): Promise<void>;
  openListView(): Promise<void>;
  getListViews(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
}
