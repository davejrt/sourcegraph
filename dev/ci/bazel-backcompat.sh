
set eu

bazelrcs="--bazelrc=.bazelrc"

if [[ "${CI:-false}" == "true" ]]; then
  bazelrcs="${bazelrcs} --bazelrc=.aspect/bazelrc/ci.bazelrc --bazelrc=.aspect/bazelrc/ci.sourcegraph.bazelrc"
fi

echo "--- :git: generate mgirations diff and applying backcompat patch"
git diff --ignore-space-at-eol v5.1.0..HEAD -- migrations/ > dev/backcompat/patches/back_compat_migrations.patch

echo "--- :bazel: bazel test @sourcegraph_back_compat"
bazel "${bazelrcs}" \
  test --test_tag_filters=go -- \
  @sourcegraph_back_compat//cmd/... \
  @sourcegraph_back_compat//lib/... \
  @sourcegraph_back_compat//internal/... \
  @sourcegraph_back_compat//enterprise/cmd/... \
  @sourcegraph_back_compat//enterprise/internal/... \
  -@sourcegraph_back_compat//cmd/migrator/... \
  -@sourcegraph_back_compat//enterprise/cmd/migrator/...
