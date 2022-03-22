import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";

async function _utam_get_closeButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`button[title*='Close']`);
  return _element.findElement(_locator);
}

export default class ConsoleTabBarItem extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getCloseButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_closeButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async closeTab() {
    const _statement0 = await this.getCloseButton();
    await _statement0.click();
  }
}
