import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  UtamBaseRootPageObject as _UtamBaseRootPageObject,
  createUtamMixinCtor as _createUtamMixinCtor
} from "@utam/core";

async function _utam_filter_buttonsByText(element, text) {
  const result = await element.getText();
  return result === text;
}

async function _utam_get_buttonsByTexts(driver, root) {
  let _element = root;
  const _locator = _By.css(`button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

export default class LwcAccountsSection extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`slot`)) {
    super(driver, element, locator);
  }
  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getButtonsByText(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let elements = await _utam_get_buttonsByTexts(driver, root);
    elements = elements.map(function _createElement(element) {
      return new BaseUtamElement(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_buttonsByText(el, text))
    );
    elements = elements.filter((_, i) => appliedFilter[i]);
    return elements;
  }
}
