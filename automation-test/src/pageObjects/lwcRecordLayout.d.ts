import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  ContainerCtor as _ContainerCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordLayoutItem from "./../pageObjects/recordLayoutItem";
import _Highlights2 from "./../pageObjects/highlights2";
import _RecordLayoutSection from "./../pageObjects/recordLayoutSection";

export default class LwcRecordLayout extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getItem(
    indexStartingOne: number,
    rowIndex: number,
    itemIndex: number
  ): Promise<_RecordLayoutItem>;
  waitForHighlights2(): Promise<_Highlights2>;
  getGeneratedContent<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T>;
  getGeneratedContentList<T extends _UtamBasePageObject>(
    ContainerCtor: _ContainerCtor<T>
  ): Promise<T[]>;
  getHighlights2(): Promise<_Highlights2>;
  getSections(): Promise<_RecordLayoutSection[]>;
  getSection(indexStartingOne: number): Promise<_RecordLayoutSection>;
}
