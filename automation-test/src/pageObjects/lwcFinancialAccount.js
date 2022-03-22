"use strict";

var core = require("@utam/core");

async function _utam_get_everydayAccount(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `c-financial-account[data-id='checking-account']`
  );
  return _element.findElement(_locator);
}

async function _utam_get_savingsAccount(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `c-financial-account[data-id='savings-account']`
  );
  return _element.findElement(_locator);
}

async function _utam_get_financialGoals(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-financial-goals-person-account`);
  return _element.findElement(_locator);
}

async function _utam_get_totalBalance(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-total-balance`);
  return _element.findElement(_locator);
}

class LwcFinancialAccount extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getEverydayAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_everydayAccount(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getSavingsAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_savingsAccount(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getFinancialGoals() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_financialGoals(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getTotalBalance() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_totalBalance(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }
}

module.exports = LwcFinancialAccount;
