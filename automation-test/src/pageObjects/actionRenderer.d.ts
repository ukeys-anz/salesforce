import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Button from "./../pageObjects/button";
import _ExecutorLwcHeadless from "./../pageObjects/executorLwcHeadless";

export default class ActionRenderer extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  clickButton(): Promise<void>;
  getLightningButton(): Promise<_Button>;
  getHeadlessAction(): Promise<_ExecutorLwcHeadless>;
}
