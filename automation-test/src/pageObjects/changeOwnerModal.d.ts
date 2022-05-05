import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class ChangeOwnerModal extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  clickOwnerTypeDropDown(): Promise<void>;
  selectOwnerType(ownerType: string): Promise<void>;
  clickSearchBox(): Promise<void>;
  search(username: string): Promise<void>;
  selectUser(resultTitle: string): Promise<void>;
  save(): Promise<void>;
  getChangeOwnerButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getOwnerType(
    ownerType: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
