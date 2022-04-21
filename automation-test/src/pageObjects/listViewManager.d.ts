import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  ContainerCtor as _ContainerCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ListViewManagerHeader from "./../pageObjects/listViewManagerHeader";

export default class ListViewManager extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getHeader(): Promise<_ListViewManagerHeader>;
  getListViewContainer<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
}
