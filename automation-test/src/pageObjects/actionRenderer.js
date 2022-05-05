"use strict";

var core = require("@utam/core");
var _Button = require("./../pageObjects/button");
var _ExecutorLwcHeadless = require("./../pageObjects/executorLwcHeadless");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);
var _ExecutorLwcHeadless__default =
  /*#__PURE__*/ _interopDefaultLegacy(_ExecutorLwcHeadless);

async function _utam_filter_item(element, itemText) {
  const result = await element.getText();
  return result.includes(itemText);
}

async function _utam_get_items(driver, root) {
  let _element = root;
  const _locator = core.By.css(`runtime_platform_actions-ribbon-menu-item`);
  return _element.findElements(_locator);
}

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

  async __getItem(itemText) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_items(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_item(el, itemText))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    return elements;
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

  async clickItemByText(itemText) {
    const _statement0 = await this.__getItem(itemText);
    await _statement0.click();
  }
}

module.exports = ActionRenderer;
