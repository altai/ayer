AYER_CONFIG=${AYER_CONFIG:-~/.config/ayer}
GERRIT_PORT=29418
BASE_WORKDIR=~/.ayer
GERRIT_SUBMITTABLE="CodeReview+2 Verified+1 -Verified-1 -CodeReview-2"

set -E

source "$AYER_CONFIG"
# TODO: show errors if some variables are not set

# surprise: this command finishes the current shell
function die() {
    echo "$@" >&2
    exit 3
}

# arguments: spec_file tag
function rpm_get_tag() {
    rpm -q --specfile "${1}" --qf "%{$2}\n" | head -1 | sed 's,/,,g'
}


function log() {
    echo "$@"
}


# args: repo_name repo_path refspec
function git_fetch_refspec() {
    local repo_name=$1 repo_path=$2 refspec=$3
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


function gerrit_repo_ssh()
{
    local git_project=$1
    if [[ "$git_project" == ssh://* ]]; then
        echo $git_project
    else
        echo "ssh://$GERRIT_SSH:$GERRIT_PORT/${git_project%.git}.git"
    fi
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

# arguments: spec_file treeish build_version
function update_spec() {
    local spec_file="$1"
    local treeish="$2"
    local build_version="$3"

    if [ -n "$build_version" ]; then
        sed -i "s/Release: .*/Release:        ${build_version}%{?dist}/" "${spec_file}"
    fi

    changelog_commit_msg="* $(date '+%a %b %d %Y') Ayer Build System $(rpm_get_tag ${spec_file} version)\\
- build an RPM from commit $(git rev-parse $treeish)\\
"

    if ! grep -q '%changelog' "$spec_file"; then
        echo -e '\n%changelog' >> "$spec_file"
    fi
    sed -i "s/%changelog.*/%changelog\\
$changelog_commit_msg/" "$spec_file"
}

# arguments: git_dir build_version
# uses PWD as working dir
# waits for git.list in PWD
function build_srpms() {
    local git_dir=$1
    local build_version=$2

    local build_dir=$PWD 
    local git_repos_list="${build_dir}/git.list"
    local git_repos_dir="${git_dir}/git"
    local srpms_dir="$build_dir/SRPMS"
    local logs_dir="$build_dir/SLOGS"
    local spec_dir="$build_dir/SPECS"
    rm -rf "$logs_dir" "$spec_dir" "$srpms_dir"
    mkdir -p "$logs_dir" "$spec_dir" "$srpms_dir"
    mkdir -p "$git_repos_dir"

    while read refspec repo_name; do
        repo_name="${repo_name%.git}"
        log "building src rpm for $repo_name"
        cd "$git_repos_dir"
        git_fetch_refspec "$git_repos_dir/${repo_name}.git" "$(gerrit_repo_ssh $repo_name)" "$refspec" &>/dev/null
        cd "$git_repos_dir/${repo_name}.git"
        git update-ref --no-deref HEAD FETCH_HEAD
        log_filename="$logs_dir/$repo_name.log"
        extract_pattern FETCH_HEAD "*.spec" "${spec_dir}/" | while read rel_spec_file; do 
            spec_file="${spec_dir}/${rel_spec_file}"
            update_spec "${spec_file}" HEAD $build_version
            ayer_treeish=HEAD ayer-rpm -bs "${spec_file}" &> "$log_filename"
            grep '^Wrote:.*.rpm' "$log_filename" | while read ignored rpm_name; do
                mv "$rpm_name" "$srpms_dir/"
            done
        done
    done < "$git_repos_list"
}

# uses PWD as working dir
# waits for SRPMS dir inside PWD
function build_final_rpms() {
    local build_dir=$PWD 
    local srpms_dir="$build_dir/SRPMS"

    if [ -n "$BUILD_SERVER_SSH" ]; then
        log -n "building binary rpms at $BUILD_SERVER_SSH"
        local remote_dir=$(ssh "$BUILD_SERVER_SSH" "mktemp -d /tmp/ayer.XXXXXX")
        log ":$remote_dir"
        scp -r "$srpms_dir" "$BUILD_SERVER_SSH:$remote_dir/" &>/dev/null
        scp "$(which ayer-binrpm)" "$BUILD_SERVER_SSH:$remote_dir/" &>/dev/null
        ssh "$BUILD_SERVER_SSH" "cd $remote_dir && ./ayer-binrpm" && binrpm_exitcode=0 || binrpm_exitcode=$?
        rm -rf "$build_dir/"{RPMS,LOGS}
        scp -r "$BUILD_SERVER_SSH:$remote_dir/{RPMS,LOGS}" "$build_dir" &>/dev/null
        ssh "$BUILD_SERVER_SSH" "rm -rf '$remote_dir'"
        [ "$binrpm_exitcode" == "0" ] || die "binary rpm build failed with exit code $binrpm_exitcode"
    else
        ayer-binrpm "$build_dir"
    fi
}

# arguments: release_refspec create-release-arguments
# uses PWD as working dir
function build_release_srpm() {
    local release_refspec="$1"
    shift

    local build_dir=$PWD 
    local srpms_dir="$build_dir/SRPMS"
    local logs_dir="$build_dir/SLOGS"
    local log_filename="$logs_dir/release.log"
    local release_git_dir="$build_dir/release"
    git_fetch_refspec "$release_git_dir" "$(gerrit_repo_ssh release)" "$release_refspec" &>/dev/null
    cd "$release_git_dir"
    git checkout FETCH_HEAD &>/dev/null
    ayer-create-release "$@" &> "$log_filename"
    grep '^Wrote:.*.rpm' "$log_filename" | while read ignored rpm_name; do
        mv "$rpm_name" "$srpms_dir/"
    done
}
