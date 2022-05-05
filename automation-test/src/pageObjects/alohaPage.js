"use strict";

var core = require("@utam/core");
var _BodyTextEditorContainer = require("./../pageObjects/bodyTextEditorContainer");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _BodyTextEditorContainer__default = /*#__PURE__*/ _interopDefaultLegacy(
  _BodyTextEditorContainer
);

async function _utam_get_bodyEditorContainer(driver, root) {
  let _element = root;
  const _locator = core.By.css(`iframe[title='Body Text Editor Container']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class AlohaPage extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBodyEditorContainer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_bodyEditorContainer(driver, root);
    element = new core.FrameUtamElement(driver, element);
    return element;
  }

  async enterBodyTextEditorContainerIframe() {
    const _statement0 = await this.getDocument();
    await _statement0.enterFrame(
      await this.__getBodyEditorContainer(),
      _BodyTextEditorContainer__default["default"]
    );
  }
}

module.exports = AlohaPage;
