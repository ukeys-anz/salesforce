"use strict";

var core = require("@utam/core");

async function _utam_get_shareButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Share']`);
  return _element.findElement(_locator);
}

async function _utam_get_contentEditArea(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.slds-rich-text-area__content`);
  return _element.findElement(_locator);
}

async function _utam_get_saveButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Click, or press Ctrl+Enter']`);
  return _element.findElement(_locator);
}

async function _utam_get_latestPost(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.cuf-feedElementIterationItem`);
  return _element.findElement(_locator);
}

async function _utam_get_latestPostContent(driver, root) {
  let _element = await _utam_get_latestPost(driver, root);
  const _locator = core.By.css(`.cuf-body .uiOutputText`);
  return _element.findElement(_locator);
}

async function _utam_get_postActionTrigger(driver, root) {
  let _element = await _utam_get_latestPost(driver, root);
  const _locator = core.By.css(`.cuf-feedItemActionTrigger`);
  return _element.findElement(_locator);
}

async function _utam_get_postActionButton(driver, root) {
  let _element = await _utam_get_postActionTrigger(driver, root);
  const _locator = core.By.css(`button`);
  return _element.findElement(_locator);
}

async function _utam_get_postDeleteButton(driver, root) {
  let _element = await _utam_get_postActionTrigger(driver, root);
  const _locator = core.By.css(`li[title='Delete'] a`);
  return _element.findElement(_locator);
}

class ChatterPanel extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getShareButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_shareButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getContentEditArea() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement,
      core.EditableUtamElement
    );
    let element = await _utam_get_contentEditArea(driver, root);
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async __getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_saveButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getLatestPost() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_latestPost(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLatestPostContent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_latestPostContent(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getPostActionTrigger() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_postActionTrigger(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getPostActionButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_postActionButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getPostDeleteButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_postDeleteButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async postComment(contentToShare) {
    const _statement0 = await this.__getShareButton();
    await _statement0.click();
    const _statement1 = await this.__getContentEditArea();
    await _statement1.clearAndType(contentToShare);
    const _statement2 = await this.__getSaveButton();
    await _statement2.click();
  }

  async latestPostContentHasMasked() {
    const _statement0 = await this.__getLatestPostContent();
    const _result0 = await _statement0.getText();
    const _matcher0 = _result0.includes("************");
    return _matcher0;
  }

  async getLatestPostContent() {
    const _statement0 = await this.__getLatestPostContent();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async latestPostContentContains(content) {
    const _statement0 = await this.__getLatestPostContent();
    const _result0 = await _statement0.getText();
    const _matcher0 = _result0.includes(content);
    return _matcher0;
  }

  async latestPostContentEquals(content) {
    const _statement0 = await this.__getLatestPostContent();
    const _result0 = await _statement0.getText();
    const _matcher0 = _result0 === content;
    return _matcher0;
  }

  async clickDeleteLatestPost() {
    const _statement0 = await this.__getPostActionButton();
    await _statement0.click();
    await this.waitFor(async () => {
      const _statement0 = await this.__getPostDeleteButton();
      const _result0 = await _statement0.isVisible();
      return _result0;
    });
    const _statement2 = await this.__getPostDeleteButton();
    await _statement2.click();
  }
}

module.exports = ChatterPanel;
