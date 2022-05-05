import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcViewCardsDetails from "./../pageObjects/lwcViewCardsDetails";

export default class LwcViewCards extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  showDetails(): Promise<void>;
  isInDetailsView(): Promise<boolean>;
  hasMoreCards(): Promise<boolean>;
  loadMore(): Promise<void>;
  getCards(): Promise<_LwcViewCardsDetails[] | null>;
}
