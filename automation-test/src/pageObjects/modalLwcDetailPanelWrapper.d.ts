import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordLayoutEventBroker from "./../pageObjects/recordLayoutEventBroker";
import _LwcDetailPanel from "./../pageObjects/lwcDetailPanel";

export default class ModalLwcDetailPanelWrapper extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getEventBroker(): Promise<_RecordLayoutEventBroker>;
  getLwcDetailPanel(): Promise<_LwcDetailPanel>;
}
