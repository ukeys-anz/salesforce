import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  ContainerCtor as _ContainerCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _TabBar from "./../pageObjects/tabBar";

export default class Tabset extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getActiveTabContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getTabBar(): Promise<_TabBar>;
}
