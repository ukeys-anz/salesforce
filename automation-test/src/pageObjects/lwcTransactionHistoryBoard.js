"use strict";

var core = require("@utam/core");
var _LwcTransactionHistoryRecord = require("./../pageObjects/lwcTransactionHistoryRecord");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcTransactionHistoryRecord__default = /*#__PURE__*/ _interopDefaultLegacy(
  _LwcTransactionHistoryRecord
);

async function _utam_filter_transactionHistoryRecordOfType(
  element,
  transactionType
) {
  const result = await element.getTransactionType();
  return result === transactionType;
}

async function _utam_get_boardBody(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='board-body']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_transactionHistoryRecordOfTypes(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`c-transaction-history-record`);
  return _element.findElements(_locator);
}

class LwcTransactionHistoryBoard extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBoardBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_boardBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getTransactionHistoryRecordOfType(transactionType) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_transactionHistoryRecordOfTypes(
      driver,
      root
    );
    elements = elements.map(function _createElement(element) {
      return new _LwcTransactionHistoryRecord__default[
        "default"
      ](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) =>
        _utam_filter_transactionHistoryRecordOfType(el, transactionType)
      )
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }
}

module.exports = LwcTransactionHistoryBoard;
