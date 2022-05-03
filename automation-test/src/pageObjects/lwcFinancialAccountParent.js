"use strict";

var core = require("@utam/core");
var _LwcFinancialGoals = require("./../pageObjects/lwcFinancialGoals");
var _LwcTransactionHistoryBoard = require("./../pageObjects/lwcTransactionHistoryBoard");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcFinancialGoals__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcFinancialGoals);
var _LwcTransactionHistoryBoard__default = /*#__PURE__*/ _interopDefaultLegacy(
  _LwcTransactionHistoryBoard
);

async function _utam_get_financialGoals(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-financial-goals`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_transactionHistoryBoard(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-transaction-history-board`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LwcFinancialAccountParent extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFinancialGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialGoals(driver, root);
    element = new _LwcFinancialGoals__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getTransactionHistoryBoard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_transactionHistoryBoard(driver, root);
    element = new _LwcTransactionHistoryBoard__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = LwcFinancialAccountParent;
