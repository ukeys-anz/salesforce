import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcFinancialAccount from "./../pageObjects/lwcFinancialAccount";
import _LwcFinancialGoalsPersonAccount from "./../pageObjects/lwcFinancialGoalsPersonAccount";

async function _utam_get_refreshButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`[data-test-id='refresh-button']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_everydayAccount(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `c-financial-account[data-test-id='checking-account']`
  );
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_savingsAccount(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `c-financial-account[data-test-id='savings-account']`
  );
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_financialGoals(driver, root) {
  let _element = root;
  const _locator = _By.css(`c-financial-goals-person-account`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LwcPersonAccountFinancialDetails extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getRefreshButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_refreshButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getEverydayAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_everydayAccount(driver, root);
    element = new _LwcFinancialAccount(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSavingsAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_savingsAccount(driver, root);
    element = new _LwcFinancialAccount(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getFinancialGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_financialGoals(driver, root);
    element = new _LwcFinancialGoalsPersonAccount(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async refresh() {
    const _statement0 = await this.__getRefreshButton();
    await _statement0.click();
  }
}
