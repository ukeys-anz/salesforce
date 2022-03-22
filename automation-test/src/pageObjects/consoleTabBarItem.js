"use strict";

var core = require("@utam/core");

async function _utam_get_closeButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title*='Close']`);
  return _element.findElement(_locator);
}

class ConsoleTabBarItem extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getCloseButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_closeButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async closeTab() {
    const _statement0 = await this.getCloseButton();
    await _statement0.click();
  }
}

module.exports = ConsoleTabBarItem;
