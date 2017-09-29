SystemJS.config({
  baseURL: "/source/scripts",
  browserConfig: {
    "paths": {
      "npm:": "/jspm_packages/npm/",
      "github:": "/jspm_packages/github/",
      "main/": ""
    }
  },
  nodeConfig: {
    "paths": {
      "npm:": "jspm_packages/npm",
      "github:": "jspm_packages/github",
      "main/": "source/scripts/"
    }
  },
  devConfig: {
    "map": {
      "plugin-babel": "npm:systemjs-plugin-babel@0.0.21",
      "systemjs-hot-reloader": "npm:systemjs-hot-reloader@1.1.0",
      "systemjs-plugin-json": "npm:systemjs-plugin-json@0.3.0"
    },
    "packages": {
      "npm:systemjs-hot-reloader@1.1.0": {
        "map": {
          "systemjs-hmr": "npm:systemjs-hmr@2.0.9"
        }
      }
    }
  },
  transpiler: "plugin-babel",
  packages: {
    "main": {
      "main": "main.js",
      "format": "esm",
      "meta": {
        "*.js": {
          "loader": "plugin-babel"
        },
        "*.json": {
          "loader": "systemjs-plugin-json"
        }
      }
    }
  },
  map: {
    "@hot": "@empty"
  }
});

SystemJS.config({
  packageConfigPaths: [
    "npm:@*/*.json",
    "npm:*.json"
  ],
  map: {
    "babel-polyfill": "npm:babel-polyfill@6.23.0",
    "fs": "npm:jspm-nodelibs-fs@0.2.1",
    "jquery": "npm:jquery@3.2.0",
    "path": "npm:jspm-nodelibs-path@0.2.3",
    "process": "npm:jspm-nodelibs-process@0.2.1"
  },
  packages: {
    "npm:babel-polyfill@6.23.0": {
      "map": {
        "babel-runtime": "npm:babel-runtime@6.23.0",
        "core-js": "npm:core-js@2.4.1",
        "regenerator-runtime": "npm:regenerator-runtime@0.10.5"
      }
    },
    "npm:babel-runtime@6.23.0": {
      "map": {
        "core-js": "npm:core-js@2.4.1",
        "regenerator-runtime": "npm:regenerator-runtime@0.10.5"
      }
    }
  }
});
