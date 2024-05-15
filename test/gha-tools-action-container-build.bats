@test "check git version" {
  run bash -c "docker exec gha-tools-action-container-build git --version"
  [[ "${output}" =~ "2.43" ]]
}
