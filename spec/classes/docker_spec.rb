require 'spec_helper'

describe 'docker', :type => :class do
  context "on Debian" do
    let(:facts) { {
      :osfamily               => 'Debian',
      :os                     => { family: 'Debian', name: 'Ubuntu' },
      :operatingsystem        => 'Ubuntu',
      :lsbdistid              => 'Ubuntu',
      :lsbdistcodename        => 'maverick',
      :kernelrelease          => '3.8.0-29-generic',
      :operatingsystemrelease => '10.04',
    } }
    service_config_file = '/etc/default/docker'
    storage_config_file = '/etc/default/docker'

    it { should contain_service('docker').with_hasrestart('false') }
    it { should contain_class('apt') }
    it { should contain_package('apt-transport-https').that_comes_before('Package[docker]') }
    it { should contain_package('docker').with_name('lxc-docker').with_ensure('present') }
    it { should contain_apt__source('docker').with_location('https://get.docker.io/ubuntu') }
    it { should contain_file('/etc/init.d/docker').with_ensure('link').with_target('/lib/init/upstart-job') }

    context 'with a custom version' do
      let(:params) { {'version' => '0.5.5' } }
      it { should contain_package('docker').with_name('lxc-docker-0.5.5').with_ensure('present') }
    end

    context 'with no upstream package source' do
      let(:params) { {'use_upstream_package_source' => false } }
      it { should_not contain_apt__source('docker') }
      it { should contain_package('docker').with_name('lxc-docker') }
    end

    context 'with no upstream package source' do
      let(:params) { {'use_upstream_package_source' => false } }
      it { should_not contain_apt__source('docker') }
      it { should_not contain_class('epel') }
      it { should contain_package('docker') }
    end

    context 'It should include default prerequired_packages' do
      it { should contain_package('apt-transport-https').with_ensure('present') }
      it { should contain_package('cgroup-lite').with_ensure('present') }
      it { should contain_package('apparmor').with_ensure('present') }
    end

    context 'when given a specific tmp_dir' do
      let(:params) {{ 'tmp_dir' => '/bigtmp' }}
      it { should contain_file('/etc/default/docker').with_content(/export TMPDIR="\/bigtmp"/) }
    end

    context 'with custom service_name' do
      let(:params) {{ 'service_name' => 'docker.io' }}
      it { should contain_file('/etc/default/docker.io') }
    end

    it { should compile.with_all_deps }
    it { should contain_class('docker::install').that_comes_before('Class[docker::config]') }
    it { should contain_class('docker::service').that_subscribes_to('Class[docker::config]') }
    it { should contain_class('docker::config') }

    context 'with a specific docker command' do
      let(:params) {{ 'docker_command' => 'docker.io' }}
      it { should contain_file(service_config_file).with_content(/docker.io/) }
    end

    context 'with a custom package name' do
      let(:params) { {'package_name' => 'docker-custom-pkg-name' } }
      it { should contain_package('docker').with_name('docker-custom-pkg-name').with_ensure('present') }
    end

    context 'with a custom package name and version' do
      let(:params) { {
        'version'      => '0.5.5',
        'package_name' => 'docker-custom-pkg-name',
      } }
      it { should contain_package('docker').with_name('docker-custom-pkg-name-0.5.5').with_ensure('present') }
    end

    context 'when not managing the package' do
      let(:params) { {'manage_package' => false } }
      it { should_not contain_package('docker') }
    end

    context 'It should accept custom prerequired_packages' do
      let(:params) { {'prerequired_packages' => [ 'test_package' ],
                      'manage_package'       => false,  } }
      it { should contain_package('test_package').with_ensure('present') }
    end

    context 'with proxy param' do
      let(:params) { {'proxy' => 'http://127.0.0.1:3128' } }
      it { should contain_file(service_config_file).with_content(/export http_proxy='http:\/\/127.0.0.1:3128'\nexport https_proxy='http:\/\/127.0.0.1:3128'/) }
    end

    context 'with no_proxy param' do
      let(:params) { {'no_proxy' => '.github.com' } }
      it { should contain_file(service_config_file).with_content(/export no_proxy='.github.com'/) }
    end

    context 'with execdriver param lxc' do
      let(:params) { { 'execdriver' => 'lxc' }}
      it { should contain_file(service_config_file).with_content(/-e lxc/) }
    end

    context 'with execdriver param native' do
      let(:params) { { 'execdriver' => 'native' }}
      it { should contain_file(service_config_file).with_content(/-e native/) }
    end

    context 'with storage driver param' do
      let(:params) { { 'storage_driver' => 'devicemapper' }}
      it { should contain_file(storage_config_file).with_content(/--storage-driver=devicemapper/) }
    end

    context 'without execdriver param' do
      it { should_not contain_file(service_config_file).with_content(/-e lxc/) }
      it { should_not contain_file(service_config_file).with_content(/-e native/) }
    end

    context 'with multi dns param' do
      let(:params) { {'dns' => ['8.8.8.8', '8.8.4.4']} }
      it { should contain_file(service_config_file).with_content(/--dns 8.8.8.8/).with_content(/--dns 8.8.4.4/) }
    end

    context 'with dns param' do
      let(:params) { {'dns' => '8.8.8.8'} }
      it { should contain_file(service_config_file).with_content(/--dns 8.8.8.8/) }
    end

    context 'with multi dns_search param' do
      let(:params) { {'dns_search' => ['my.domain.local', 'other-domain.de']} }
      it { should contain_file(service_config_file).with_content(/--dns-search my.domain.local/).with_content(/--dns-search other-domain.de/) }
    end

    context 'with dns_search param' do
      let(:params) { {'dns_search' => 'my.domain.local'} }
      it { should contain_file(service_config_file).with_content(/--dns-search my.domain.local/) }
    end

    context 'with multi extra parameters' do
      let(:params) { {'extra_parameters' => ['--this this', '--that that'] } }
      it { should contain_file(service_config_file).with_content(/--this this/) }
      it { should contain_file(service_config_file).with_content(/--that that/) }
    end

    context 'with a string extra parameters' do
      let(:params) { {'extra_parameters' => '--this this' } }
      it { should contain_file(service_config_file).with_content(/--this this/) }
    end

    context 'with multi shell values' do
      let(:params) { {'shell_values' => ['--this this', '--that that'] } }
      it { should contain_file(service_config_file).with_content(/--this this/) }
      it { should contain_file(service_config_file).with_content(/--that that/) }
    end

    context 'with a string shell values' do
      let(:params) { {'shell_values' => '--this this' } }
      it { should contain_file(service_config_file).with_content(/--this this/) }
    end

    context 'with socket group set' do
      let(:params) { { 'socket_group' => 'notdocker' }}
      it { should contain_file(service_config_file).with_content(/-G notdocker/) }
    end

    context 'with service_state set to stopped' do
      let(:params) { {'service_state' => 'stopped'} }
      it { should contain_service('docker').with_ensure('stopped') }
    end

    context 'with a custom service name' do
      let(:params) { {'service_name' => 'docker.io'} }
      it { should contain_service('docker').with_name('docker.io') }
    end

    context 'with service_enable set to false' do
      let(:params) { {'service_enable' => 'false'} }
      it { should contain_service('docker').with_enable('false') }
    end

    context 'with service_enable set to true' do
      let(:params) { {'service_enable' => 'true'} }
      it { should contain_service('docker').with_enable('true') }
    end

    context 'with specific log_level' do
      let(:params) { { 'log_level' => 'debug' } }
      it { should contain_file(service_config_file).with_content(/-l debug/) }
    end

    context 'with an invalid log_level' do
      let(:params) { { 'log_level' => 'verbose'} }
      it do
        expect {
          should contain_package('docker')
        }.to raise_error(Puppet::Error, /log_level must be one of debug, info, warn, error or fatal/)
      end
    end

    context 'with specific selinux_enabled parameter' do
      let(:params) { { 'selinux_enabled' => 'true' } }
      it { should contain_file(service_config_file).with_content(/--selinux-enabled=true/) }
    end

    context 'with an invalid selinux_enabled parameter' do
      let(:params) { { 'selinux_enabled' => 'yes'} }
      it do
        expect {
          should contain_package('docker')
        }.to raise_error(Puppet::Error, /selinux_enabled must be true or false/)
      end
    end

    context 'with custom root dir' do
      let(:params) { {'root_dir' => '/mnt/docker'} }
      it { should contain_file(service_config_file).with_content(/--data-root \/mnt\/docker/) }
    end

    context 'with ensure absent' do
      let(:params) { {'ensure' => 'absent' } }
      it { should contain_package('docker').with_ensure('absent') }
    end

  end

  context 'specific to Ubuntu Maverick' do
    let(:facts) { {
      :osfamily               => 'Debian',
      :operatingsystem        => 'Ubuntu',
      :lsbdistid              => 'Ubuntu',
      :lsbdistcodename        => 'maverick',
      :kernelrelease          => '3.8.0-29-generic',
      :operatingsystemrelease => '10.04',
    } }

    context 'with no parameters' do
      it { should contain_package('linux-image-extra-3.8.0-29-generic') }
      it { should contain_package('apparmor') }
    end

    context 'with no upstream package source' do
      let(:params) { {'use_upstream_package_source' => false } }
      it { should contain_package('linux-image-extra-3.8.0-29-generic') }
    end

    context 'when not managing the kernel' do
      let(:params) { {'manage_kernel' => false} }
      it { should_not contain_package('linux-image-extra-3.8.0-29-generic') }
    end
  end

  context 'specific to Debian wheezy' do
    let(:facts) { {
      :osfamily        => 'Debian',
      :operatingsystem => 'Debian',
      :lsbdistid       => 'Debian',
      :lsbdistcodename => 'wheezy',
      :kernelrelease   => '3.12-1-amd64'
    } }

    it { should_not contain_package('linux-image-extra-3.8.0-29-generic') }
    it { should_not contain_package('linux-image-generic-lts-raring') }
    it { should_not contain_package('linux-headers-generic-lts-raring') }
    it { should contain_service('docker').without_provider }

    context 'with no upstream package source' do
      let(:params) { {'use_upstream_package_source' => false } }
      it { should_not contain_apt__source('docker') }
      it { should contain_package('docker').with_name('docker.io') }
    end
  end
end
