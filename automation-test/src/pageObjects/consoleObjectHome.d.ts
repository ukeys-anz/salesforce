import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _ListViewManager from "./../pageObjects/listViewManager";

export default class ConsoleObjectHome extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getRoot(): Promise<_BaseUtamElement>;
  getListView(): Promise<_ListViewManager>;
}
