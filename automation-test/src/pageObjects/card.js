"use strict";

var core = require("@utam/core");
var _Button = require("./../pageObjects/button");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);

async function _utam_get_narrow(driver, root) {
  let _element = root;
  const _locator = core.By.css(`article[class*='slds-card_narrow']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_header(driver, root) {
  let _element = root;
  const _locator = core.By.css(`header`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_titleContainer(driver, root) {
  let _element = await _utam_get_header(driver, root);
  const _locator = core.By.css(`span[class*='slds-text-heading_small']`);
  return _element.findElement(_locator);
}

async function _utam_get_button(driver, root) {
  let _element = await _utam_get_header(driver, root);
  const _locator = core.By.css(`lightning-button`);
  return _element.findElement(_locator);
}

async function _utam_get_cardBody(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.slds-card__body`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_footer(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.slds-card__footer`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Card extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getNarrow() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_narrow(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_header(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTitleContainer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_titleContainer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_button(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getCardBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_cardBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_footer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getFooterText() {
    const _statement0 = await this.__getFooter();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getBodyText() {
    const _statement0 = await this.__getCardBody();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getTitleText() {
    const _statement0 = await this.__getTitleContainer();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async isNarrow() {
    const _statement0 = await this.__getNarrow();
    const _result0 = await _statement0.isPresent();
    return _result0;
  }
}

module.exports = Card;
