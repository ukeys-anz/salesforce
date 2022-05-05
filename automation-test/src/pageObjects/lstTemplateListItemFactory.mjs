import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";

async function _utam_get_lstRelatedPreviewCard(driver, root) {
  let _element = root;
  const _locator = _By.css(`lst-related-preview-card`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_rowHeaderLstTemplatelistField(driver, root) {
  let _element = await _utam_get_lstRelatedPreviewCard(driver, root);
  const _locator = _By.css(`h3 lst-template-list-field`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_rowHeaderLookup(driver, root) {
  let _element = await _utam_get_rowHeaderLstTemplatelistField(driver, root);
  const _locator = _By.css(`force-lookup`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LstTemplateListItemFactory extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLstRelatedPreviewCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstRelatedPreviewCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRowHeaderLstTemplatelistField() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_rowHeaderLstTemplatelistField(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getRowHeaderLookup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_rowHeaderLookup(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }
}
