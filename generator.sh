#!/bin/sh

SCRIPT="$0"
echo "# START SCRIPT: $SCRIPT"

COMMIT="true"
SWAGGER_VERSION=
SDK_VERSION=

echo_usage() {
	echo "Usage: $0 -s swagger_version -c commit"
	echo ""
	echo "-s swagger_version the tag of the swagger file in it git repo"
	echo "-c commit the generated code in to github repo [OPTIONAL], default: true"
	echo "-h  print help"
}

while getopts :s:c:h opt; do
  case $opt in
    s) 
		SWAGGER_VERSION=$OPTARG 
		;;
    c) 
		COMMIT=$OPTARG 
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

CURRENTDATETIME=`date +"%Y%m%d.%H%M%S"`
SDK_VERSION="1.0.0"
SDK_TAG="${SWAGGER_VERSION}/${CURRENTDATETIME}"

SDK_GEN_FOLDER="sdk-php"
SDK_REPO_FOLDER="sdk-repo"
SWAGGER_REPO_FOLDER="swagger-file"
URL="${SWAGGER_REPO_FOLDER}/openapi.json"
SWAGGER_REPO="https://github.com/krishnakumarkp/bookstore-swagger.git"
SDK_REPO="git@github.com:krishnakumarkp/sdk-php.git"

echo "generating sdk version $SDK_VERSION"
COMMIT_MSG="Generated at $(date) with swagger file version $SWAGGER_VERSION"

delete_folder_if_exists(){
    folder=$1

    if [ -d "./$folder" ]; then
        rm -rf $folder
        echo "delete $folder "
    fi
}

#delete folder before the build
delete_folder_if_exists $SDK_GEN_FOLDER

#this is to checkout the swagger file
delete_folder_if_exists $SWAGGER_REPO_FOLDER

git clone --depth 1 --branch $SWAGGER_VERSION $SWAGGER_REPO $SWAGGER_REPO_FOLDER
echo "clone $SWAGGER_VERSION version of swaggerfile to $SWAGGER_REPO_FOLDER"

if [ ! -d "$SWAGGER_REPO_FOLDER" ]; then
  echo "Error: ${SWAGGER_REPO_FOLDER} not found. Can not continue."
  exit 1
fi

echo "checked out swagger file"

executable="./generator_cli/openapi-generator-cli.jar"

java -jar $executable generate -t ./templates/swagger/php -i $URL -g php -o $SDK_GEN_FOLDER --package-name "Book store APIs Client Library for PHP" --invoker-package Bookstore\\Client --artifact-version $SDK_VERSION --git-user-id Krishnakumarkp --git-repo-id sdk-php --skip-validate-spec

if [ ! -d "$SDK_GEN_FOLDER" ]; then
  echo "Error: ${SDK_GEN_FOLDER} not found. Can not continue."
  exit 1
fi

#checkout the repo for generated code
delete_folder_if_exists $SDK_REPO_FOLDER
git clone $SDK_REPO $SDK_REPO_FOLDER
echo "clone $SDK_REPO_FOLDER"

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
#start commit

if [ "$COMMIT" = "true" ]; then
	echo "$COMMIT_MSG"
	git add .
	git commit -a -m "$COMMIT_MSG"
	git push origin master
	git tag $SDK_TAG
	git push origin $SDK_TAG
	echo "git pushed"
fi