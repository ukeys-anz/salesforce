import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class CoachesWorkbenchCaseCreationFormPicklist extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  selectPicklistItem(picklistItemIndex: number): Promise<void>;
  getPicklistItem(
    picklistItemIndex: number
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
