import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_tabByLabel(driver, root, label) {
  let _element = root;
  const _locator = _By.css(`li[title*='${label}']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_tabss(driver, root) {
  let _element = root;
  const _locator = _By.css(`li a`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_activeTab(driver, root) {
  let _element = root;
  const _locator = _By.css(`li[class*='slds-is-active'] a`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class TabBar extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getTabByLabel(label) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_tabByLabel(driver, root, label);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getTabs() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let elements = await _utam_get_tabss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }

  async __getActiveTab() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_activeTab(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getActiveTabText() {
    const _statement0 = await this.__getActiveTab();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async clickTab(label) {
    const _statement0 = await this.getTabByLabel(label);
    await _statement0.click();
  }
}
