import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionLink from "./../pageObjects/actionLink";
import _ActionsContainer from "./../pageObjects/actionsContainer";

export default class ListViewManagerHeader extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getSelectedListViewName(): Promise<string>;
  waitForAction(labelText: string): Promise<_ActionLink>;
  getActions(): Promise<_ActionsContainer>;
}
