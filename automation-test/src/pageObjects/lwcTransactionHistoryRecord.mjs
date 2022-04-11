import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_transactionDate(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='transaction-date']`);
  _element = new _ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_transactionType(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='transaction-type']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_transactionTime(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='transaction-time']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_menuButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button-menu`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_raiseDisputeButton(driver, root) {
  let _element = await _utam_get_menuButton(driver, root);
  const _locator = _By.css(`lightning-menu-item:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_button(driver, root) {
  let _element = await _utam_get_menuButton(driver, root);
  const _locator = _By.css(`button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcTransactionHistoryRecord extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getTransactionDate() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
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
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_transactionType(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTransactionTime() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_transactionTime(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getMenuButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_menuButton(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRaiseDisputeButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_raiseDisputeButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_button(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
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

  async getTransactionDateInput() {
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

  async raiseDispute() {
    const _statement0 = await this.__getButton();
    await _statement0.click();
    const _statement1 = await this.__getRaiseDisputeButton();
    await _statement1.click();
  }
}
