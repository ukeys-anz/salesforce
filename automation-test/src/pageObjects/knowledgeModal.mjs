import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _LwcPublishArticle from "./../pageObjects/lwcPublishArticle";

async function _utam_get_modalFooter(driver, root) {
  let _element = root;
  const _locator = _By.css(`.modal-footer`);
  return _element.findElement(_locator);
}

async function _utam_get_submitButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = _By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_approveButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = _By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_editAsDraftButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = _By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_publishArticleModal(driver, root) {
  let _element = root;
  const _locator = _By.css(`c-publish-article`);
  return _element.findElement(_locator);
}

export default class KnowledgeModal extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
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
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getModalFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_modalFooter(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getSubmitButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_submitButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getApproveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_approveButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getEditAsDraftButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_editAsDraftButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getPublishArticleModal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_publishArticleModal(driver, root);
    element = new _LwcPublishArticle(driver, element);
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
