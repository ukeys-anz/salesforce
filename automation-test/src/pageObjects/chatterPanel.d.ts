import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

export default class ChatterPanel extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  postComment(contentToShare: string): Promise<void>;
  latestPostContentHasMasked(): Promise<boolean>;
  getLatestPostContent(): Promise<string>;
  latestPostContentContains(content: string): Promise<boolean>;
  latestPostContentEquals(content: string): Promise<boolean>;
  clickDeleteLatestPost(): Promise<void>;
}
