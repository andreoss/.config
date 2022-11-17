{ config, pkgs, lib, stdenv, self, ... }:
let androidComposition = pkgs.androidenv.composeAndroidPackages {
    abiVersions = [ "armeabi-v7a" "arm64-v8a" "x86_64" ];
    buildToolsVersions = [ "26.0.1" "31.0.0" ];
    cmakeVersions = [ "3.10.2" ];
    emulatorVersion = "30.3.4";
    includeEmulator = false;
    includeNDK = true;
    includeSources = false;
    includeSystemImages = false;
    ndkVersions = [ "21.1.6352462" ];
    platformVersions = [ "29" "31" ];
    toolsVersion = "26.0.1";
  };
in
{
  nixpkgs.config = {
    android_sdk.accept_license = true;
  };
  home.sessionVariables = {
    ANDROID_SDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk";
    ANDROID_NDK_ROOT = "${androidComposition.androidsdk}/libexec/android-sdk/ndk-bundle";
  };
}
