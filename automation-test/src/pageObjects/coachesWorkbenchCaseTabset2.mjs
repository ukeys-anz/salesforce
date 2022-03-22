import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _Component2 from "./../pageObjects/component2";

async function _utam_get_tabset(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-tabset`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_activeTab(driver, root) {
  let _element = await _utam_get_tabset(driver, root);
  const _locator = _By.css(`flexipage-tab2.slds-show`);
  return _element.findElement(_locator);
}

async function _utam_get_detailComponent(driver, root) {
  let _element = await _utam_get_activeTab(driver, root);
  const _locator = _By.css(`flexipage-component2`);
  return _element.findElement(_locator);
}

export default class CoachesWorkbenchCaseTabset2 extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_tabset(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getActiveTab() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_activeTab(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDetailComponent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailComponent(driver, root);
    element = new _Component2(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
