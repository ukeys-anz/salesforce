import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordPicklist from "./../pageObjects/recordPicklist";

export default class InputStageName extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getRecordPicklist(): Promise<_RecordPicklist>;
}
