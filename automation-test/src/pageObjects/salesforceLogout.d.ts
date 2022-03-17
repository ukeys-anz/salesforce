import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

export default class SalesforceLogout extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  logout(): Promise<void>;
}
