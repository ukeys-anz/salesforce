import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Input from "./../pageObjects/input";
import _Button from "./../pageObjects/button";

async function _utam_get_lightningInput(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-input`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lightningButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_content(driver, root) {
  let _element = root;
  const _locator = _By.css(`div.slds-card__body pre`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class WireGetObjectInfo extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getLightningInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningInput(driver, root);
    element = new _Input(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getLightningButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_lightningButton(driver, root);
    element = new _Button(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getContent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_content(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async searchAndWaitForResponse(textToSearch) {
    const _statement0 = await this.getLightningInput();
    await _statement0.setText(textToSearch);
    const _statement1 = await this.getLightningButton();
    await _statement1.click();
    const _result2 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.containsElement(
        _By.css(`div.slds-card__body pre`),
        true
      );
      return _result0;
    });
    return _result2;
  }

  async getContent() {
    const _statement0 = await this.__getContent();
    const _result0 = await _statement0.getText();
    return _result0;
  }
}
