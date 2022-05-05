"use strict";

var core = require("@utam/core");

async function _utam_get_changeOwnerButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button-icon.change-owner-trigger`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class ChangeOwner extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getChangeOwnerButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_changeOwnerButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async clickButton() {
    const _statement0 = await this.getChangeOwnerButton();
    await _statement0.click();
  }
}

module.exports = ChangeOwner;
