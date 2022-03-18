"use strict";

var core = require("@utam/core");
var _Input = require("./../pageObjects/input");
var _Button = require("./../pageObjects/button");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Input__default = /*#__PURE__*/ _interopDefaultLegacy(_Input);
var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);

async function _utam_get_lightningInput(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-input`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lightningButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_content(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div.slds-card__body pre`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class WireGetObjectInfo extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getLightningInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningInput(driver, root);
    element = new _Input__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getLightningButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getContent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_content(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async searchAndWaitForResponse(textToSearch) {
    const _statement0 = await this.getLightningInput();
    await _statement0.setText(textToSearch);
    const _statement1 = await this.getLightningButton();
    await _statement1.click();
    const _result2 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.containsElement(
        core.By.css(`div.slds-card__body pre`),
        true
      );
      return _result0;
    });
    return _result2;
  }

  async getContent() {
    const _statement0 = await this.__getContent();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}

module.exports = WireGetObjectInfo;
