import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

export default class KnowledgeModal extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  submit(): Promise<void>;
  approve(): Promise<void>;
  editAsDraft(): Promise<void>;
  publish(): Promise<void>;
}
