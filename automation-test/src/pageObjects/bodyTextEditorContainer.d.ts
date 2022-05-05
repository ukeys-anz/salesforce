import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

export default class BodyTextEditorContainer extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  enterBodyTextEditorIframe(): Promise<void>;
  getRoot(): Promise<_BaseUtamElement>;
}
