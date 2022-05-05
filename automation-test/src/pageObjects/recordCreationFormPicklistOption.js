"use strict";

var core = require("@utam/core");

async function _utam_get_optionLink(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a`);
  return _element.findElement(_locator);
}

class RecordCreationFormPicklistOption extends core.UtamBasePageObject {
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

  async __getOptionLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_optionLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getOptionTitle() {
    const _statement0 = await this.__getOptionLink();
    const _result0 = await _statement0.getTitle();
    return _result0;
  }

  async select() {
    const _statement0 = await this.__getOptionLink();
    await _statement0.click();
  }
}

module.exports = RecordCreationFormPicklistOption;
