import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _AppNavBarItemRoot from "./../pageObjects/appNavBarItemRoot";

export default class AppNavBar extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getNavItem(text: string): Promise<_AppNavBarItemRoot>;
}
