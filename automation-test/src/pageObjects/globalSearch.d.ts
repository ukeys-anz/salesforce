import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";
import _Input from "./../pageObjects/input";

export default class GlobalSearch extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  searchAndRedirectToRecord(
    searchTerm: string,
    resultIndex: number
  ): Promise<void>;
  getGlobalSearchButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getLightningInput(): Promise<_Input>;
}
