{
  description = "Android dev";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          system = system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        };
        buildToolsVersion = "34.0.0";

        android = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "11.0";
          # toolsVersion = "26.1.1";
          platformToolsVersion = "34.0.5";
          buildToolsVersions = [ buildToolsVersion ];
          includeEmulator = true;
          # emulatorVersion = "30.3.4";
          includeSystemImages = true;
          platformVersions = [ "21" "30" "34" ];
          abiVersions = [ "x86_64" ];
        };
        android-studio = pkgs.androidStudioPackages.canary;

      in {
        inherit android;
        devShells.default = pkgs.mkShell rec {
          ANDROID_SDK_ROOT = "${android.androidsdk}/libexec/android-sdk";
          ANDROID_HOME = ANDROID_SDK_ROOT;

          # Use the same buildToolsVersion here
          GRADLE_OPTS =
            "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_SDK_ROOT}/build-tools/${buildToolsVersion}/aapt2";

          packages = with pkgs; [
            android.platform-tools
            android.emulator
            android.androidsdk
            temurin-bin-17
            android-studio
            watchman
          ];
        };
      });
}
