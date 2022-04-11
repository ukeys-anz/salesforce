"use strict";

var core = require("@utam/core");
var _Component2 = require("./../pageObjects/component2");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Component2__default = /*#__PURE__*/ _interopDefaultLegacy(_Component2);

async function _utam_get_internal(driver, root) {
  let _element = root;
  const _locator = core.By.css(`app_flexipage-lwc-app-flexipage-internal`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_adgRollup(driver, root) {
  let _element = await _utam_get_internal(driver, root);
  const _locator = core.By.css(`.adg-rollup-wrapped`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_module(driver, root) {
  let _element = await _utam_get_adgRollup(driver, root);
  const _locator = core.By.css(`.forcegenerated-flexipage-module`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_template(driver, root) {
  let _element = await _utam_get_module(driver, root);
  const _locator = core.By.css(`.forcegenerated-flexipage-template`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_flexipageComponent2(driver, root) {
  let _element = await _utam_get_template(driver, root);
  const _locator = core.By.css(`flexipage-component2`);
  return _element.findElement(_locator);
}

class AppFlexipage extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getInternal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_internal(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getAdgRollup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_adgRollup(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getModule() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_module(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTemplate() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_template(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getFlexipageComponent2() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_flexipageComponent2(driver, root);
    element = new _Component2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async waitForLoad() {
    await this.waitFor(async () => {
      const _statement0 = await this.__getModule();
      const _result0 = await _statement0.containsElement(
        core.By.css(`.forcegenerated-flexipage-template`),
        true
      );
      return _result0;
    });
    return this;
  }
}

module.exports = AppFlexipage;
