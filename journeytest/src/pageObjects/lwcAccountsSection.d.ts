import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement
} from "@utam/core";
export default class LwcAccountsSection extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);

  getButtonsByText(text: string): Promise<_BaseUtamElement[]>;
}
