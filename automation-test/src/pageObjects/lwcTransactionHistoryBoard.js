"use strict";

var core = require("@utam/core");
var _Input = require("./../pageObjects/input");
var _Button = require("./../pageObjects/button");
var _LwcTransactionHistoryRecord = require("./../pageObjects/lwcTransactionHistoryRecord");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Input__default = /*#__PURE__*/ _interopDefaultLegacy(_Input);
var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);
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

async function _utam_filter_transactionHistoryRecordsWithDate(element) {
  const result = await element.getTransactionDateEle();
  return result !== null;
}

async function _utam_get_boardBody(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[data-test-id='board-body']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_searchSection(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`.search-section`);
  return _element.findElement(_locator);
}

async function _utam_get_startDateInput(driver, root) {
  let _element = await _utam_get_searchSection(driver, root);
  const _locator = core.By.css(`[data-test-id='startDateInput']`);
  return _element.findElement(_locator);
}

async function _utam_get_endDateInput(driver, root) {
  let _element = await _utam_get_searchSection(driver, root);
  const _locator = core.By.css(`[data-test-id='endDateInput']`);
  return _element.findElement(_locator);
}

async function _utam_get_searchButton(driver, root) {
  let _element = await _utam_get_searchSection(driver, root);
  const _locator = core.By.css(`lightning-button`);
  return _element.findElement(_locator);
}

async function _utam_get_transactionHistoryRecordOfTypes(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`c-transaction-history-record`);
  return _element.findElements(_locator);
}

async function _utam_get_transactionHistoryRecordsWithDates(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`c-transaction-history-record`);
  return _element.findElements(_locator);
}

async function _utam_get_transactionHistoryRecord(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`c-transaction-history-record`);
  return _element.findElement(_locator);
}

async function _utam_get_transactionHistoryRecordss(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`c-transaction-history-record`);
  return _element.findElements(_locator);
}

async function _utam_get_loadMoreButton(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = core.By.css(`button[class*='load-more']`);
  return _element.findElement(_locator);
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

  async __getSearchSection() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_searchSection(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getStartDateInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_startDateInput(driver, root);
    element = new _Input__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getEndDateInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_endDateInput(driver, root);
    element = new _Input__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getSearchButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_searchButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
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

  async getTransactionHistoryRecordsWithDate() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_transactionHistoryRecordsWithDates(
      driver,
      root
    );
    elements = elements.map(function _createElement(element) {
      return new _LwcTransactionHistoryRecord__default[
        "default"
      ](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_transactionHistoryRecordsWithDate(el))
    );
    elements = elements.filter((_, i) => appliedFilter[i]);
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getTransactionHistoryRecord() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_transactionHistoryRecord(driver, root);
    element = new _LwcTransactionHistoryRecord__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }

  async getTransactionHistoryRecords() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_transactionHistoryRecordss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _LwcTransactionHistoryRecord__default[
        "default"
      ](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async __getLoadMoreButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_loadMoreButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getEndDateSearch() {
    const _statement0 = await this.__getEndDateInput();
    const _result1 = await _statement0.getDatepicker();
    return _result1;
  }

  async loadMore() {
    const _statement0 = await this.__getLoadMoreButton();
    await _statement0.click();
    const _statement1 = await this.getTransactionHistoryRecords();
    await Promise.all(_statement1.map((_it) => _it.waitForVisible()));
  }
}

module.exports = LwcTransactionHistoryBoard;
