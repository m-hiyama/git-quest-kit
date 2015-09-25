#!/bin/sh
# -*- coding: utf-8-unix -*-

unset GIT_DIR
. ./git-inspect-functions.sh

#
# 1-1. ワークツリー付き リポジトリ1 を作る
#

git init 1-git-sample
[ $? -eq 0 ] || exit 1
cd 1-git-sample
echo '_*' > .gitignore
# 注意：通常は .gitignore を .gitignore には入れない
echo '.gitignore' >> .gitignore

g_save

#
# 1-2. 最初のコミットを作る
#
# a.txt

echo this is a.txt> a.txt; git add a.txt; git commit -m first

g_save

#
# 1-3. ブランチを作る
#
# topic

git branch topic

g_save

#
# 1-4. 次のコミットを作る
#
# b.txt
#
# タグを付けておく
# tag_second

echo this is b.txt> b.txt; git add b.txt; git commit -m second
git tag tag_second

g_save

#
# 1-5. 別のブランチでコミットを作る
#
# a.txt modify
# subdir/c.txt

git checkout topic
echo this is modified a.txt> a.txt
mkdir subdir
echo this is c.txt> subdir/c.txt
git add a.txt subdir/c.txt; git commit -m branched

g_save

#
# 1-6. 新しいブランチをmasterにマージする
#

git checkout master
git merge topic -m merged 

g_save

#
# おしまい
#

cd ..
