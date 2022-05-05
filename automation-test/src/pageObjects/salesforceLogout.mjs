import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  ClickableUtamElement as _ClickableUtamElement
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

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.isVisible();
      return _result0;
    });
    return _result0;
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getUserProfile() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_userProfile(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getLogoutLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_logoutLink(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async clickProfile() {
    const _statement0 = await this.getUserProfile();
    await _statement0.click();
  }

  async clickLogout() {
    const _statement0 = await this.getLogoutLink();
    await _statement0.click();
  }
}
