provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# the zone variable must be within the region
# hence this weird setup
locals {
  zone = "${var.gcp_region}-${var.gcp_zone}"
}

# we use a version of Ubuntu 22.04 LTS
# this data item gives us the latest available image
data "google_compute_image" "ubuntu2204image" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# we want our instances to be able to talk to each other directly
# hence we add them all to a dedicated network
resource "google_compute_network" "celestial-network" {
  name                    = "celestial-network"
  description             = "This network connects Celestial hosts and coordinator."
  auto_create_subnetworks = false
}

# within our network, we need a subnet for this region that has the correct
# IP address range
resource "google_compute_subnetwork" "celestial-subnet" {
  name          = "celestial-subnetwork"
  ip_cidr_range = "192.168.10.0/24"
  region        = var.gcp_region
  network       = google_compute_network.celestial-network.id
}

# we need to explicitly enable communication between instances in that network
# as google cloud doesn't add any rules by default
resource "google_compute_firewall" "celestial-net-firewall-internal" {
  name          = "celestial-net-firewall-internal"
  description   = "This firewall allows internal communication in the network."
  direction     = "INGRESS"
  network       = google_compute_network.celestial-network.id
  source_ranges = ["${google_compute_subnetwork.celestial-subnet.ip_cidr_range}"]

  allow {
    protocol = "all"
  }
}

# we also need to enable ingress to our machines
resource "google_compute_firewall" "celestial-net-firewall-external" {
  name          = "celestial-net-firewall-external"
  description   = "This firewall allows external connections to our instances for ssh and celestial."
  network       = google_compute_network.celestial-network.id
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["22", "1969"]
  }
}

# we need to create an image for our hosts
# this needs a custom license to use nested virtualization
resource "google_compute_image" "celestial-host-image" {
  name = "celestial-host-image"
  #   source_disk = google_compute_disk.celestial-host-disk.self_link
  source_image = data.google_compute_image.ubuntu2204image.self_link
  licenses     = ["https://www.googleapis.com/compute/v1/projects/vm-options/global/licenses/enable-vmx"]
}

# the host instances run Ubuntu 22.04 and have all the necessary files
resource "google_compute_instance" "celestial-hosts" {
  name         = "celestial-host"
  machine_type = var.host_type
  zone         = local.zone

  boot_disk {

    initialize_params {
      image = google_compute_image.celestial-host-image.self_link
    }
  }

  # adapter for internal network
  network_interface {
    subnetwork = google_compute_subnetwork.celestial-subnet.self_link
    network_ip = "192.168.10.3"
    # put this empty block in to get a public IP
    access_config {
    }
  }

  # install Docker
  # you can do this manually if you want or even build custom images
  # for our purposes, the metadata_startup_script is a good place to start
  metadata_startup_script = <<EOF
#!/bin/bash

# we need the /celestial folder available on the hosts
sudo mkdir -p /celestial

# we also need wireguard and ipset as dependencies
sudo apt-get update
sudo apt-get install \
    --no-install-recommends \
    --no-install-suggests \
    -y wireguard ipset

# and we need firecracker on the machine
# download the current release
curl -fsSL -o firecracker-v0.25.2-x86_64.tgz \
    https://github.com/firecracker-microvm/firecracker/releases/download/v0.25.2/firecracker-v0.25.2-x86_64.tgz
tar -xvf firecracker-v0.25.2-x86_64.tgz
# and add the firecracker and jailer binaries
sudo mv release-v0.25.2-x86_64/firecracker-v0.25.2-x86_64 /usr/local/bin/firecracker
sudo mv release-v0.25.2-x86_64/seccompiler-bin-v0.25.2-x86_64 /usr/local/bin/jailer

# now download the kernel
curl -fsSL \
    -o vmlinux.bin \
    "https://s3.amazonaws.com/spec.ccfc.min/img/quickstart_guide/x86_64/kernels/vmlinux.bin"
sudo mv vmlinux.bin /celestial/vmlinux.bin

# sometimes it can also be helpful to increase process and file handler
# limits on your host machines:
cat << END > /home/ubuntu/limits.conf
* soft nofile 64000
* hard nofile 64000
root soft nofile 64000
root hard nofile 64000
* soft nproc 64000
* hard nproc 64000
root soft nproc 64000
root hard nproc 64000
END
sudo mv /home/ubuntu/limits.conf /etc/security/limits.conf
EOF

  service_account {
    scopes = ["cloud-platform"]
  }
}

output "host_ip" {
  value = google_compute_instance.celestial-hosts.network_interface.0.access_config.0.nat_ip
}
