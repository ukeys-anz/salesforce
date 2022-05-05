import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  EditableUtamElement as _EditableUtamElement
} from "@utam/core";

export default class BodyTextEditor extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  editBody(content: string): Promise<void>;
  getRoot(): Promise<_BaseUtamElement & _EditableUtamElement>;
}
