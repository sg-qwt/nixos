{ lib
, orca-slicer
, pkgs
, ...
}:

let
  # Orca Slicer tracks the networking ABI independently of its own version.
  # Orca >= 2.3.2 uses the 02.03.00 ABI series.
  pluginVersion = "02.03.00.99";

  open-bamboo-networking = pkgs.my.open-bamboo-networking.override {
    client = "orca_slicer";
    inherit pluginVersion;
  };
in
orca-slicer.overrideAttrs (oldAttrs: {
  pname = "orca-slicer-open";

  postPatch =
    (oldAttrs.postPatch or "")
    + ''
      # Load the immutable, packaged plugin instead of looking in the user's
      # writable OrcaSlicer plugin directory.
      substituteInPlace src/slic3r/Utils/BBLNetworkPlugin.cpp \
        --replace-fail 'library = plugin_folder.string() + "/" + std::string("lib") + std::string(BAMBU_NETWORK_LIBRARY) + "_" + version + lib_ext;' \
                       'library = "${open-bamboo-networking}/plugins/libbambu_networking_${pluginVersion}.so";' \
        --replace-fail 'library = plugin_folder.string() + "/" + std::string("lib") + std::string(BAMBU_SOURCE_LIBRARY) + ".so";' \
                       'library = "${open-bamboo-networking}/plugins/libBambuSource.so";'

      # Keep Orca from downloading the proprietary plugin, and make the open
      # plugin available even for a fresh or pre-existing configuration.
      substituteInPlace src/slic3r/GUI/GUI_App.cpp \
        --replace-fail '    // Orca: select network plugin version based on configured version string' \
                       $'    app_config->set_bool("installed_networking", true);\n    app_config->set_bool("update_network_plugin", false);\n    app_config->set_network_plugin_version("${pluginVersion}");\n\n    // Orca: select network plugin version based on configured version string'

      substituteInPlace src/slic3r/GUI/WebGuideDialog.cpp \
        --replace-fail '        m_ProfileJson["network_plugin_install"] = wxGetApp().app_config->get("app","installed_networking");' \
                       '        m_ProfileJson["network_plugin_install"] = "1";' \
        --replace-fail '        m_ProfileJson["network_plugin_compability"] = wxGetApp().is_compatibility_version() ? "1" : "0";' \
                       '        m_ProfileJson["network_plugin_compability"] = "1";' \
        --replace-fail '        network_plugin_ready = wxGetApp().is_compatibility_version();' \
                       '        network_plugin_ready = true;'

      substituteInPlace resources/web/guide/5/5.js \
        --replace-fail $'\tTranslatePage();' $'\tFinishGuide(); return;'
    '';

  meta = oldAttrs.meta // {
    description = "Orca Slicer with the open-bamboo-networking plugin";
    license = lib.licenses.agpl3Only;
  };
})
