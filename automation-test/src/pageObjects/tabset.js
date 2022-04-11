"use strict";

var core = require("@utam/core");
var _TabBar = require("./../pageObjects/tabBar");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _TabBar__default = /*#__PURE__*/ _interopDefaultLegacy(_TabBar);

async function _utam_get_activeTabContent(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[class*='slds-show'][role='tabpanel']`);
  return _element.findElement(_locator);
}

async function _utam_get_tabBar(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-tab-bar`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Tabset extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getActiveTabContent(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_activeTabContent(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getTabBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_tabBar(driver, root);
    element = new _TabBar__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = Tabset;
