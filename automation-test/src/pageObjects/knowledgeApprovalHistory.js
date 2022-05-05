"use strict";

var core = require("@utam/core");

async function _utam_get_title(driver, root) {
  let _element = root;
  const _locator = core.By.css(`h3.primaryField`);
  return _element.findElement(_locator);
}

async function _utam_get_assignedTo(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.itemRows li:nth-of-type(3) .slds-item--detail`
  );
  return _element.findElement(_locator);
}

class KnowledgeApprovalHistory extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getTitle() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_title(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getAssignedTo() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_assignedTo(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getTitle() {
    const _statement0 = await this.__getTitle();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getAssignedTo() {
    const _statement0 = await this.__getAssignedTo();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}

module.exports = KnowledgeApprovalHistory;
