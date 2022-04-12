import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _AppNav from "./../pageObjects/appNav";
import _AppFlexipage from "./../pageObjects/appFlexipage";

async function _utam_get_navigationBar(driver, root) {
  let _element = root;
  const _locator = _By.css(`one-appnav`);
  return _element.findElement(_locator);
}

async function _utam_get_activeFlexiPage(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `.oneContent.active app_flexipage-lwc-app-flexipage`
  );
  return _element.findElement(_locator);
}

export default class HomePage extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getNavigationBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_navigationBar(driver, root);
    element = new _AppNav(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getActiveFlexiPage() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_activeFlexiPage(driver, root);
    element = new _AppFlexipage(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getComponent() {
    const _statement0 = await this.getActiveFlexiPage();
    const _statement1 = await _statement0.waitForLoad();
    const _result2 = await _statement1.getFlexipageComponent2();
    return _result2;
  }
}
