import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_lightningCard(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-card`);
  return _element.findElement(_locator);
}

async function _utam_get_cardHolder(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css(`[data-test-id='cardholder']`);
  return _element.findElement(_locator);
}

async function _utam_get_last4Digits(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css(`[data-test-id='last-4-digits']`);
  return _element.findElement(_locator);
}

async function _utam_get_expiryDate(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css(`[data-test-id='expiry-date']`);
  return _element.findElement(_locator);
}

async function _utam_get_status(driver, root) {
  let _element = await _utam_get_lightningCard(driver, root);
  const _locator = _By.css(`[data-test-id='status']`);
  return _element.findElement(_locator);
}

export default class LwcViewCardsDetails extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLightningCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lightningCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getCardHolder() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_cardHolder(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLast4Digits() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_last4Digits(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getExpiryDate() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_expiryDate(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getStatus() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_status(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async isCarHolderVisible() {
    const _statement0 = await this.__getCardHolder();
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async isLast4DigitsVisible() {
    const _statement0 = await this.__getLast4Digits();
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async isExpiryDateVisible() {
    const _statement0 = await this.__getExpiryDate();
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async isStatusVisible() {
    const _statement0 = await this.__getStatus();
    const _result0 = await _statement0.isVisible();
    return _result0;
  }

  async getStatus() {
    const _statement0 = await this.__getStatus();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}
