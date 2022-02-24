"use strict";

var core = require("@utam/core");

async function _utam_get_username(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[id='username']`);
  return _element.findElement(_locator);
}

async function _utam_get_login(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[id='login']`);
  return _element.findElement(_locator);
}

async function _utam_get_password(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[id='password']`);
  return _element.findElement(_locator);
}

class LwcLoginPage extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
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

  async getLogin() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_login(driver, root);
    element = new ClickableUtamElement(driver, element);
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
}

module.exports = LwcLoginPage;
