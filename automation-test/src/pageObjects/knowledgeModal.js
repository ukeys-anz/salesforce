"use strict";

var core = require("@utam/core");
var _LwcPublishArticle = require("./../pageObjects/lwcPublishArticle");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcPublishArticle__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcPublishArticle);

async function _utam_get_modalFooter(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.modal-footer`);
  return _element.findElement(_locator);
}

async function _utam_get_submitButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = core.By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_approveButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = core.By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_editAsDraftButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = core.By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_publishArticleModal(driver, root) {
  let _element = root;
  const _locator = core.By.css(`c-publish-article`);
  return _element.findElement(_locator);
}

class KnowledgeModal extends core.UtamBaseRootPageObject {
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

  async __getModalFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalFooter(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getSubmitButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_submitButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getApproveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_approveButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getEditAsDraftButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_editAsDraftButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getPublishArticleModal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_publishArticleModal(driver, root);
    element = new _LwcPublishArticle__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async submit() {
    const _statement0 = await this.__getSubmitButton();
    await _statement0.click();
  }

  async approve() {
    const _statement0 = await this.__getApproveButton();
    await _statement0.click();
  }

  async editAsDraft() {
    const _statement0 = await this.__getEditAsDraftButton();
    await _statement0.click();
  }

  async publish() {
    const _statement0 = await this.__getPublishArticleModal();
    await _statement0.publish();
  }
}

module.exports = KnowledgeModal;
