import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

async function _utam_get_loginForm(driver, root) {
  let _element = root;
  const _locator = _By.css(`[id='theloginform']`);
  return _element.findElement(_locator);
}

async function _utam_get_username(driver, root) {
  let _element = await _utam_get_loginForm(driver, root);
  const _locator = _By.css(`[name='username']`);
  return _element.findElement(_locator);
}

async function _utam_get_password(driver, root) {
  let _element = await _utam_get_loginForm(driver, root);
  const _locator = _By.css(`[id='password']`);
  return _element.findElement(_locator);
}

async function _utam_get_loginButton(driver, root) {
  let _element = await _utam_get_loginForm(driver, root);
  const _locator = _By.css(`[name='Login']`);
  return _element.findElement(_locator);
}

async function _utam_get_rightBody(driver, root) {
  let _element = root;
  const _locator = _By.css(`[id='right']`);
  return _element.findElement(_locator);
}

export default class LwcLogin extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }
  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getLoginForm() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_loginForm(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getUsername() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_username(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getPassword() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_password(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getLoginButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_loginButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getRightBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_rightBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async submitForm(userName, passWord) {
    const _statement0 = await this.getUsername();
    await _statement0.setText(userName);
    const _statement1 = await this.getPassword();
    await _statement1.setText(passWord);
    const _statement2 = await this.getLoginButton();
    await _statement2.click();
  }
}
