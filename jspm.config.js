SystemJS.config({
  baseURL: "assets/scripts",
  paths: {
    "npm:": "jspm_packages/npm/",
    "kotsu/": "source/scripts/"
  },
  devConfig: {
    "map": {
      "plugin-babel": "npm:systemjs-plugin-babel@0.0.21",
      "systemjs-plugin-json": "npm:systemjs-plugin-json@0.3.0"
    }
  },
  meta: {
    "*.json": {
      "loader": "systemjs-plugin-json"
    }
  },
  transpiler: "plugin-babel",
  packages: {
    "kotsu": {
      "main": "main.js",
      "format": "esm",
      "meta": {
        "*.js": {
          "loader": "plugin-babel"
        }
      }
    }
  }
});

SystemJS.config({
  packageConfigPaths: [
    "npm:@*/*.json",
    "npm:*.json"
  ],
  map: {
    "jquery": "npm:jquery@3.2.0"
  },
  packages: {}
});
