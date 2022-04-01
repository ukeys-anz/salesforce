import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _Component2 from "./../pageObjects/component2";
import _AppNav from "./../pageObjects/appNav";
import _AppFlexipage from "./../pageObjects/appFlexipage";

export default class HomePage extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getComponent(): Promise<_Component2>;
  getNavigationBar(): Promise<_AppNav>;
  getActiveFlexiPage(): Promise<_AppFlexipage>;
}
