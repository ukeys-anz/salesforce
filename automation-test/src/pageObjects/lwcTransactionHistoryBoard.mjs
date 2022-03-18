import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcTransactionHistoryRecord from "./../pageObjects/lwcTransactionHistoryRecord";

async function _utam_filter_transactionHistoryRecords(
  element,
  transcationType
) {
  const result = await element.getTransactionType();
  return result === transcationType;
}

async function _utam_get_boardBody(driver, root) {
  let _element = root;
  const _locator = _By.css(`div[test-data-id='board-body']`);
  return _element.findElement(_locator);
}

async function _utam_get_transactionHistoryRecordss(driver, root) {
  let _element = await _utam_get_boardBody(driver, root);
  const _locator = _By.css(`c-transaction-history-record`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

export default class LwcTransactionHistoryBoard extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBoardBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_boardBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getTransactionHistoryRecords(transcationType) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_transactionHistoryRecordss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _LwcTransactionHistoryRecord(driver, element);
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
