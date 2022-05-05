import {
  Driver as _Driver,
  Element as _Element,
  Locator as _Locator,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

/**
 * generated from JSON src/utam/force/chatterPanel.utam.json
 * @version 2022-05-03T10:04:49.271Z
 * @author UTAM
 */
export default class ChatterPanel extends _UtamBasePageObject {
  constructor(driver: _Driver, element?: _Element, locator?: _Locator);
  clickShareButton(): Promise<void>;
  postComment(contentToShare: string): Promise<void>;
  latestPostContentHasMasked(): Promise<boolean>;
  getLatestPostContent(): Promise<string>;
  latestPostContentContains(content: string): Promise<boolean>;
  latestPostContentEquals(content: string): Promise<boolean>;
  clickDeleteLatestPost(): Promise<void>;
}
