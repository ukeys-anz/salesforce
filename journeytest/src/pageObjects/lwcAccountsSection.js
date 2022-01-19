"use strict";

var core = require("@utam/core");

async function _utam_filter_buttonsByText(element, text) {
  const result = await element.getText();
  return result === text;
}

async function _utam_get_buttonsByTexts(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

class LwcAccountsSection extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`slot`)) {
    super(driver, element, locator);
  }
  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getButtonsByText(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let elements = await _utam_get_buttonsByTexts(driver, root);
    elements = elements.map(function _createElement(element) {
      return new BaseUtamElement(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_buttonsByText(el, text))
    );
    elements = elements.filter((_, i) => appliedFilter[i]);
    return elements;
  }
}

module.exports = LwcAccountsSection;
