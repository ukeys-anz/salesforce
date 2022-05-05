"use strict";

var core = require("@utam/core");

async function _utam_get_recordNumber(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.itemTitle .uiOutputText`);
  return _element.findElement(_locator);
}

class CompletedQARelatedListItem extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getRecordNumber() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_recordNumber(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getNumber() {
    const _statement0 = await this.__getRecordNumber();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}

module.exports = CompletedQARelatedListItem;
