import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _GlobalSearchResultsListItem from "./../pageObjects/globalSearchResultsListItem";

export default class GlobalSearchResultsList extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getSearchResultsListItem(
    resultIndex: number
  ): Promise<_GlobalSearchResultsListItem>;
}
