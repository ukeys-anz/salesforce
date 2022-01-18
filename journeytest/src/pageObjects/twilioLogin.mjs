import {
  By as _By,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  createUtamMixinCtor as _createUtamMixinCtor,
  EditableUtamElement as _EditableUtamElement,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

async function _utam_get_email(driver, root) {
  let _element = root;
  const _locator = _By.css(`[name='loginfmt']`);
  return _element.findElement(_locator);
}

async function _utam_get_next(driver, root) {
  let _element = root;
  const _locator = _By.css(`input[type='submit']`);
  return _element.findElement(_locator);
}

async function _utam_get_password(driver, root) {
  let _element = root;
  const _locator = _By.css(`[name='passwd']`);
  return _element.findElement(_locator);
}

export default class TwilioLogin extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }
  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getEmail() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_email(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getNext() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_next(driver, root);
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
