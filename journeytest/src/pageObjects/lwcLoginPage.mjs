import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

async function _utam_get_username(driver, root) {
  let _element = root;
  const _locator = _By.css(`[id='username']`);
  return _element.findElement(_locator);
}

async function _utam_get_login(driver, root) {
  let _element = root;
  const _locator = _By.css(`[id='login']`);
  return _element.findElement(_locator);
}

async function _utam_get_password(driver, root) {
  let _element = root;
  const _locator = _By.css(`[id='password']`);
  return _element.findElement(_locator);
}

export default class LwcLoginPage extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }
  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getUsername() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_username(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getLogin() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_login(driver, root);
    element = new ClickableUtamElement(driver, element);
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
}
