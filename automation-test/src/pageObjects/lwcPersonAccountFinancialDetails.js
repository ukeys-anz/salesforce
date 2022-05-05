"use strict";

var core = require("@utam/core");
var _LwcFinancialAccount = require("./../pageObjects/lwcFinancialAccount");
var _LwcFinancialGoalsPersonAccount = require("./../pageObjects/lwcFinancialGoalsPersonAccount");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcFinancialAccount__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcFinancialAccount);
var _LwcFinancialGoalsPersonAccount__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcFinancialGoalsPersonAccount);

async function _utam_get_refreshButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='refresh-button']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_everydayAccount(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `c-financial-account[data-test-id='checking-account']`
  );
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_savingsAccount(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `c-financial-account[data-test-id='savings-account']`
  );
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_financialGoals(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-financial-goals-person-account`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcPersonAccountFinancialDetails extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getRefreshButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_refreshButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getEverydayAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_everydayAccount(driver, root);
    element = new _LwcFinancialAccount__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSavingsAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_savingsAccount(driver, root);
    element = new _LwcFinancialAccount__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getFinancialGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialGoals(driver, root);
    element = new _LwcFinancialGoalsPersonAccount__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }

  async refresh() {
    const _statement0 = await this.__getRefreshButton();
    await _statement0.click();
  }
}

module.exports = LwcPersonAccountFinancialDetails;
