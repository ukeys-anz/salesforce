import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class BaseComboboxItem extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getItemValue(): Promise<string>;
  clickItem(): Promise<void>;
  getItemByLabel(
    itemLabel: string
  ): Promise<(_BaseUtamElement & _ClickableUtamElement) | null>;
}
