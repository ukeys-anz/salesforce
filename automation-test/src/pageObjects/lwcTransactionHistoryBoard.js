"use strict";

var core = require("@utam/core");
var _LwcTransactionHistoryRecord = require("./../pageObjects/lwcTransactionHistoryRecord");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcTransactionHistoryRecord__default = /*#__PURE__*/ _interopDefaultLegacy(
  _LwcTransactionHistoryRecord
);

async function _utam_filter_transactionHistoryRecords(
  element,
  transcationType
) {
  const result = await element.getTransactionType();
  return result === transcationType;
}

async function _utam_get_boardBody(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div[test-data-id='board-body']`);
  return _element.findElement(_locator);
}

async function _utam_get_transactionHistoryRecordss(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`c-transaction-history-record`);
  _element = new core.ShadowRoot(driver, _element);
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

  async getTransactionHistoryRecords(transcationType) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_transactionHistoryRecordss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _LwcTransactionHistoryRecord__default[
        "default"
      ](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) =>
        _utam_filter_transactionHistoryRecords(el, transcationType)
      )
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }

  async getTransactionHistoryRecordByType(transcationType) {
    const _statement0 = await this.getTransactionHistoryRecords(
      transcationType
    );
    const _result0 = await _statement0.getRecordType();
    return _result0;
  }
}

module.exports = LwcTransactionHistoryBoard;
