import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  BaseUtamElement as _BaseUtamElement,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _CoachesWorkbenchCaseCreationFormPicklist from "./../pageObjects/coachesWorkbenchCaseCreationFormPicklist";

export default class CoachesWorkbenchCaseCreationForm extends _UtamBaseRootPageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  selectCaseRecordType(text: string): Promise<void>;
  selectPicklist(
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number
  ): Promise<void>;
  editTextarea(
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number,
    text: string
  ): Promise<void>;
  searchAndSelectLookup(
    sectionIndex: number,
    sectionRowIndex: number,
    sectionRowItemIndex: number,
    searchTerm: string,
    resultTile: string
  ): Promise<void>;
  saveNew(): Promise<void>;
  getNewCase(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getCaseRecordType(
    text: string
  ): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getNextButton(): Promise<_BaseUtamElement & _ClickableUtamElement>;
  getPicklistItemsLists(): Promise<_CoachesWorkbenchCaseCreationFormPicklist[]>;
  getSaveCase(): Promise<_BaseUtamElement & _ClickableUtamElement>;
}
