import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  FrameUtamElement as _FrameUtamElement,
  UtamBaseRootPageObject as _UtamBaseRootPageObject
} from "@utam/core";
import _BodyTextEditor from "./../pageObjects/bodyTextEditor";

async function _utam_get_bodyTextEdtor(driver, root) {
  let _element = root;
  const _locator = _By.css(`iframe[title='Body Text Editor Container']`);
  return _element.findElement(_locator);
}

export default class BodyTextEditorContainer extends _UtamBaseRootPageObject {
  constructor(driver, element, locator = _By.css(`body`)) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBodyTextEdtor() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_bodyTextEdtor(driver, root);
    element = new _FrameUtamElement(driver, element);
    return element;
  }

  async enterBodyTextEditorIframe() {
    const _statement0 = await this.getDocument();
    await _statement0.enterFrame(
      await this.__getBodyTextEdtor(),
      _BodyTextEditor
    );
  }
}
