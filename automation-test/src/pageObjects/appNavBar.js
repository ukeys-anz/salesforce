"use strict";

var core = require("@utam/core");
var _AppNavBarItemRoot = require("./../pageObjects/appNavBarItemRoot");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _AppNavBarItemRoot__default = /*#__PURE__*/ _interopDefaultLegacy(
  _AppNavBarItemRoot
);

async function _utam_filter_navItem(element, text) {
  const result = await element.getItemText();
  return result.includes(text);
}

async function _utam_get_navItems(driver, root) {
  let _element = root;
  const _locator = core.By.css(`one-app-nav-bar-item-root`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

class AppNavBar extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getNavItem(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_navItems(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _AppNavBarItemRoot__default["default"](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_navItem(el, text))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }
}

module.exports = AppNavBar;
