#!/bin/sh
# -*- coding: utf-8-unix -*-

unset GIT_DIR
. ./git-inspect-functions.sh

#
# 2-1. 別な リポジトリ2 を作る
#

git init 2-git-sample
[ $? -eq 0 ] || exit 1
cd 2-git-sample
mv .git ../repo-2-git-sample.git
[ $? -eq 0 ] ||  exit 1
echo 'gitdir: ../repo-2-git-sample.git' > .git
echo '_*' > .gitignore
# 注意：通常は .gitignore を .gitignore には入れない
echo '.gitignore' >> .gitignore

g_save

#
# 2-2. 最初のコミットを作る
#
# a.txt

echo this is a.txt> a.txt; git add a.txt; git commit -m 'first in 2'

g_save

#
# 2-3. 次のコミットを作る
#
# b.txt one line added
# d.txt

echo this is b.txt> b.txt
echo this is d.txt> d.txt
git add b.txt d.txt; git commit -m 'second in 2'

g_save

#
# 2-4. サンプル1 に戻ってリモート指定をする
#

cd ../1-git-sample
[ $? -eq 0 ] ||  exit 1
git remote add  origin ../repo-2-git-sample.git

g_save

#
# おしまい
#

cd ..
