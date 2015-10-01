#!/bin/sh
# -*- coding: utf-8-unix -*-

unset GIT_DIR
A=3-git-sample

git init $A
[ $? = 0 ] || exit 1

cd $A

echo a> a.txt; git add a.txt; git commit -m 1 # 1
echo b> b.txt; git add b.txt; git commit -m 2 # 2

git checkout --orphan B
echo c> c.txt; git add c.txt; git commit -m 4 # 4

git checkout --orphan other
echo a> a.txt; git add a.txt; git commit -m 7 # 7
echo b2> b.txt; git add b.txt; git commit -m 8 # 8

git checkout master
git branch tmp
git merge B -m 3 # 3

git checkout B
echo d> d.txt; git add d.txt; git commit -m 5 # 5
git merge tmp -m 6 # 6

git checkout B^
git tag tag_master2 B # タグがないと見えなくなるので
git branch -D tmp B

cd ..
