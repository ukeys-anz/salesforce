import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Button from "./../pageObjects/button";
import _ActionsRibbon from "./../pageObjects/actionsRibbon";

export default class FormFooter extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getSaveButton(): Promise<_Button>;
  getCancelButton(): Promise<_Button>;
  getSaveAndNewButton(): Promise<_Button>;
  getActionsRibbon(): Promise<_ActionsRibbon>;
}
