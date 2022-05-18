"use strict";

var core = require("@utam/core");
var _FormattedNumber = require("./../pageObjects/formattedNumber");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _FormattedNumber__default =
  /*#__PURE__*/ _interopDefaultLegacy(_FormattedNumber);

async function _utam_get_transactionDate(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='transaction-date']`);
  _element = new core.ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_transactionType(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='transaction-type']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_transactionTime(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='transaction-time']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_amount(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='amount']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_merchantName(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='merchant-name']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_convertedCurrencyCode(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='converted-currency-code']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_cardScheme(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='card-scheme']`);
  _element = new core.ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_menuButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-button-menu`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_showDetailsButton(driver, root) {
  let _element = await _utam_get_menuButton(driver, root);
  const _locator = core.By.css(`lightning-menu-item:nth-of-type(1)`);
  return _element.findElement(_locator);
}

async function _utam_get_raiseDisputeButton(driver, root) {
  let _element = await _utam_get_menuButton(driver, root);
  const _locator = core.By.css(`lightning-menu-item:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_dropDownButton(driver, root) {
  let _element = await _utam_get_menuButton(driver, root);
  const _locator = core.By.css(`button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcTransactionHistoryRecord extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getTransactionDate() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_transactionDate(driver, root);
    if (!element) {
      return null;
    }
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTransactionType() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_transactionType(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTransactionTime() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_transactionTime(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getAmount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_amount(driver, root);
    element = new _FormattedNumber__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getMerchantName() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_merchantName(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getConvertedCurrencyCode() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_convertedCurrencyCode(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getCardScheme() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_cardScheme(driver, root);
    if (!element) {
      return null;
    }
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getMenuButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_menuButton(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getShowDetailsButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_showDetailsButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getRaiseDisputeButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_raiseDisputeButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getDropDownButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_dropDownButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getTransactionDateEle() {
    const _result0 = await this.__getTransactionDate();
    return _result0;
  }

  async getTransactionDate() {
    const _statement0 = await this.__getTransactionDate();
    if (_statement0 === null) {
      return null;
    }
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getTransactionType() {
    const _statement0 = await this.__getTransactionType();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getTransactionTime() {
    const _statement0 = await this.__getTransactionTime();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getAmount() {
    const _statement0 = await this.__getAmount();
    await _statement0.getInnerText();
  }

  async getMerchantName() {
    const _statement0 = await this.__getMerchantName();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getConvertedCurrencyCode() {
    const _statement0 = await this.__getConvertedCurrencyCode();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getCardScheme() {
    const _statement0 = await this.__getCardScheme();
    if (_statement0 === null) {
      return null;
    }
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async showDetails() {
    const _statement0 = await this.__getDropDownButton();
    await _statement0.click();
    const _statement1 = await this.__getShowDetailsButton();
    await _statement1.click();
  }

  async raiseDispute() {
    const _statement0 = await this.__getDropDownButton();
    await _statement0.click();
    const _statement1 = await this.__getRaiseDisputeButton();
    await _statement1.click();
  }
}

module.exports = LwcTransactionHistoryRecord;
