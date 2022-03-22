import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcRecordLayout from "./../pageObjects/lwcRecordLayout";
import _FormFooter from "./../pageObjects/formFooter";

export default class BaseRecordForm extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  clickFooterButton(titleString: string): Promise<void>;
  waitForLoad(): Promise<this>;
  getRecordLayout(): Promise<_LwcRecordLayout>;
  getFooter(): Promise<_FormFooter>;
}
