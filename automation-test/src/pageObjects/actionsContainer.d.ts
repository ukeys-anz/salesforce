import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionButton from "./../pageObjects/actionButton";
import _ActionLink from "./../pageObjects/actionLink";

export default class ActionsContainer extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getActionButton(text: string): Promise<_ActionButton>;
  getActionLink(text: string): Promise<_ActionLink>;
}
