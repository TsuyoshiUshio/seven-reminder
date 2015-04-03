require_relative "./spec_helper"

#describe port(3000) do
#	it {should be_listening}
#end

describe package('nodejs') do 
	it { should be_installed }
end

describe process("ruby") do
	it { should be_running }
end

describe command("ruby -v") do
  its(:stdout) {should match /2.2.0/}
end

#describe port(3000) do
#	it { should be_listening }
#end
