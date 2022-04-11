"use strict";

var core = require("@utam/core");
var _Button = require("./../pageObjects/button");
var _ExecutorLwcHeadless = require("./../pageObjects/executorLwcHeadless");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);
var _ExecutorLwcHeadless__default = /*#__PURE__*/ _interopDefaultLegacy(
  _ExecutorLwcHeadless
);

async function _utam_get_lightningButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_headlessAction(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `runtime_platform_actions-executor-lwc-headless`
  );
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class ActionRenderer extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getLightningButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getHeadlessAction() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_headlessAction(driver, root);
    element = new _ExecutorLwcHeadless__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async clickButton() {
    const _statement0 = await this.getLightningButton();
    await _statement0.click();
  }
}

module.exports = ActionRenderer;
