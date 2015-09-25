#!/bin/sh
# -*- coding: utf-8-unix -*-

unset GIT_DIR
A=3-git-sample
B=_tmpB
C=_tmpC

git init $A
[ $? = 0 ] || exit 1
git init $B
[ $? = 0 ] || exit 1
git init $C
[ $? = 0 ] || exit 1

cd $A
echo a> a.txt; git add a.txt; git commit -m 1 # 1
echo b> b.txt; git add b.txt; git commit -m 2 # 2

cd ../$B
echo c> c.txt; git add c.txt; git commit -m 4 # 4

cd ../$C
echo a> a.txt; git add a.txt; git commit -m 7 # 7
echo b> b.txt; git add b.txt; git commit -m 8 # 8

cd ../$A
git remote add B ../$B/.git; git remote add C ../$C/.git
git fetch B; git fetch C

git branch tmp
git merge B/master -m 3 # 3

git checkout B/master
git checkout -b master2
echo d> d.txt; git add d.txt; git commit -m 5 # 5

git merge tmp -m 6 # 6

git checkout C/master
git branch other

git checkout master2^

git remote rm B
git remote rm C

git tag tag_master2 master2 # タグがないと見えなくなるので
git branch -D tmp master2

cd ..

rm -f -r $B
rm -f -r $C
