"use strict";

var core = require("@utam/core");
var _BodyTextEditor = require("./../pageObjects/bodyTextEditor");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _BodyTextEditor__default =
  /*#__PURE__*/ _interopDefaultLegacy(_BodyTextEditor);

async function _utam_get_bodyTextEdtor(driver, root) {
  let _element = root;
  const _locator = core.By.css(`iframe[title='Body Text Editor Container']`);
  return _element.findElement(_locator);
}

class BodyTextEditorContainer extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getBodyTextEdtor() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_bodyTextEdtor(driver, root);
    element = new core.FrameUtamElement(driver, element);
    return element;
  }

  async enterBodyTextEditorIframe() {
    const _statement0 = await this.getDocument();
    await _statement0.enterFrame(
      await this.__getBodyTextEdtor(),
      _BodyTextEditor__default["default"]
    );
  }
}

module.exports = BodyTextEditorContainer;
