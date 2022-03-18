import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordHomeTemplateDesktop2 from "./../pageObjects/recordHomeTemplateDesktop2";
import _RecordLayoutEventBroker from "./../pageObjects/recordLayoutEventBroker";

export default class RecordPageDecorator extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getTemplateDesktop2(): Promise<_RecordHomeTemplateDesktop2>;
  getEventBroker(): Promise<_RecordLayoutEventBroker>;
}
