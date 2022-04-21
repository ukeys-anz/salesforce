"use strict";

var core = require("@utam/core");

class GlobalSearchResultsListItem extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    return new ClickableUtamElement(driver, root);
  }

  async selectResult() {
    const _statement0 = await this.__getRoot();
    await _statement0.click();
  }
}

module.exports = GlobalSearchResultsListItem;
