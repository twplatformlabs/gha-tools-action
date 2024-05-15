@test "terraform installed" {
  run bash -c "docker exec gha-tools-action-container-build git --version"
  [[ "${output}" =~ "2.43" ]]
}
