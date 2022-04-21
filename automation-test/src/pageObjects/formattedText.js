"use strict";

var core = require("@utam/core");

class FormattedText extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getInnerText() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}

module.exports = FormattedText;
