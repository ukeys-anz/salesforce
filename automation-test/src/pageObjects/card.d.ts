import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Button from "./../pageObjects/button";

export default class Card extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getFooterText(): Promise<string>;
  getBodyText(): Promise<string>;
  getTitleText(): Promise<string>;
  isNarrow(): Promise<boolean>;
  getButton(): Promise<_Button>;
}
