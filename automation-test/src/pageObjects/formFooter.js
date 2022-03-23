"use strict";

var core = require("@utam/core");
var _Button = require("./../pageObjects/button");
var _ActionsRibbon = require("./../pageObjects/actionsRibbon");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);
var _ActionsRibbon__default = /*#__PURE__*/ _interopDefaultLegacy(
  _ActionsRibbon
);

async function _utam_get_saveButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button.save-button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_cancelButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button.cancel-button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_saveAndNewButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button.save-and-new-button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_actionsRibbon(driver, root) {
  let _element = root;
  const _locator = core.By.css(`runtime_platform_actions-actions-ribbon`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class FormFooter extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_saveButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getCancelButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_cancelButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSaveAndNewButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_saveAndNewButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getActionsRibbon() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actionsRibbon(driver, root);
    element = new _ActionsRibbon__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = FormFooter;
