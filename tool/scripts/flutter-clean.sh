rm -rf pubspec.lock
flutter clean
cd packages
for dir in */ ; do

    echo ${dir}
    cd ${dir}
    pwd
    rm -rf pubspec.lock
    flutter clean
    cd ..
    pwd
    if [ "$#" -gt 0 ]; then shift; fi
    # shift
done