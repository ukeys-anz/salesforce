import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _AppNavBar from "./../pageObjects/appNavBar";

export default class AppNav extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getAppNavBar(): Promise<_AppNavBar>;
}
