"use strict";

var core = require("@utam/core");

async function _utam_get_lstRelatedPreviewCard(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lst-related-preview-card`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_rowHeaderLstTemplatelistField(driver, root) {
  let _element = await _utam_get_lstRelatedPreviewCard(driver, root);
  const _locator = core.By.css(`h3 lst-template-list-field`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_rowHeaderLookup(driver, root) {
  let _element = await _utam_get_rowHeaderLstTemplatelistField(driver, root);
  const _locator = core.By.css(`force-lookup`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class LstTemplateListItemFactory extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLstRelatedPreviewCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_lstRelatedPreviewCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRowHeaderLstTemplatelistField() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_rowHeaderLstTemplatelistField(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getRowHeaderLookup() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_rowHeaderLookup(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }
}

module.exports = LstTemplateListItemFactory;
