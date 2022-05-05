"use strict";

var core = require("@utam/core");

async function _utam_get_sortLink(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a.toggle`);
  return _element.findElement(_locator);
}

async function _utam_get_assistiveText(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a.toggle + .slds-assistive-text`);
  return _element.findElement(_locator);
}

class ListViewHeader extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getSortLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_sortLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getAssistiveText() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_assistiveText(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async sort() {
    const _statement0 = await this.__getSortLink();
    await _statement0.click();
  }

  async getSortingDirection() {
    const _statement0 = await this.__getAssistiveText();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}

module.exports = ListViewHeader;
