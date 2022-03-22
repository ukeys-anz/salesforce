"use strict";

var core = require("@utam/core");

async function _utam_get_transactionType(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div[data-test-id='transcation-type']`);
  return _element.findElement(_locator);
}

async function _utam_get_dropdownButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div.button-icon-col`);
  return _element.findElement(_locator);
}

async function _utam_get_menuButton(driver, root) {
  let _element = await _utam_get_dropdownButton(driver, root);
  const _locator = core.By.css(`lightning-button-menu`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcTransactionHistoryRecord extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getTransactionType() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_transactionType(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getDropdownButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_dropdownButton(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getMenuButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_menuButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getRecordType() {
    const _statement0 = await this.__getTransactionType();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async raiseDispute() {
    const _statement0 = await this.getMenuButton();
    await _statement0.click();
  }
}

module.exports = LwcTransactionHistoryRecord;
