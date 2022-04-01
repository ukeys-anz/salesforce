import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Input from "./../pageObjects/input";
import _Button from "./../pageObjects/button";

export default class WireGetObjectInfo extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  searchAndWaitForResponse(textToSearch: string): Promise<boolean>;
  getContent(): Promise<string>;
  getLightningInput(): Promise<_Input>;
  getLightningButton(): Promise<_Button>;
}
