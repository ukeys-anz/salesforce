import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Button from "./../pageObjects/button";

async function _utam_get_narrow(driver, root) {
  let _element = root;
  const _locator = _By.css(`article[class*='slds-card_narrow']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_header(driver, root) {
  let _element = root;
  const _locator = _By.css(`header`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_titleContainer(driver, root) {
  let _element = await _utam_get_header(driver, root);
  const _locator = _By.css(`span[class*='slds-text-heading_small']`);
  return _element.findElement(_locator);
}

async function _utam_get_button(driver, root) {
  let _element = await _utam_get_header(driver, root);
  const _locator = _By.css(`lightning-button`);
  return _element.findElement(_locator);
}

async function _utam_get_cardBody(driver, root) {
  let _element = root;
  const _locator = _By.css(`.slds-card__body`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_footer(driver, root) {
  let _element = root;
  const _locator = _By.css(`.slds-card__footer`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class Card extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getNarrow() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_narrow(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_header(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTitleContainer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_titleContainer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_button(driver, root);
    element = new _Button(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getCardBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_cardBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
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
