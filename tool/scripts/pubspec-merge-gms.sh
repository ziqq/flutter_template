#!/bin/sh
cp pubspec.yaml pubspec-tmp.yaml
yaml-merge pubspec-tmp.yaml pubspec-gms.yaml > pubspec.yaml
rm pubspec-tmp.yaml