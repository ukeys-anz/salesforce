"use strict";

var core = require("@utam/core");

async function _utam_filter_button(element, buttonText) {
  const result = await element.getText();
  return result === buttonText;
}

async function _utam_get_buttons(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button`);
  return _element.findElements(_locator);
}

class ChangeRecordTypeFooter extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getButton(buttonText) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_buttons(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_button(el, buttonText))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    return elements;
  }

  async clickButton(buttonText) {
    const _statement0 = await this.getButton(buttonText);
    await _statement0.click();
  }
}

module.exports = ChangeRecordTypeFooter;
