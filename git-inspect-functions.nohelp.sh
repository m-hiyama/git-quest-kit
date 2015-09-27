#% git-inspect-functions.sh -*- coding: utf-8-unix -*-
#%
#% ヘルプテキストの作り方：
#% grep -v '#%' git-inspect-functions.sh | grep -e '#[^%]' | sed -e 's/#//' > help.txt
#%
#% コンソール表示が文字化けする場合は、
#% export CONSOLE_ENCODING=sjis
#% などとする。


function _g_confirm_gitdir #% 補助関数： gitdirを確認する
#% $1 リポジトリ
{
    gitdir="$1"
    if [ "$gitdir" = "" ]; then
        echo No gitdir > /dev/stderr
        return 1
    fi
    if [ ! -f $gitdir/HEAD ]; then
	echo Not a git repository: $gitdir > /dev/stderr
	return 1
    fi
    [ "$INFORM_GITDIR" != "" ] && echo "gitdir=$gitdir" > /dev/stderr
    echo $gitdir
    return 0
}

function _g_decide_gitdir #% 補助関数： 1つの引数からリポジトリを決定する
#% $1 省略可: リポジトリ
{
    if [ "$1" = "" ]; then
	gitdir=`g_dir`
    else
        gitdir="$1"
    fi

    gitdir=`_g_confirm_gitdir $gitdir` ; [ $? -eq 0 ] || return 1
    
    echo $gitdir
    return 0
}

function _g_decide_gitdir_arg #% 補助関数： 2つの引数からリポジトリを決定する
#% $1 引数1つなら固有引数、引数2つならリポジトリ
#% $2 省略可: 引数2つなら固有引数
{
    if [ "$1" = "" ]; then
        echo No arg > /dev/stderr
        return 1
    fi
    if [ "$2" = "" ]; then
        arg="$1"
        gitdir=`g_dir`
    else
        arg="$2"
        gitdir="$1"
    fi

    gitdir=`_g_confirm_gitdir $gitdir` ; [ $? -eq 0 ] || return 1
    
    echo $gitdir $arg #% 空白を含むファイル名では不具合が起きる
    return 0
}

function g_objects #-- リポジトリに含まれる全てのオブジェクトを列挙します。
# $1 省略可: リポジトリ
# objectsディレクトリ内でlsを実行して出力を加工。
{
    gitdir=`_g_decide_gitdir $1` ; [ $? -eq 0 ] || return 1

    (cd $gitdir/objects/; find -type f) | sed -e 's@^\.@@' -e 's@/@@g'
}

# 
function g_index #-- リポジトリのインデックス（ステージングエリア）をダンプします。
# $1 省略可: リポジトリ
# git ls-files -s を実行。
{
    gitdir=`_g_decide_gitdir $1` ; [ $? -eq 0 ] || return 1
    
    (GIT_DIR=$gitdir; git ls-files -s)
}

# 
function g_deref #-- 参照式を解決し、オブジェクトIDを出力します。
# $1 引数1つなら参照式（リビジョン式）、引数2つならリポジトリ
# $2 省略可: 引数2つなら参照式（リビジョン式）
# git rev-parse を実行。
{
    read gitdir ref <<<$(_g_decide_gitdir_arg $1 $2)
    [ "$gitdir" = "" ] && return 1

    (GIT_DIR=$gitdir; git rev-parse $ref)
}

# 
function g_aos_set #-- 指定されたコミットのAOS集合を列挙します。
# $1 引数1つならコミット、引数2つならリポジトリ
# $2 省略可: 引数2つならコミット
# git log -s を実行。
# aosは、ancestor-or-self（祖先または自分）の略記。
{
    read gitdir commit <<<$(_g_decide_gitdir_arg $1 $2)
    [ "$gitdir" = "" ] && return 1
    
    #% 最後に改行を出力しないと、wcが行の勘定を間違う
    (GIT_DIR=$gitdir; git log -s --format=%H $commit --; echo "")
}


# 
function g_cat #-- 指定されたオブジェクトを表示します。
# $1 引数1つならオブジェクト、引数2つならリポジトリ
# $2 省略可: 引数2つならオブジェクト
# git cat-file -t と git cat-file -p を実行。

{
    read gitdir obj <<<$(_g_decide_gitdir_arg $1 $2)
    [ "$gitdir" = "" ] && return 1
    
    type=`GIT_DIR=$gitdir; git cat-file -t "$obj"`
    hash=`GIT_DIR=$gitdir; git rev-parse "$obj"`
    echo "self $type $hash"
    echo "---"
    (GIT_DIR=$gitdir; git cat-file -p "$obj")
}


G_SAVE_SUFFIX_FILE=_g_save.suffix
# 
function g_save #-- 現在のリポジトリを保存します。
# $1 省略可: 保存対象のリポジトリ
{
    gitdir=`_g_decide_gitdir $1` ; [ $? -eq 0 ] || return 1
    
    if [ ! -e $G_SAVE_SUFFIX_FILE ]; then
        echo 1 > $G_SAVE_SUFFIX_FILE
    fi

    G_SAVE_SUFFIX=`cat $G_SAVE_SUFFIX_FILE`
    savedir="_git.$G_SAVE_SUFFIX"
    echo $(($G_SAVE_SUFFIX + 1)) > $G_SAVE_SUFFIX_FILE
    mkdir $savedir

    /bin/cp -r $gitdir/* $savedir/
}

function _g_prepare_tmp_files #% 補助関数： g_objectsの結果を一時ファイルにする。
{
    if [ "$1" == "" ]; then
	echo No arg > /dev/stderr
	return 1
    fi
    if [ "$2" = "" ]; then
	fst=`g_dir`
	snd=$1
    else
	fst=$1
	snd=$2
    fi

    tmp1=_objs1.$$.tmp
    tmp2=_objs2.$$.tmp
    g_objects $fst > $tmp1
    g_objects $snd > $tmp2
    echo $tmp1 $tmp2
    return 0
}

# 
function g_union_obj #-- オブジェクト集合の合併集合を出力します。
# $1 リポジトリ
# $2 省略可: リポジトリ
{
    read tmp1 tmp2<<<$(_g_prepare_tmp_files $1 $2)
    [ "$tmp1" = "" ] && return 1

    cat $tmp1 $tmp2 | sort | uniq -c
}

# 
function g_inters_obj #-- オブジェクト集合の共通部分集合を出力します。
# $1 リポジトリ
# $2 省略可: リポジトリ
{
    read tmp1 tmp2<<<$(_g_prepare_tmp_files $1 $2)
    [ "$tmp1" = "" ] && return 1
    
    cat $tmp1 $tmp2 | sort | uniq -d
}

# 
function g_diff_obj #-- オブジェクト集合の差集合を出力します。
# $1 リポジトリ
# $2 省略可: リポジトリ
{
    read tmp1 tmp2<<<$(_g_prepare_tmp_files $1 $2)
    [ "$tmp1" = "" ] && return 1
    
    cat $tmp1 $tmp2 $tmp2 | sort | uniq -u
}

# 
function g_set #-- 使用するリポジトリをセット／アンセットします。
# $1 省略可: リポジトリ
# 引数を省略すると、アンセット。
{
    if [ "$1" = "" ]; then
        unset GIT_DIR
        return 0
    fi
    if [ -d "$1"  -a  -f "$1/HEAD" ]; then
        export GIT_DIR="$1"
        return 0
    else
        echo Not a git repository: $1 > /dev/stderr
        return 1
    fi
}

# 
function g_dir #-- 現在使用しているリポジトリを出力します。
# 引数なし
{
    if [ "$GIT_DIR" != "" ]; then
        echo $GIT_DIR
    elif [ -f .git ]; then
         cat .git | sed -e 's/^gitdir: //'
    elif [ -d .git ]; then
         echo .git
    fi
    return 0
}

# 
function g_inform #-- リポジトリの場所を表示するかどうかをセットします。
# $1 0 または 1、0 は表示、1は非表示
{
    if [ "$1" = "0" ]; then
	unset INFORM_GITDIR
	echo NOT inform
	return 0
    elif [ "$1" = "1" ]; then
	export INFORM_GITDIR=1
	echo inform
	return 0
    else
	echo Bad argument > /dev/stderr
	return 1
    fi
}

# 
function g_help #-- ヘルプを表示します。
# 引数なし
{
    if [ "$CONSOLE_ENCODING" != "" ]; then
	iconv="iconv -f utf-8 -t $CONSOLE_ENCODING"
    else
	iconv=cat
    fi
    echo "$G_HELP_MSG" | $iconv 
}

G_HELP_MSG="Not defined."

#% makeにより、ここから下にヘルプテキストが追加される。
