"use strict";

var core = require("@utam/core");

async function _utam_get_targetValue(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='target-value']`);
  return _element.findElement(_locator);
}

async function _utam_get_totalSaved(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='total-saved']`);
  return _element.findElement(_locator);
}

class LwcFinancialGoalsDetails extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getTargetValue() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_targetValue(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getTotalSaved() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_totalSaved(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }
}

module.exports = LwcFinancialGoalsDetails;
