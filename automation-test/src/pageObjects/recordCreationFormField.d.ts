import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _AlohaPage from "./../pageObjects/alohaPage";

export default class RecordCreationFormField extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  getLabel(): Promise<string>;
  getReadOnlyLabel(): Promise<string>;
  expandPicklist(): Promise<void>;
  editNumber(numberStr: string): Promise<void>;
  editText(text: string): Promise<void>;
  editTextarea(text: string): Promise<void>;
  clickLookup(): Promise<void>;
  searchLookup(searchTerm: string): Promise<void>;
  selectLookupResult(): Promise<void>;
  selectLookupResultByTitle(resultTile: string): Promise<void>;
  editBody(): Promise<void>;
  getBodyIframe(): Promise<_AlohaPage | null>;
}
