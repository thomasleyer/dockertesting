require 'dockerspec/serverspec'
require 'dockerspec/infrataster'


describe 'defaultreplynginx image' do

  # Docker image tests
  #
  # Things you can find out without running a container of the image
  # e.g. labels, cmd, environment variables, exposed ports, entrypoint

  describe docker_build(id: 'dockertesting:latest') do

    # Tests for our own image properties
    its(:labels) { should include 'maintainer' => 'selecticon@googlemail.com' }
    its(:labels) { should include 'description' }

    # Tests to make sure the base image is OK
    its(:arch) { should eq 'amd64' }
    its(:os) { should eq 'linux' }
    its(:cmd) { should eq [ "nginx", "-g", "daemon off;" ]}
    its(:env) { should include "PATH" => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" }
    its(:env) { should include "NGINX_VERSION" => "1.17.3" }
    its(:env) { should include "NJS_VERSION" => "0.3.5" }
    its(:env) { should include "PKG_RELEASE" => "1~buster" }
    its(:exposes) { should eq ["80"] }
  end

  # Docker container tests
  #
  # Things you can only find out from a running image
  # e.g. files/permissions, users, packages, running processes

  describe docker_run('.', tag: 'dockertesting:latest') do
    # Tests for our own container properties
    describe file('/usr/share/nginx/html/404.html') do
      it { should exist }
    end
    describe file('/usr/share/nginx/html/404_sorry.png') do
      it { should exist }
    end

    # Test to make sure the base image is OK
    describe file ('/usr/sbin/nginx') do
      it { should exist }
    end


  # PoC Tests

  packages= ["mawk", "mount", "nginx"]

  # Verify packages
  packages.each do |name|
    describe package(name) do
      it { should be_installed }
    end
  end

  packageversions = {
    'passwd' => {
      version: '1:4.5-1.1'
    }
  }

  # Verify packages
  packageversions.each do |name, details|
    describe package(name) do
      it { should be_installed.with_version(details[:version]) }
    end
  end

  # Infrataster tests
  #
  # Things you can find out by probing replies of your container on port 80
  # e.g. return codes, returned content

    describe server(described_container) do # Infrataster

      describe http('/') do

        # Tests
        it 'responds content including "Sorry, buddy"' do
          expect(response.body).to include 'Sorry, buddy'
        end


        # Tests to make sure the base image is OK
        it 'responds as "nginx" server' do
          expect(response.headers['server']).to match(/nginx/i)
          expect(response.status).to eq(404)
        end
      end
    end
  end


end

