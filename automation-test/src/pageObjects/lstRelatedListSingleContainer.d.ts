import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ListViewRow from "./../pageObjects/listViewRow";
import _LstTemplateListItemFactory from "./../pageObjects/lstTemplateListItemFactory";

export default class LstRelatedListSingleContainer extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  clickButtonByTitle(titleString: string): Promise<void>;
  clickDropdownButtonByTitle(buttonTitle: string): Promise<void>;
  getListViewRowByIndex(rowIndex: number): Promise<_ListViewRow>;
  getItemByIndex(itemInde: number): Promise<_LstTemplateListItemFactory>;
}
