"use strict";

var core = require("@utam/core");
var _Component2 = require("./../pageObjects/component2");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Component2__default = /*#__PURE__*/ _interopDefaultLegacy(_Component2);

async function _utam_get_tabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-tabset`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_activeTab(driver, root) {
  let _element = await _utam_get_tabset(driver, root);
  const _locator = core.By.css(`flexipage-tab2.slds-show`);
  return _element.findElement(_locator);
}

async function _utam_get_detailComponent(driver, root) {
  let _element = await _utam_get_activeTab(driver, root);
  const _locator = core.By.css(`flexipage-component2`);
  return _element.findElement(_locator);
}

class CoachesWorkbenchCaseTabset2 extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_tabset(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getActiveTab() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_activeTab(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDetailComponent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailComponent(driver, root);
    element = new _Component2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = CoachesWorkbenchCaseTabset2;
