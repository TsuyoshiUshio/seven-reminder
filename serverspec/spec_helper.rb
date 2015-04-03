require "docker"
require "serverspec"

set :backend, :docker
set :docker_url, ENV["DOCKER_HOST"]
set :docker_image, "serverspec_docker3"



Excon.defaults[:ssl_verify_peer] = false
