import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  ActionableUtamElement as _ActionableUtamElement
} from "@utam/core";

export default class LwcCustomerDetails extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getSearchBox(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getNavigationShow(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getMenuSelect(
    menuItem: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getHomeSearchBox(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getSearchBoxBtn(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getSearchMoreBox(): Promise<_BaseUtamElement & _EditableUtamElement>;
  getConnectClose(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getCases(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getSearchItem(
    customerNumber: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getAppLauncher(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getSearchAccount(): Promise<_BaseUtamElement>;
  getCustomerNameLink(titleString: string): Promise<_BaseUtamElement>;
  getCloseCustomer(
    customerName: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getAccountDetails(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
  getCardDetailButton(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
  getCardDetailsSection(): Promise<
    (_BaseUtamElement & _ActionableUtamElement)[]
  >;
  getTabHeader(): Promise<(_BaseUtamElement & _ActionableUtamElement)[]>;
  getAccountSection(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
}
