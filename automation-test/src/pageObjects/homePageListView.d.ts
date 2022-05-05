import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ListViewHeader from "./../pageObjects/listViewHeader";
import _ListViewRow from "./../pageObjects/listViewRow";

export default class HomePageListView extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getListViewTitle(): Promise<string>;
  clickNew(): Promise<void>;
  getListViewHeaderByTitle(headerTitle: string): Promise<_ListViewHeader>;
  getListViewRowByIndex(rowIndex: number): Promise<_ListViewRow>;
}
