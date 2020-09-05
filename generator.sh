#!/bin/sh

SCRIPT="$0"
echo "# START SCRIPT: $SCRIPT"

SWAGGER_VERSION=

echo_usage() {
	echo "Usage: $0 -s swagger_version -v sdkversion"
	echo ""
	echo "-s swagger_version the tag of the swagger file in it git repo"
	echo "-v sdk version to be specified in documentation"
	echo "-h  print help"
}

SDK_VERSION="1.0.0"

while getopts :s:c:h opt; do
  case $opt in
    s) 
		SWAGGER_VERSION=$OPTARG 
		;;
	v) 
		SDK_VERSION=$OPTARG 
		;;
    h) 
		echo_usage 
		exit 0 
		;;
	\?)
		echo "Unknown option: -$OPTARG"
		echo_usage
		exit 1
		;;
  esac
done

if [ -z "$SWAGGER_VERSION" ]
then
    echo "No swagger version specified, Can not continue."
	exit 1
fi

SDK_GEN_FOLDER="sdk-php"
SWAGGER_REPO_FOLDER="swagger-file"
URL="${SWAGGER_REPO_FOLDER}/openapi.json"
SWAGGER_REPO="https://github.com/krishnakumarkp/bookstore-swagger.git"


echo "generating sdk version $SDK_VERSION"

delete_folder_if_exists(){
    folder=$1

    if [ -d "./$folder" ]; then
        rm -rf $folder
        echo "delete $folder "
    fi
}

#delete folder before the build
delete_folder_if_exists $SDK_GEN_FOLDER

#this is to checkout the swagger fileP
delete_folder_if_exists $SWAGGER_REPO_FOLDER

git clone --depth 1 --branch $SWAGGER_VERSION $SWAGGER_REPO $SWAGGER_REPO_FOLDER
echo "clone $SWAGGER_VERSION version of swaggerfile to $SWAGGER_REPO_FOLDER"

if [ ! -d "$SWAGGER_REPO_FOLDER" ]; then
  echo "Error: ${SWAGGER_REPO_FOLDER} not found. Can not continue."
  exit 1
fi

echo "checked out swagger file"

EXECUTABLE="./generator_cli/openapi-generator-cli.jar"

if [ ! -f "$EXECUTABLE" ]; then
    echo "$EXECUTABLE not found. Can not continue."
	exit 1
fi

java -jar $EXECUTABLE generate -t ./templates/swagger/php -i $URL -g php -o $SDK_GEN_FOLDER --package-name "Book store APIs Client Library for PHP" --invoker-package Bookstore\\Client --artifact-version $SDK_VERSION --git-user-id Krishnakumarkp --git-repo-id sdk-php --skip-validate-spec

if [ ! -d "$SDK_GEN_FOLDER" ]; then
  echo "Error: ${SDK_GEN_FOLDER} not found. Can not continue."
  exit 1
fi