import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _ConsoleTabBarItem from "./../pageObjects/consoleTabBarItem";

export default class ConsoleAppNavigation extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  redirectToTab(menuItem: string): Promise<void>;
  isCurrentTab(tabName: string): Promise<boolean>;
  redirectToCurrentTabHome(): Promise<void>;
  getTabBarItems(): Promise<_ConsoleTabBarItem[] | null>;
  getCurrentTab(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
