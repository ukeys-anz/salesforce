"use strict";

var core = require("@utam/core");

async function _utam_get_contentRowss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceChangeRecordTypeRow`);
  return _element.findElements(_locator);
}

class ChangeRecordType extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getContentRows() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let elements = await _utam_get_contentRowss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new BaseUtamElement(driver, element);
    });
    return elements;
  }
}

module.exports = ChangeRecordType;
