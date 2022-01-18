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
export default class LwcCaseCreation extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);

  getNewCase(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getSelectElements(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
  getGeneralEnquiryChk(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getNextButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getChannelReceived(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getTabItem(index: number): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getCustomerDropDown(
    customerName: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getValueDropDown(
    itemValue: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getDualListLeft(
    itemValue: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getDualListLeftItems(): Promise<(_BaseUtamElement & _ClickableUtamElement)[]>;
  getMoveChosen(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getSaveCase(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getCustomerInput(): Promise<_BaseUtamElement & _EditableUtamElement>;
}
