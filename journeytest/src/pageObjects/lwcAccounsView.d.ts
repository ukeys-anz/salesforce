import {
  By as _By,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement,
  EditableUtamElement as _EditableUtamElement,
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement
} from "@utam/core";
export default class LwcAccounsView extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);

  getSelectAccountFiler(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getInputAccountName(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getRefreshAccount(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getSelectElements(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
  getListView(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getAccountItem(
    accname: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
