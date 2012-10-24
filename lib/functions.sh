# -*- sh -*-

AYER_CONFIG=${AYER_CONFIG:-~/.config/ayer}
GERRIT_PORT=29418
BASE_WORKDIR=~/.ayer
GERRIT_SUBMITTABLE="CodeReview+2 Verified+1 NOT Verified-1 NOT CodeReview-2"
build_os=centos6

set -e


function load_config() {
    source "$AYER_CONFIG"
    git_dir="$BASE_WORKDIR/git"
   # TODO: show errors if some variables are not set
}

function cd_to_hoy_top() {
    while true; do
        if [ "$PWD" == "/" ]; then
            die "not an ayer repository"
        fi
        if [ -f .ayer ]; then
            source .ayer
            hoy_top=$PWD
            return
        fi
        cd ..
    done
}

# surprise: this command finishes the current shell
function die() {
    echo "$@" >&2
    exit 3
}

# arguments: spec_file tag
function rpm_get_tag() {
    rpm -q --specfile "${1}" --qf "%{$2}\n" | head -1 | sed 's,/,,g'
}


# args: repo_name repo_path refspec
function git_fetch_refspec() {
    local repo_name=$1 repo_path=$2
    shift 2
    local refspec=$@
    local repo_type=
    if [[ "$repo_name" == *.git ]]; then
        repo_type="--bare"
    fi
    if [ ! -d "$repo_name" ]; then
        git init $repo_type "$repo_name"
        (cd "$repo_name" && git remote add origin "$repo_path")
    fi
    (cd "$repo_name" && git fetch origin $refspec)
}

# args: repo_name repo_path
# fetches changes, heads, and tags
function git_fetch_std() {
    git_fetch_refspec "$1" "$2" --tags +refs/changes/*:refs/remotes/origin/* +refs/heads/*:refs/remotes/origin/*
}

function git_fetch_repos() {
    local base_treeish="$1"
    mkdir -p "$git_dir"
    cd "$git_dir"
    git_fetch_std "${BASE_PROJECT}.git" "$(gerrit_repo_ssh ${BASE_PROJECT})"
    cd "./${BASE_PROJECT}.git"
    git rev-parse $base_treeish &>/dev/null || die "\`$base_treeish' is not found in ${BASE_PROJECT}"
    git ls-tree -r $base_treeish | while read mode type hash path; do
        if [ "$mode" == 160000 ]; then
            git_project_dir="$(basename "$path").git"
            git_fetch_std "${git_dir}/${git_project_dir}" "$(gerrit_repo_ssh "$git_project_dir")"
        fi
    done
}

function gerrit_repo_ssh()
{
    local git_project=$1
    if [[ "$git_project" == ssh://* ]]; then
        echo $git_project
    else
        echo "ssh://$GERRIT_SSH:$GERRIT_PORT/${git_project%.git}.git"
    fi
}

function gerrit_command() {
    ssh "$GERRIT_SSH" -p "$GERRIT_PORT" gerrit "$@"
}

# arguments: repo_dir remote_repo_name remote_repo_full_path
function git_update_remote() {
    (
        cd "$1"
        git remote set-url "$2" "$3" 2>/dev/null || git remote add "$2" "$3"
    )
}

# extract all regular file corresponding to the pattern
# do not set access rights
# args: treeish pattern outdir [-r]
function extract_pattern()
{
        local treeish="$1"; shift
        local pattern="$1"; shift
	local outdir="$1"; shift
        local recursive="$1"

        mkdir -p "$outdir"	
        local mode otype id name
        git ls-tree $recursive "$treeish" | while read mode otype id name; do
                # ignore non-blobs.
                [ "$otype" = blob ] || continue
                short_name=$(basename "$name")
                # ignore unmatched.
                [[ "${short_name}" == $pattern ]] || continue
                target_name="$outdir/$name"
                mkdir -p "$(dirname "$target_name")"
                git cat-file blob "$id" >"$target_name"
                echo "$name"
        done
}

# uses PWD as working dir
function clean_srpms() {
    local build_dir=$PWD 
    rm -rf "$build_dir"/{SRPMS,RPMS,LOGS,SLOGS}
}


function replace_dir() {
    if [ -d "$1" ]; then
        [ ! -d "$2" ] || mv "$2"{,.old}
        mv "$1" "$2"
        rm -fr "$2".old
    fi
}

function replace_repos() {
    local base_target_dir="$1"
    local build_dir=$base_target_dir/build
    replace_dir "$build_dir/deps" "$base_target_dir/deps"
    replace_dir "$build_dir/RPMS" "$base_target_dir/$build_os"
    #rm -rf "$build_dir"
}
