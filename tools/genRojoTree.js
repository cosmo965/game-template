const fs = require("fs");
const path = require("path");

const BASE_PATH = path.join(__dirname, "../src");

function toPosix(p) {
  return p.split(path.sep).join("/");
}

function toPascalCase(str) {
  if (str.toLowerCase() === "ui") return "UI";
  return str.charAt(0).toUpperCase() + str.slice(1);
}

function srcPath(...parts) {
  return toPosix(path.join("src", ...parts));
}

const tree = {
  name: "genrojotree",
  tree: {
    $className: "DataModel",

    ReplicatedStorage: {
      Client: {
        $className: "Folder",
        Features: { $className: "Folder" },
        UI: { $path: "src/ui" },
      },
      Packages: { $path: "Packages" },
      Shared: {
        $className: "Folder",
        Features: { $className: "Folder" },
        Modules: { $className: "Folder" },
        ClientLoaded: { $path: "src/runtime/ClientLoaded.luau" },
      },
    },

    ServerScriptService: {
      Server: {
        $className: "Folder",
        Features: { $className: "Folder" },
      },
      Runtime: { $path: "src/runtime/Runtime.server.luau" },
    },

    StarterPlayer: {
      StarterPlayerScripts: {
        Runtime: { $path: "src/runtime/Runtime.client.luau" },
      },
    },

    ReplicatedFirst: {
      ReplicatedFirst: { $path: "src/runtime/ReplicatedFirst.client.luau" },
    }
  },
};

const clientFeatures = tree.tree.ReplicatedStorage.Client.Features;
const sharedFeatures = tree.tree.ReplicatedStorage.Shared.Features;
const serverFeatures = tree.tree.ServerScriptService.Server.Features;

function mapFeature(featDirName) {
  const featureName = toPascalCase(featDirName);
  const featDir = path.join(BASE_PATH, "features", featDirName);

  const clientDir = path.join(featDir, "client");
  const sharedDir = path.join(featDir, "shared");
  const serverDir = path.join(featDir, "server");
  const uiDir     = path.join(featDir, "ui");

  const controllerLuau  = path.join(clientDir, "Controller.luau");
  const clientUtilsLuau = path.join(clientDir, "Utils.luau");
  const handlerLuau     = path.join(sharedDir, "Handler.luau");
  const sharedUtilsLuau = path.join(sharedDir, "Utils.luau");
  const serviceLuau     = path.join(serverDir, "Service.luau");
  const serverUtilsLuau = path.join(serverDir, "Utils.luau");

  const controllerName = `${featureName}Controller`;
  const handlerName    = `${featureName}Handler`;
  const serviceName    = `${featureName}Service`;
  const utilsName      = `${featureName}Utils`;

  // Client: UI + Controller + Utils
  const clientNode = { $className: "Folder" };
  if (fs.existsSync(uiDir) && fs.statSync(uiDir).isDirectory()) {
    const uiNode = { $className: "Folder" };
    for (const sub of fs.readdirSync(uiDir, { withFileTypes: true })) {
      if (!sub.isDirectory()) continue;
      uiNode[sub.name] = { $path: srcPath("features", featDirName, "ui", sub.name) };
    }
    if (Object.keys(uiNode).length > 1) clientNode.UI = uiNode;
  }
  if (fs.existsSync(controllerLuau)) {
    clientNode[controllerName] = { $path: srcPath("features", featDirName, "client", "Controller.luau") };
  }
  if (fs.existsSync(clientUtilsLuau)) {
    clientNode[utilsName] = { $path: srcPath("features", featDirName, "client", "Utils.luau") };
  }
  if (Object.keys(clientNode).length > 1) {
    clientFeatures[featureName] = clientNode;
  }

  // Shared: Handler + Utils + Remotes
  const sharedNode = { $className: "Folder" };
  if (fs.existsSync(handlerLuau)) {
    sharedNode[handlerName] = { $path: srcPath("features", featDirName, "shared", "Handler.luau") };
  }
  if (fs.existsSync(sharedUtilsLuau)) {
    sharedNode[utilsName] = { $path: srcPath("features", featDirName, "shared", "Utils.luau") };
  }
  const remoteLuau = path.join(sharedDir, "Remote.luau");
  if (fs.existsSync(remoteLuau)) {
    sharedNode[`${featureName}Remote`] = { $path: srcPath("features", featDirName, "shared", "Remote.luau") };
  }
  if (Object.keys(sharedNode).length > 1) {
    sharedFeatures[featureName] = sharedNode;
  }

  // Server: Utils + Service
  const serverNode = { $className: "Folder" };
  if (fs.existsSync(serverUtilsLuau)) {
    serverNode[utilsName] = { $path: srcPath("features", featDirName, "server", "Utils.luau") };
  }
  if (fs.existsSync(serviceLuau)) {
    serverNode[serviceName] = { $path: srcPath("features", featDirName, "server", "Service.luau") };
  }
  if (Object.keys(serverNode).length > 1) {
    serverFeatures[featureName] = serverNode;
  }
}

const featuresDir = path.join(BASE_PATH, "features");
if (fs.existsSync(featuresDir)) {
  for (const entry of fs.readdirSync(featuresDir, { withFileTypes: true })) {
    if (entry.isDirectory()) mapFeature(entry.name);
  }
}

fs.writeFileSync("default.project.json", JSON.stringify(tree, null, 2));
console.log("✅ default.project.json generated.");
