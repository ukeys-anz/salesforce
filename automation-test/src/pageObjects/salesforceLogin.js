"use strict";

var core = require("@utam/core");

async function _utam_get_username(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[id='username']`);
  return _element.findElement(_locator);
}

async function _utam_get_password(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[id='password']`);
  return _element.findElement(_locator);
}

async function _utam_get_loginButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[id='Login']`);
  return _element.findElement(_locator);
}

class SalesforceLogin extends core.UtamBaseRootPageObject {
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

  async getUsername() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_username(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getPassword() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_password(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getLoginButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_loginButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async login(username, password) {
    const _statement0 = await this.getUsername();
    await _statement0.setText(username);
    const _statement1 = await this.getPassword();
    await _statement1.setText(password);
    const _statement2 = await this.getLoginButton();
    await _statement2.click();
  }
}

module.exports = SalesforceLogin;
