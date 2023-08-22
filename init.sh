#!/usr/bin/env sh

set -e

POSIXLY_CORRECT=1

usage() {
  echo "Usage: $0 [-h] name"
}

is_valid_name() {
  len=$(expr "$1" : '[[:alpha:]][[:alnum:]_]*$')
  [ "$1" != python_template ] && [ "${len}" -ne 0 ]
}

regularize_name() {
  echo "$1" | sed "s/--*/-/g"
}

sed_in_place() {
  tmpf=$2-tmp
  sed "$1" "$2" > "${tmpf}" && mv "${tmpf}" "$2"
}

while getopts h opt
do
  case "${opt}" in
    h)
      usage
      echo "Rename project template."
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

shift $((OPTIND - 1))

if [ "$#" -ne 1 ]
then
  usage
  exit 1
fi

name=$1
if ! is_valid_name "${name}"
then
  echo "Invalid name: ${name}" >&2
  exit 1
fi

git mv src/python_template src/"${name}"
for f in hatch.toml .gitignore
do
  sed_in_place "s/python_template/${name}/g" "${f}"
done

reg_name=$(regularize_name "${name}")
for f in pyproject.toml README.md
do
  sed_in_place "s/python-template/${reg_name}/g" "${f}"
done
