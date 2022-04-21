"use strict";

var core = require("@utam/core");
var _BaseCombobox = require("./../pageObjects/baseCombobox");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _BaseCombobox__default = /*#__PURE__*/ _interopDefaultLegacy(_BaseCombobox);

async function _utam_get_labelText(driver, root) {
  let _element = root;
  const _locator = core.By.css(`label`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_required(driver, root) {
  let _element = await _utam_get_labelText(driver, root);
  const _locator = core.By.css(`.slds-required`);
  return _element.findElement(_locator);
}

async function _utam_get_base(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-base-combobox`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Combobox extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLabelText() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_labelText(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRequired() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_required(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getBase() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_base(driver, root);
    element = new _BaseCombobox__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getLabelText() {
    const _statement0 = await this.__getLabelText();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async isRequired() {
    const _statement0 = await this.__getRequired();
    const _result0 = await _statement0.isPresent();
    return _result0;
  }
}

module.exports = Combobox;
