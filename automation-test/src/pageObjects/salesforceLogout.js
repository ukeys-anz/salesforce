"use strict";

var core = require("@utam/core");

async function _utam_get_userProfile(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[class*='branding-userProfile-button']`);
  return _element.findElement(_locator);
}

async function _utam_get_logoutLink(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a[class*='logout']`);
  return _element.findElement(_locator);
}

class SalesforceLogout extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
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
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getUserProfile() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_userProfile(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getLogoutLink() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
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

module.exports = SalesforceLogout;
