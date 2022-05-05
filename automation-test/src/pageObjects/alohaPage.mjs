import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  FrameUtamElement as _FrameUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _BodyTextEditorContainer from "./../pageObjects/bodyTextEditorContainer";

async function _utam_get_bodyEditorContainer(driver, root) {
  let _element = root;
  const _locator = _By.css(`iframe[title='Body Text Editor Container']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class AlohaPage extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBodyEditorContainer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_bodyEditorContainer(driver, root);
    element = new _FrameUtamElement(driver, element);
    return element;
  }

  async enterBodyTextEditorContainerIframe() {
    const _statement0 = await this.getDocument();
    await _statement0.enterFrame(
      await this.__getBodyEditorContainer(),
      _BodyTextEditorContainer
    );
  }
}
