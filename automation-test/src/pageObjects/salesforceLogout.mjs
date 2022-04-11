import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";

async function _utam_get_userProfile(driver, root) {
  let _element = root;
  const _locator = _By.css(`button[class*='branding-userProfile-button']`);
  return _element.findElement(_locator);
}

async function _utam_get_logoutLink(driver, root) {
  let _element = root;
  const _locator = _By.css(`a[class*='logout']`);
  return _element.findElement(_locator);
}

export default class SalesforceLogout extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getUserProfile() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_userProfile(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getLogoutLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_logoutLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async logout() {
    const _statement0 = await this.__getUserProfile();
    await _statement0.click();
    const _statement1 = await this.__getLogoutLink();
    await _statement1.click();
  }
}
