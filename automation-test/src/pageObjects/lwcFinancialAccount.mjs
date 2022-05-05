import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_balance(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='balance']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lastUpdatedTime(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='last-updated-time']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcFinancialAccount extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBalance() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_balance(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLastUpdatedTime() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lastUpdatedTime(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getBalance() {
    const _statement0 = await this.__getBalance();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getLastUpdatedTime() {
    const _statement0 = await this.__getLastUpdatedTime();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}
