#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# ─── 헬퍼 함수 ────────────────────────────────────────────────────────────────

# 사용법 안내
usage() {
  echo "Usage: $(basename "$0") <package-name>"
  echo "  예) $(basename "$0") assets-release-kit"  # 또는 packages/cli 등 상대 경로
  exit 1
}

# 경로 정규화: INIT_CWD와 npm prefix 기준으로 상대경로 산출
normalizePath() {
  local pkg="$1"
  local initCwd="${INIT_CWD%/}"
  local absDir="$initCwd/$pkg"

  # 디렉터리 존재 여부 확인
  if [[ ! -d "$absDir" ]]; then
    echo "🚫 Error: package directory not found at '$absDir'" >&2
    exit 1
  fi

  # 실제 경로로 정규화
  local canonDir
  canonDir=$(cd "$absDir" && pwd)

  # npm prefix를 기준으로 상대경로 생성
  local prefix
  prefix=$(npm prefix)
  local relPath=".${canonDir#$prefix}"

  echo "$relPath"
}

# package.json 파일 존재 검사
checkPackageJson() {
  local pkgJson="$1/package.json"
  if [[ ! -f "$pkgJson" ]]; then
    echo "🚫 Error: package.json not found at '$pkgJson'" >&2
    exit 1
  fi
}

# publishConfig 값을 머지: 기존 publishConfig 필드는 유지
mergePublishConfig() {
  local pkgDir="$1"
  local pkgJsonFile="$pkgDir/package.json"

  jq 'if has("publishConfig") then . *= .publishConfig else . end' \
    "$pkgJsonFile" > "$pkgJsonFile.tmp" \
    && mv "$pkgJsonFile.tmp" "$pkgJsonFile"

  echo "✔ publishConfig values merged into package.json"
}

# 의존성 설치 (yarn 또는 npm 선택)
installDependencies() {
  local pkgDir="$1"

  if command -v yarn &>/dev/null; then
    yarn --cwd "$pkgDir"
  else
    npm install --prefix "$pkgDir"
  fi
}

# ─── 메인 로직 ────────────────────────────────────────────────────────────────

main() {
  [[ $# -eq 1 ]] || usage

  local packageName="$1"
  local relativePath
  relativePath=$(normalizePath "$packageName")

  checkPackageJson "$relativePath"
  echo "▶ Working on package at: $relativePath"

  mergePublishConfig "$relativePath"
  installDependencies "$relativePath"

  echo "✅ Done!"
}

main "$@"
