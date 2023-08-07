
set eu

echo "------------------------------------"
target_commit=$(buildkite-agent metadata get "target_commit")
echo "Target Commit: ${target_commit}"
echo "Current Commit: $(git show HEAD)"
echo "------------------------------------"

bazelrcs="--bazelrc=.bazelrc"

if [[ "${CI:-false}" == "true" ]]; then
  bazelrcs="${bazelrcs} --bazelrc=.aspect/bazelrc/ci.bazelrc --bazelrc=.aspect/bazelrc/ci.sourcegraph.bazelrc"
fi

echo "--- :git: generate mgirations dtiff and applying backcompat patch"
git diff --ignore-space-at-eol "v5.1.0..${target_commit}" -- migrations/ > dev/backcompat/patches/back_compat_migrations.patch

echo "--- :bazel: bazel test @sourcegraph_back_compat"
bazel "${bazelrcs}" \
  test --test_tag_filters=go -- \
  //cmd/... \
  //lib/... \
  //internal/... \
  //enterprise/cmd/... \
  //enterprise/internal/...
  # -@sourcegraph_back_compat//cmd/migrator/... \
  # -@sourcegraph_back_compat//enterprise/cmd/migrator/...
