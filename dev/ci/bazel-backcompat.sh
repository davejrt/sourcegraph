
set eu

bazelrcs="--bazelrc=.bazelrc"

if [[ "${CI:-false}" == "true" ]]; then
  bazelrcs="${bazelrcs} --bazelrc=.aspect/bazelrc/ci.bazelrc --bazelrc=.aspect/bazelrc/ci.sourcegraph.bazelrc"
fi

git diff

echo "--- :git::rewind: checkout v5.1.0"
git checkout --force "v5.1.0"

echo "--- :git: generate mirations dtiff and applying backcompat patch"
git checkout --force "${BUILDKITE_COMMIT}" -- migrations/

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
