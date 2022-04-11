import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Button from "./../pageObjects/button";
import _ActionsRibbon from "./../pageObjects/actionsRibbon";

async function _utam_get_saveButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button.save-button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_cancelButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button.cancel-button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_saveAndNewButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-button.save-and-new-button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_actionsRibbon(driver, root) {
  let _element = root;
  const _locator = _By.css(`runtime_platform_actions-actions-ribbon`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class FormFooter extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_saveButton(driver, root);
    element = new _Button(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getCancelButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_cancelButton(driver, root);
    element = new _Button(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSaveAndNewButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_saveAndNewButton(driver, root);
    element = new _Button(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getActionsRibbon() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actionsRibbon(driver, root);
    element = new _ActionsRibbon(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
