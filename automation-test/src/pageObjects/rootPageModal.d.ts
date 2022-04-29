import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class RootPageModal extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  userHasNoPermissionToDeleteChatterPost(): Promise<boolean>;
  getDeleteButton(): Promise<(_BaseUtamElement & _ClickableUtamElement) | null>;
  getModalDetail(): Promise<_BaseUtamElement | null>;
}
