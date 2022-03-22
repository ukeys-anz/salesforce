import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ContainerCtor as _ContainerCtor,
  UtamBasePageObject as _UtamBasePageObject,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _ChangeRecordTypeFooter from "./../pageObjects/changeRecordTypeFooter";
import _BaseRecordForm from "./../pageObjects/baseRecordForm";
import _ModalLwcDetailPanelWrapper from "./../pageObjects/modalLwcDetailPanelWrapper";

export default class RecordActionWrapper extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  waitForFooter(): Promise<boolean>;
  waitForChangeRecordFooter(): Promise<_ChangeRecordTypeFooter>;
  getRecordForm(): Promise<_BaseRecordForm>;
  getRoot(): Promise<_BaseUtamElement>;
  getDetailsPanelContainer<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getFooterContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
}
