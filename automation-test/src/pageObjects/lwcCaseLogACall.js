"use strict";

var core = require("@utam/core");
var _Input = require("./../pageObjects/input");
var _Combobox = require("./../pageObjects/combobox");
var _Button = require("./../pageObjects/button");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Input__default = /*#__PURE__*/ _interopDefaultLegacy(_Input);
var _Combobox__default = /*#__PURE__*/ _interopDefaultLegacy(_Combobox);
var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-card`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lightningLayout(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = core.By.css(`lightning-layout`);
  return _element.findElement(_locator);
}

async function _utam_get_lightningLayoutItem(driver, root) {
  let _element = await _utam_get_lightningLayout(driver, root);
  const _locator = core.By.css(`lightning-layout-item`);
  return _element.findElement(_locator);
}

async function _utam_get_logCallButton(driver, root) {
  let _element = await _utam_get_lightningLayoutItem(driver, root);
  const _locator = core.By.css(`[data-test-id='log-call-button']`);
  return _element.findElement(_locator);
}

async function _utam_get_voiceCallSID(driver, root) {
  let _element = await _utam_get_lightningLayoutItem(driver, root);
  const _locator = core.By.css(`[data-test-id='voice-call-sid']`);
  return _element.findElement(_locator);
}

async function _utam_get_authMethod(driver, root) {
  let _element = await _utam_get_lightningLayoutItem(driver, root);
  const _locator = core.By.css(`[data-test-id='authentication-method']`);
  return _element.findElement(_locator);
}

async function _utam_get_saveButton(driver, root) {
  let _element = await _utam_get_lightningLayoutItem(driver, root);
  const _locator = core.By.css(`[data-test-id='save-button']`);
  return _element.findElement(_locator);
}

class LwcCaseLogACall extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_lightningCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLightningLayout() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_lightningLayout(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLightningLayoutItem() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_lightningLayoutItem(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getLogCallButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_logCallButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getVoiceCallSID() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_voiceCallSID(driver, root);
    element = new _Input__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getAuthMethod() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_authMethod(driver, root);
    element = new _Combobox__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_saveButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async logACall(callSID, indexStartingOne) {
    const _statement0 = await this.getLogCallButton();
    await _statement0.click();
    const _statement1 = await this.getVoiceCallSID();
    await _statement1.setText(callSID);
    const _statement2 = await this.getAuthMethod();
    const _statement3 = await _statement2.getBase();
    await _statement3.expandForDisabledInput();
    const _statement5 = await this.getAuthMethod();
    const _statement6 = await _statement5.getBase();
    await _statement6.pickItem(indexStartingOne);
    const _statement8 = await this.getSaveButton();
    await _statement8.click();
  }
}

module.exports = LwcCaseLogACall;
