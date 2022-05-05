import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _KnowledgeApprovalHistory from "./../pageObjects/knowledgeApprovalHistory";

export default class KnowledgeRecordPage extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  clickHeaderButtonByTitle(title: string): Promise<void>;
  getFieldOutputText(
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number
  ): Promise<string>;
  openCategoriesEditor(): Promise<void>;
  expandApprovalHistoryDropDown(): Promise<void>;
  getHistories(): Promise<_KnowledgeApprovalHistory[]>;
}
