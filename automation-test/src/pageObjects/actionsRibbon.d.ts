import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionRenderer from "./../pageObjects/actionRenderer";

export default class ActionsRibbon extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  waitForRenderedAction(titleString: string): Promise<_ActionRenderer>;
  expandDropdown(): Promise<void>;
  getActionRendererWithTitle(titleString: string): Promise<_ActionRenderer>;
}
