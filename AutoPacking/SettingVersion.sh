# ==================== 公共部分 =====================
# ######### 脚本样式 #############
__TITLE_LEFT_COLOR="\033[36;1m==== "
__TITLE_RIGHT_COLOR=" ====\033[0m"

__USER_INPUT_LEFT="\033[36:1m↳输入了: "

__OPTION_LEFT_COLOR="\033[33;1m"
__OPTION_RIGHT_COLOR="\033[0m"

__LINE_BREAK_LEFT="\033[32;1m"
__LINE_BREAK_RIGHT="\033[0m"

# 红底白字
__ERROR_MESSAGE_LEFT="\033[41m ! ! ! "
__ERROR_MESSAGE_RIGHT=" ! ! ! \033[0m"

# xcode version
XCODE_BUILD_VERSION=$(xcodebuild -version)
echo "-------------- Xcode版本: $XCODE_BUILD_VERSION -------------------"

# 打印信息
function printMessage() {
  pMessage=$1
  echo "${__LINE_BREAK_LEFT}${pMessage}${__LINE_BREAK_RIGHT}"
}

__BUILD_TARGET=("$(basename "$(dirname "$PWD")")")

cd ../
__PROGECT_PATH=`pwd`



# 获取项目名称
__PROJECT_NAME=`find . -name *.xcodeproj | awk -F "[/.]" '{print $(NF-1)}'`
# 已经指定Target的Info.plist文件路径 【配置Info.plist的名称】
__CURRENT_INFO_PLIST_NAME="Info.plist"
# 获取 Info.plist 路径  【配置Info.plist的路径】
__CURRENT_INFO_PLIST_PATH="${__PROJECT_NAME}/${__CURRENT_INFO_PLIST_NAME}"
# 获取版本号
__BUNDLE_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" ${__CURRENT_INFO_PLIST_PATH}`
# 包名
__BUNDLE_Name=`/usr/libexec/PlistBuddy -c "Print CFBundleName" ${__CURRENT_INFO_PLIST_PATH}`
# 获取编译版本号
__BUNDLE_BUILD_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" ${__CURRENT_INFO_PLIST_PATH}`

# input Bundle Version
__BUNDLE_VERSION_INPUT="0"

# 等待用户输入时间
__WAIT_ELECT_TIME=0.2

## 1.设置Bundle Version
echo "${__TITLE_LEFT_COLOR}请输入Bundle Version,输入0或回车视为不更改Bundle Version(当前Bundle Version:$__BUNDLE_VERSION) ${__TITLE_RIGHT_COLOR}"
read __BUNDLE_VERSION_INPUT
if [ "$__BUNDLE_VERSION_INPUT" == "" ]
then
  echo "\033[36:1m↳未输入Bundle Version , 保留原Bundle Version: $__BUNDLE_VERSION"
elif [ "$__BUNDLE_VERSION_INPUT" == "0" ]
then
  echo "\033[36:1m↳输入了: $__BUNDLE_VERSION_INPUT , 保留Bundle Version: $__BUNDLE_VERSION"
else
  __BUNDLE_VERSION=$__BUNDLE_VERSION_INPUT
  echo "\033[36:1m↳输入了: $__BUNDLE_VERSION_INPUT , 设置Bundle Version: $__BUNDLE_VERSION_INPUT"
fi
echo ""

## 2.Bundle Build Version
echo "${__TITLE_LEFT_COLOR}请输入Bundle Build Version,输入0或回车视为不更改Bundle Build Version(当前Bundle Build Version:$__BUNDLE_BUILD_VERSION) ${__TITLE_RIGHT_COLOR}"
read __BUNDLE_BUILD_VERSION_INPUT
if [ "$__BUNDLE_BUILD_VERSION_INPUT" == "" ]
then
  echo "\033[36:1m↳未输入Bundle Build Version , 保留原Bundle Build Version: $__BUNDLE_BUILD_VERSION"
elif [ "$__BUNDLE_BUILD_VERSION_INPUT" == "0" ]
then
  echo "\033[36:1m↳输入了: $__BUNDLE_BUILD_VERSION_INPUT , 保留原Bundle Build Version: $__BUNDLE_BUILD_VERSION"
else
  __BUNDLE_BUILD_VERSION=$__BUNDLE_BUILD_VERSION_INPUT
  echo "\033[36:1m↳输入了: $__BUNDLE_BUILD_VERSION_INPUT , 设置Bundle Build Version号为: $__BUNDLE_BUILD_VERSION_INPUT"
fi
echo ""

#修改版本号
#xcrun agvtool new-marketing-version
xcrun agvtool new-marketing-version "$__BUNDLE_VERSION"

#xcrun agvtool next-version -all
#设置编译版本
xcrun agvtool new-version -all "$__BUNDLE_BUILD_VERSION"

sleep 1

# Xcode11 以上版本
if [[ $XCODE_BUILD_VERSION =~ "Xcode 11" || $XCODE_BUILD_VERSION =~ "Xcode11" ]]; then
  __BUNDLE_VERSION_TAG="MARKETING_VERSION"
  __BUNDLE_BUILD_VERSION_TAG="CURRENT_PROJECT_VERSION"
  __PROJECT_ROOT_PATH=`find . -name *.xcodeproj`
  __PBXPROJ_PATH="$__PROJECT_ROOT_PATH/project.pbxproj"
  __BUNDLE_VERSION_11=$(grep "${__BUNDLE_VERSION_TAG}" $__PBXPROJ_PATH | head -1 | awk -F '=' '{print $2}' | awk -F ';' '{print $1}' | sed s/[[:space:]]//g)
  __BUNDLE_BUILD_VERSION_11=$(grep "${__BUNDLE_BUILD_VERSION_TAG}" $__PBXPROJ_PATH | head -1 | awk -F '=' '{print $2}' | awk -F ';' '{print $1}' | sed s/[[:space:]]//g)

  # if [[ -n "$__BUNDLE_VERSION_11" ]]; then
  #   __BUNDLE_VERSION="$__BUNDLE_VERSION_11";
  # fi

  if [[ -n "$__BUNDLE_BUILD_VERSION_11" ]]; then
    __BUNDLE_BUILD_VERSION="$__BUNDLE_BUILD_VERSION_11";
  fi
fi

printMessage "----------------------------------------------------------"
printMessage "  工程名: $__BUILD_TARGET"
printMessage "  包名: $__BUNDLE_Name"
printMessage "  当前版本 Bundle Version: ${__BUNDLE_VERSION}"
printMessage "  当前版本 Bundle Build Version: ${__BUNDLE_BUILD_VERSION}"
printMessage "----------------------------------------------------------"

exit
