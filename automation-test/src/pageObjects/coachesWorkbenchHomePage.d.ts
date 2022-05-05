import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _CompletedQARelatedList from "./../pageObjects/completedQARelatedList";
import _HomePageListView from "./../pageObjects/homePageListView";

export default class CoachesWorkbenchHomePage extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getCompletedQARelatedList(): Promise<_CompletedQARelatedList>;
  getListViewByTitle(title: string): Promise<_HomePageListView>;
}
