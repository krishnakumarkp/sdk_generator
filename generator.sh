#!/bin/sh

SCRIPT="$0"
echo "# START SCRIPT: $SCRIPT"


PARAMS_VERSION="0.1"

URL="swagger_file/openapi.json"

SDK_GEN_FOLDER="sdk-php"
SDK_REPO_FOLDER="sdk-repo"

echo " version: $PARAMS_VERSION " 

delete_folder_if_exists(){
    folder=$1

    if [ -d "./$folder" ]; then
        rm -rf $folder
        echo "delete $folder "
    fi
}

#delete folder before the build
delete_folder_if_exists $SDK_GEN_FOLDER

executable="./generator_cli/openapi-generator-cli.jar"

java -jar $executable generate -t ./templates/swagger/php -i $URL -g php -o $SDK_GEN_FOLDER --package-name "Book store APIs Client Library for PHP" --invoker-package Bookstore\\Client --artifact-version $PARAMS_VERSION --git-user-id Krishnakumarkp --git-repo-id sdk-php  --skip-validate-spec

if [ ! -d "$SDK_GEN_FOLDER" ]; then
  echo "Error: ${SDK_GEN_FOLDER} not found. Can not continue."
  exit 1
fi

#mkdir $SDK_REPO_FOLDER

if [ ! -d "$SDK_REPO_FOLDER" ]; then
  echo "Error: ${SDK_REPO_FOLDER} not found. Can not continue."
  exit 1
fi

#into the repo
cd $SDK_REPO_FOLDER
#clean up the repo folder; remove everything except .git folder
find -maxdepth 1 ! -name .git ! -name . -exec rm -rv {} \;
#copy the generated code into repo
cp -a ../$SDK_GEN_FOLDER/. .
echo "copy $SDK_GEN_FOLDER to $SDK_REPO_FOLDER "