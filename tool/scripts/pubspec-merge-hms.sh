#!/bin/sh
cp pubspec.yaml pubspec-tmp.yaml
yaml-merge pubspec-tmp.yaml pubspec-hms.yaml > pubspec.yaml
rm pubspec-tmp.yaml