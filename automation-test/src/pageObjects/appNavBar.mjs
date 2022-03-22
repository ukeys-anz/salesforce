import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _AppNavBarItemRoot from "./../pageObjects/appNavBarItemRoot";

async function _utam_filter_navItem(element, text) {
  const result = await element.getItemText();
  return result.includes(text);
}

async function _utam_get_navItems(driver, root) {
  let _element = root;
  const _locator = _By.css(`one-app-nav-bar-item-root`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

export default class AppNavBar extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getNavItem(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_navItems(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _AppNavBarItemRoot(driver, element);
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
