import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

/**
 * generated from JSON src/utam/lwc/lwcViewCardsDetails.utam.json
 * @version 2022-05-03T02:13:15.522Z
 * @author UTAM
 */
export default class LwcViewCardsDetails extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  isCardHolderVisible(): Promise<boolean>;
  isLast4DigitsVisible(): Promise<boolean>;
  isExpiryDateVisible(): Promise<boolean>;
  isStatusVisible(): Promise<boolean>;
  getStatus(): Promise<string>;
}
