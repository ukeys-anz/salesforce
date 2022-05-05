import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

export default class QualityAssessmentSharingModal extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  search(searchTerm: string): Promise<void>;
  clickSearchBox(): Promise<void>;
  clickResult(username: string): Promise<void>;
  save(): Promise<void>;
  getSaveButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
