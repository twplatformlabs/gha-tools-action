@test "check git version" {
  run bash -c "docker exec gha-tools-action-container-build git --help"
  [[ "${output}" =~ "git" ]]
}
