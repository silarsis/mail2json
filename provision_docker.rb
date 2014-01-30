#!/usr/bin/ruby
#
# Script to provision docker instances

require 'docker'
require 'yaml'

Docker.validate_version!

# Grab existing and running images/containers, compare with config
existing = Docker::Image.all.map{ |image| image.info['Repository']}
running = Docker::Container.all.map{ |container| container.json['Config']['Image'] }
config = YAML.load_file('docker.yaml')
imagesToCreate = config.select{ |k, v| !existing.include?(v['fromImage']) }
docksToRun = config.select{ |k, v| !running.include?(v['fromImage']) }

# Create all images that don't currently exist
imagesToCreate.each_pair do |name, data|
	puts "Creating Image #{name}"
	Docker::Image.create('fromImage' => data['fromImage'])
end

# Run all containers that aren't currently running
docksToRun.each_pair do |name, data|
	puts "Running Container #{name}"
	data['Image'] = data['fromImage']
	data.delete('fromImage')
	portBindings = nil
	# Want to change the handling here
	if data.has_key?('ExposedPorts')
		data['NetworkDisabled'] = false
		data['PortSpecs'] = nil
		portBindings = {}
		data['ExposedPorts'].each_key{ |k| portBindings[k] = [{'HostIp' => '', 'HostPort' => k.split('/')[0]}]}
	end
	Docker::Container.create(data).start('portBindings' => portBindings)
end

# Ensure that we're registered with shipyard, assuming shipyard is running
key = `/vagrant/shipyard-agent -url http://127.0.0.1:8000 -register 2>&1 | grep Agent | awk '{ print $5 }'`
exec("/vagrant/shipyard-agent -url http://localhost:8000 -key #{key}")