import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialGoals from "./../pageObjects/lwcFinancialGoals";
import _LwcTransactionHistoryBoard from "./../pageObjects/lwcTransactionHistoryBoard";

async function _utam_get_financialGoals(driver, root) {
  let _element = root;
  const _locator = _By.css(`c-financial-goals`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_transactionHistoryBoard(driver, root) {
  let _element = root;
  const _locator = _By.css(`c-transaction-history-board`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcFinancialAccountParent extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getFinancialGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialGoals(driver, root);
    element = new _LwcFinancialGoals(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getTransactionHistoryBoard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_transactionHistoryBoard(driver, root);
    element = new _LwcTransactionHistoryBoard(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
