import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

export default class ChangeOwnerModal extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  searchAndSelectNewOwner(
    ownerType: string,
    searchTerm: string,
    resultTitle: string
  ): Promise<void>;
  getChangeOwnerButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getOwnerType(
    ownerType: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
