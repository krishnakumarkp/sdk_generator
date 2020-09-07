#!/bin/sh

SCRIPT="$0"
echo "# START SCRIPT: $SCRIPT"

echo_usage() {
	echo "Usage: $0 -s swagger_version"
	echo ""
	echo "-s swagger_version the tag of the swagger file in git repo"
	echo "-h  print help"
}

SWAGGER_VERSION=
while getopts :s:c:h opt; do
  case $opt in
    s) 
		SWAGGER_VERSION=$OPTARG 
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

COMMIT="true"
CURRENTDATETIME=`date +"%Y%m%d.%H%M%S"`
SDK_TAG="${SWAGGER_VERSION}.${CURRENTDATETIME}"
SDK_GEN_FOLDER="sdk-php"
SDK_REPO_FOLDER="sdk-repo"
SDK_REPO="git@github.com:krishnakumarkp/sdk-php.git"
COMMIT_MSG="Generated at $(date)"
TAG_MSG="Generated at $(date)"
delete_folder_if_exists(){
    folder=$1

    if [ -d "./$folder" ]; then
        rm -rf $folder
        echo "delete $folder "
    fi
}

#checkout the repo for generated code
delete_folder_if_exists $SDK_REPO_FOLDER
git clone $SDK_REPO $SDK_REPO_FOLDER
echo "clone $SDK_REPO_FOLDER"

if [ ! -d "$SDK_REPO_FOLDER" ]; then
  echo "Error: ${SDK_REPO_FOLDER} not found. Can not continue."
  exit 1
fi

if [ ! -d "$SDK_GEN_FOLDER" ]; then
  echo "Error: ${SDK_GEN_FOLDER} not found. Can not continue."
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
	git tag -a $SDK_TAG -m "$TAG_MSG"
	git push origin $SDK_TAG
	echo "git pushed"
fi