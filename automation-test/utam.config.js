module.exports = {
  pageObjectsRootDir: "./", // config file directory name
  pageObjectsFileMask: ["src/utam/**/*.utam.json"],
  pageObjectsOutputDir: "src/pageObjects",
  // remap custom elements imports
  alias: {
    "utam-*/": "./../"
  }
};
