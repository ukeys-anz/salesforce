import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";
import _Input from "./../pageObjects/input";
import _Combobox from "./../pageObjects/combobox";
import _Button from "./../pageObjects/button";

export default class LwcCaseLogACall extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  logACall(callSID: string, indexStartingOne: number): Promise<void>;
  getLogCallButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getVoiceCallSID(): Promise<_Input>;
  getAuthMethod(): Promise<_Combobox>;
  getSaveButton(): Promise<_Button>;
}
