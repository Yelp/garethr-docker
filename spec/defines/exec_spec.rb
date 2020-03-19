require 'spec_helper'

describe 'docker::exec', :type => :define do
  let(:title) { 'sample' }
	let(:facts) { {
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

  context 'when running detached' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'detach' => true} }
      it { should contain_exec('docker exec --detach=true container command') }
  end

  context 'when running with tty' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'tty' => true} }
      it { should contain_exec('docker exec --tty=true container command') }
  end

  context 'when running with interactive' do
      let(:params) { {'command' => 'command', 'container' => 'container', 'interactive' => true} }
      it { should contain_exec('docker exec --interactive=true container command') }
  end
end
