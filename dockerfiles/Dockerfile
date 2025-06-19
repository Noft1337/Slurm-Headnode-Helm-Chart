# Build by running this from project root:
#    docker build -f dockerfiles/Dockerfile .

# ----- Builder Stage -----
FROM rockylinux/rockylinux:9.5 AS builder

ARG SLURM_VERSION=25.05.0
ARG SLURM_TAR=slurm-$SLURM_VERSION.tar.bz2

WORKDIR /root

# Copy custom yum repos if needed
COPY dockerfiles/files/pki /tmp/pki
COPY dockerfiles/files/yum.repos.d /tmp/yum.repos.d

# Prepare the build environment
RUN rm -rf /etc/yum.repos.d
RUN cp -r /tmp/yum.repos.d /etc/yum.repos.d
RUN cp -raf /tmp/pki/. /etc/pki/
RUN yum clean all
RUN yum -y makecache --refresh
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y \
    autoconf \
    automake \
    gcc \
    http-parser-devel \
    hwloc-devel \
    json-c-devel \
    libjwt-devel \
    make \
    mariadb-devel \
    munge-devel \
    munge-libs \
    numactl-devel \
    pam-devel \
    perl \
    perl-devel \
    pmix \
    readline-devel \
    systemd \
    ucx-devel \
    dbus-devel \
    libbpf-devel \
    kernel-headers \
    rpm \
    rpm-build \
    libyaml-devel \
    wget
RUN yum clean all

# Download and build Slurm
RUN wget "https://download.schedmd.com/slurm/$SLURM_TAR"
RUN rpmbuild -ta "$SLURM_TAR" --without debug --with slurmrestd --with hwloc --with mysql --with jwt --with numa --with ucx --with munge --without pam --without x11 --with yaml

# Copy RPMs to target directory
RUN mkdir /tmp/rpms
RUN cp /root/rpmbuild/RPMS/x86_64/* /tmp/rpms

# ----- Production Stage -----
FROM rockylinux/rockylinux:9.5 AS prod
WORKDIR /root

# Copy RPMs from builder
COPY --from=builder /root/rpmbuild/RPMS/x86_64/ /tmp/rpms

# Copy files
COPY dockerfiles/files/home /tmp/home
COPY dockerfiles/files/profile.d /tmp/profile.d
COPY dockerfiles/files/pki /tmp/pki
COPY dockerfiles/files/yum.repos.d /tmp/yum.repos.d
RUN cp -arf /tmp/home/. /root/
RUN cp -arf /tmp/profile.d/. /etc/profile.d/
RUN cp -raf /tmp/pki/. /etc/pki/
RUN rm -rf /etc/yum.repos.d && cp -r /tmp/yum.repos.d /etc/yum.repos.d

# Install Packages
RUN yum clean all
RUN yum -y makecache --refresh
RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y \
    munge \
    munge-libs \
    mariadb \
    mariadb-server\
    mariadb-connector-c-devel \
    hwloc \
    ucx \
    pmix \
    vim \
    wget \
    go \
    python3.9

# Set powerline
RUN go install github.com/justjanne/powerline-go@latest
RUN mv /root/go/bin/powerline-go /usr/local/bin

# Install the rpms
RUN find /tmp/rpms/ -type f -name "*.rpm" -exec yum install -y /tmp/rpms/'{}' \;
# Delete RPMS 
# RUN find /tmp/rpms/ -type f -name "*.rpm" -exec rm -f '{}' \;

CMD ["/bin/bash"]
