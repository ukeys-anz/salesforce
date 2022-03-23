"use strict";

var core = require("@utam/core");
var _LwcRecordLayout = require("./../pageObjects/lwcRecordLayout");
var _FormFooter = require("./../pageObjects/formFooter");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcRecordLayout__default = /*#__PURE__*/ _interopDefaultLegacy(
  _LwcRecordLayout
);
var _FormFooter__default = /*#__PURE__*/ _interopDefaultLegacy(_FormFooter);

async function _utam_get_recordLayoutContainer(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.record-layout-container`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_recordLayout(driver, root) {
  let _element = await _utam_get_recordLayoutContainer(driver, root);
  const _locator = core.By.css(`records-lwc-record-layout`);
  return _element.findElement(_locator);
}

async function _utam_get_footer(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-form-footer`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class BaseRecordForm extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.containsElement(
        core.By.css(`.record-layout-container`),
        true
      );
      return _result0;
    });
    return _result0;
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getRecordLayoutContainer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_recordLayoutContainer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getRecordLayout() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_recordLayout(driver, root);
    element = new _LwcRecordLayout__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_footer(driver, root);
    element = new _FormFooter__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async clickFooterButton(titleString) {
    await this.waitFor(async () => {
      const _result0 = await this.getFooter();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement1 = await this.getFooter();
    const _statement2 = await _statement1.getActionsRibbon();
    const _statement3 = await _statement2.waitForRenderedAction(titleString);
    await _statement3.clickButton();
  }

  async waitForLoad() {
    await this.waitFor(async () => {
      const _statement0 = await this.__getRecordLayoutContainer();
      const _result0 = await _statement0.containsElement(
        core.By.css(`records-lwc-record-layout`)
      );
      return _result0;
    });
    return this;
  }
}

module.exports = BaseRecordForm;
