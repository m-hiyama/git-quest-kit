# not public  -*- coding: utf-8-unix -*-
git init A
git init B
git init C

cd A
echo a> a.txt; git add a.txt; git commit -m 0-1 # 0-1

cd ../B
echo a> a.txt; git add a.txt; git commit -m 0-2 # 0-2

cd ../C
echo a> a.txt; git add a.txt; git commit -m 0-0 # 0-0

cd ../A
git remote add B ../B/.git; git remote add C ../C/.git
git fetch B; git fetch C

git merge B/master -m 2-2 # 2-2

git checkout -b topic
echo b> b.txt; git add b.txt; git commit -m 1-2 # 1-2

git checkout master
git merge --no-ff topic -m 2-0 # 2-0

git checkout B/master
git checkout -b master2
echo c> c.txt; git add c.txt; git commit -m 1-1 # 1-1

git merge topic -m 2-1 # 2-1

echo d> d.txt; git add d.txt; git commit -m 1-0 # 1-0
