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

  const stateDir        = path.join(featDir, "state");
  const clientSliceLuau  = path.join(stateDir, "Client.luau");
  const sharedSliceLuau  = path.join(stateDir, "Shared.luau");
  const serverSliceLuau  = path.join(stateDir, "Server.luau");

  const controllerName      = `${featureName}Controller`;
  const handlerName         = `${featureName}Handler`;
  const serviceName         = `${featureName}Service`;
  const clientUtilsName     = `${featureName}ControllerUtils`;
  const sharedUtilsName     = `${featureName}HandlerUtils`;
  const serverUtilsName     = `${featureName}ServiceUtils`;

  // Client: UI + Controller + Utils
  // Recognized ui/ subfolders: Components, HUD, Menu, Stories.
  // Stories holds UI Labs `.story.luau` files used for hot-reload previews
  // in Studio (Roblox dev). Any other subfolder is also picked up generically.
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
    clientNode[clientUtilsName] = { $path: srcPath("features", featDirName, "client", "Utils.luau") };
  }
  if (fs.existsSync(stateDir) && fs.existsSync(clientSliceLuau)) {
    clientNode[`${featureName}ClientSlice`] = { $path: srcPath("features", featDirName, "state", "Client.luau") };
  }
  // Map any extra .luau files in client/ that aren't already mapped (Controller.luau, Utils.luau)
  if (fs.existsSync(clientDir)) {
    const knownClientFiles = new Set(["Controller.luau", "Utils.luau"]);
    for (const f of fs.readdirSync(clientDir)) {
      if (!f.endsWith(".luau") || knownClientFiles.has(f)) continue;
      const baseName = f.slice(0, -5); // strip .luau
      clientNode[baseName] = { $path: srcPath("features", featDirName, "client", f) };
    }
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
    sharedNode[sharedUtilsName] = { $path: srcPath("features", featDirName, "shared", "Utils.luau") };
  }
  const remoteLuau = path.join(sharedDir, "Remote.luau");
  if (fs.existsSync(remoteLuau)) {
    sharedNode[`${featureName}Remote`] = { $path: srcPath("features", featDirName, "shared", "Remote.luau") };
  }
  if (fs.existsSync(stateDir) && fs.existsSync(sharedSliceLuau)) {
    sharedNode[`${featureName}SharedSlice`] = { $path: srcPath("features", featDirName, "state", "Shared.luau") };
  }
  // Map any extra .luau files in shared/ that aren't already mapped (Handler.luau, Utils.luau, Remote.luau)
  if (fs.existsSync(sharedDir)) {
    const knownSharedFiles = new Set(["Handler.luau", "Utils.luau", "Remote.luau"]);
    for (const f of fs.readdirSync(sharedDir)) {
      if (!f.endsWith(".luau") || knownSharedFiles.has(f)) continue;
      const baseName = f.slice(0, -5); // strip .luau
      sharedNode[baseName] = { $path: srcPath("features", featDirName, "shared", f) };
    }
  }
  if (Object.keys(sharedNode).length > 1) {
    sharedFeatures[featureName] = sharedNode;
  }

  // Server: Utils + Service + any extra .luau files in server/ (e.g. Config, Template, Internal, ProfileStore)
  const serverNode = { $className: "Folder" };
  if (fs.existsSync(serverUtilsLuau)) {
    serverNode[serverUtilsName] = { $path: srcPath("features", featDirName, "server", "Utils.luau") };
  }
  if (fs.existsSync(serviceLuau)) {
    serverNode[serviceName] = { $path: srcPath("features", featDirName, "server", "Service.luau") };
  }
  if (fs.existsSync(stateDir) && fs.existsSync(serverSliceLuau)) {
    serverNode[`${featureName}ServerSlice`] = { $path: srcPath("features", featDirName, "state", "Server.luau") };
  }
  // Map any extra .luau files in server/ that aren't already mapped (Utils.luau, Service.luau)
  if (fs.existsSync(serverDir)) {
    const knownServerFiles = new Set(["Utils.luau", "Service.luau"]);
    for (const f of fs.readdirSync(serverDir)) {
      if (!f.endsWith(".luau") || knownServerFiles.has(f)) continue;
      const baseName = f.slice(0, -5); // strip .luau
      serverNode[baseName] = { $path: srcPath("features", featDirName, "server", f) };
    }
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
