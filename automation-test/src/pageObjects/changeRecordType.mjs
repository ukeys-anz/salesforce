import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_contentRowss(driver, root) {
  let _element = root;
  const _locator = _By.css(`.forceChangeRecordTypeRow`);
  return _element.findElements(_locator);
}

export default class ChangeRecordType extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getContentRows() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let elements = await _utam_get_contentRowss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new BaseUtamElement(driver, element);
    });
    return elements;
  }
}
