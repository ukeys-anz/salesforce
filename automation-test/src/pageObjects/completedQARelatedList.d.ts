import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _CompletedQARelatedListItem from "./../pageObjects/completedQARelatedListItem";

export default class CompletedQARelatedList extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getQualityAssessmentByNumber(
    qaNumber: string
  ): Promise<_CompletedQARelatedListItem>;
}
