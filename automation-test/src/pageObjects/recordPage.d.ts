import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _RecordLayoutEventBroker from "./../pageObjects/recordLayoutEventBroker";
import _CaseRecordPage from "./../pageObjects/caseRecordPage";
import _RecordPageDecorator from "./../pageObjects/recordPageDecorator";

export default class RecordPage extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getRecordLayoutBroker(): Promise<_RecordLayoutEventBroker>;
  getCaseRecordPage(): Promise<_CaseRecordPage>;
  getDecorator(): Promise<_RecordPageDecorator>;
}
