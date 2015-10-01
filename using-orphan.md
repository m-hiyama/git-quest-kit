<!-- -*- coding: utf-8-unix -*- -->

# git checkout --orphan の利用

setup-git-sample-3.shでは、親のないコミットを作るために、
他のリポジトリからのフェッチを利用していました。
これはこれで、フェッチが何をするかを示す意味があるのでそのままにしておきますが、
親のないコミットを作る目的だけなら、
`git checkout --orphan` を利用すればより簡単にできます。


using-orphan.sh は、`git checkout --orphan` を使って、
setup-git-sample-3.shとまったく同じことを行うスクリプトです。
