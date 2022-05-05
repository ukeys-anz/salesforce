import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class KnowledgeEditAsDraftModal extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  saveDraft(): Promise<void>;
  editReasonForChangeEdit(reasonForChangeText: string): Promise<void>;
  getSaveButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
