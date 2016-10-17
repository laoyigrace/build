%global release_name liberty
%global service subject

%{!?upstream_version: %global upstream_version %{version}%{?milestone}}

%global with_doc 1

Name:             ojj-subject
# Liberty semver reset
# https://review.openstack.org/#/q/I6a35fa0dda798fad93b804d00a46af80f08d475c,n,z
Epoch:            1
Version:          1.0.0
Release:          1%{?dist}
Summary:          OJJ Subject Service

License:          ASL 2.0
URL:              http://subject.openstack.org
Source0:          https://tarballs.openstack.org/%{service}/%{service}-%{upstream_version}.tar.gz

Source1:         ojj-subject-api.service
Source3:         ojj-subject-registry.service
Source10:         ojj-subject.logrotate

Source21:         subject-api-dist.conf
Source24:         subject-registry-dist.conf

BuildArch:        noarch
BuildRequires:    python2-devel
BuildRequires:    python-setuptools
BuildRequires:    python-pbr
BuildRequires:    intltool
# Required for config generation
BuildRequires:    python-cursive
BuildRequires:    python-crypto
BuildRequires:    python-eventlet
BuildRequires:    python-futurist
BuildRequires:    python-subject-store >= 0.13.0
BuildRequires:    python-httplib2
BuildRequires:    python-oslo-config >= 2:3.7.0
BuildRequires:    python-oslo-log >= 1.14.0
BuildRequires:    python-oslo-middleware >= 3.0.0
BuildRequires:    python-oslo-policy >= 0.5.0
BuildRequires:    python-oslo-utils >= 3.5.0
BuildRequires:    python-osprofiler
BuildRequires:    python-paste-deploy
BuildRequires:    python-requests
BuildRequires:    python-routes
BuildRequires:    python-oslo-messaging >= 4.0.0
BuildRequires:    python-semantic-version
BuildRequires:    python-taskflow >= 1.26.0
BuildRequires:    python-wsme >= 0.8

Requires(pre):    shadow-utils
Requires:         python-subject = %{epoch}:%{version}-%{release}
#Requires:         python-subjectclient >= 1:0

Requires(post): systemd
Requires(preun): systemd
Requires(postun): systemd
BuildRequires: systemd

%description
OpenStack Subject Service (code-named Glance) provides discovery, registration,
and delivery services for virtual disk images. The Subject Service API server
provides a standard REST interface for querying information about virtual disk
images stored in a variety of back-end stores, including OpenStack Object
Storage. Clients can register new virtual disk images with the Subject Service,
query for information on publicly available disk images, and use the Subject
Service's client library for streaming virtual disk images.

This package contains the API and registry servers.

%package -n       python-subject
Summary:          Subject Python libraries

Requires:         pysendfile
Requires:         python-anyjson
Requires:         python-cursive
Requires:         python-crypto
Requires:         python-cryptography >= 1.0
Requires:         python-debtcollector >= 1.2.0
Requires:         python-eventlet >= 0.18.2
Requires:         python-futurist >= 0.11.0
Requires:         python-subject-store >= 0.18.0
Requires:         python-httplib2
Requires:         python-iso8601 >= 0.1.11
Requires:         python-jsonschema
Requires:         python-keystoneauth1 >= 2.10.0
Requires:         python-keystoneclient >= 1:2.0.0
Requires:         python-keystonemiddleware >= 4.0.0
Requires:         python-migrate >= 0.9.6
Requires:         python-monotonic >= 0.6
Requires:         python-netaddr
Requires:         python-oslo-concurrency >= 3.8.0
Requires:         python-oslo-config >= 2:3.14.0
Requires:         python-oslo-context >= 2.9.0
Requires:         python-oslo-db >= 4.10.0
Requires:         python-oslo-i18n >= 2.1.0
Requires:         python-oslo-log >= 1.14.0
Requires:         python-oslo-messaging >= 5.2.0
Requires:         python-oslo-middleware >= 3.0.0
Requires:         python-oslo-policy >= 1.9.0
Requires:         python-oslo-serialization >= 1.10.0
Requires:         python-oslo-service >= 1.10.0
Requires:         python-oslo-utils >= 3.16.0
Requires:         python-oslo-vmware >= 0.11.1
Requires:         python-osprofiler
Requires:         python-paste
Requires:         python-paste-deploy
Requires:         python-pbr
Requires:         python-posix_ipc
Requires:         python-prettytable
Requires:         python-retrying
Requires:         python-routes
Requires:         python-semantic-version
Requires:         python-six >= 1.9.0
Requires:         python-sqlalchemy >= 1.0.10
Requires:         python-stevedore >= 1.16.0
Requires:         python-swiftclient >= 2.2.0
Requires:         python-taskflow >= 1.26.0
Requires:         python-webob >= 1.2.3
Requires:         python-wsme >= 0.8
Requires:         pyOpenSSL
Requires:         pyxattr

#test deps: python-mox python-nose python-requests
#test and optional store:
#ceph - subject.store.rdb
#python-boto - subject.store.s3
Requires:         python-boto

%description -n   python-subject
Ojj Subject Service (code-named Subject) provides discovery, registration,
and delivery services for virtual disk images.

This package contains the subject Python library.

%if 0%{?with_doc}
%package doc
Summary:          Documentation for OpenStack Subject Service

Requires:         %{name} = %{epoch}:%{version}-%{release}

BuildRequires:    systemd-units
BuildRequires:    python-sphinx
BuildRequires:    python-oslo-sphinx
BuildRequires:    graphviz
# Required to build module documents
BuildRequires:    python-boto
BuildRequires:    python-cryptography >= 1.0
BuildRequires:    python-keystoneauth1
BuildRequires:    python-keystonemiddleware >= 4.0.0
BuildRequires:    python-oslo-concurrency >= 3.5.0
BuildRequires:    python-oslo-context >= 0.2.0
BuildRequires:    python-oslo-db >= 4.1.0
BuildRequires:    python-sqlalchemy >= 1.0.10
BuildRequires:    python-stevedore
BuildRequires:    python-webob >= 1.2.3
# Required for man page building
BuildRequires:    python-oslotest
BuildRequires:    python-psutil
BuildRequires:    python-testresources
BuildRequires:    pyxattr
BuildRequires:    python-pep8
# Required to compile translation files
BuildRequires:    python-babel
BuildRequires:    python-httplib2
BuildRequires:    python-cursive
BuildRequires:    python-osprofiler
BuildRequires:    python-paste
BuildRequires:    python-oslo-policy
BuildRequires:    python-oslo-middleware
BuildRequires:    python-paste-deploy
BuildRequires:    python-routes
BuildRequires:    python-taskflow
BuildRequires:    python-futurist
BuildRequires:    python-wsme
BuildRequires:    python-crypto
BuildRequires:    python-oslo-messaging


%description      doc
OpenStack Subject Service (code-named Glance) provides discovery, registration,
and delivery services for virtual disk images.

This package contains documentation files for subject.
%endif

%package -n python-%{service}-tests
Summary:        Glance tests
Requires:       ojj-%{service} = %{epoch}:%{version}-%{release}

%description -n python-%{service}-tests
OpenStack Subject Service (code-named Glance) provides discovery, registration,
and delivery services for virtual disk images.

This package contains the Glance test files.


%prep
%setup -q -n subject-%{upstream_version}

sed -i '/\/usr\/bin\/env python/d' subject/common/config.py subject/common/crypt.py subject/db/sqlalchemy/migrate_repo/manage.py

# Remove the requirements file so that pbr hooks don't add it
# to distutils requiers_dist config
rm -rf {test-,}requirements.txt tools/{pip,test}-requires


%build
PYTHONPATH=. oslo-config-generator --config-dir=etc/oslo-config-generator/
find . \( -name .gitignore -o -name .placeholder \) -delete
find . -name "*.pyc" | xargs rm -f
find . -name "*.pyo" | xargs rm -f

# Build
%{__python2} setup.py build

# Generate i18n files
#%{__python2} setup.py compile_catalog -d build/lib/%{service}/locale

%install
%{__python2} setup.py install -O1 --skip-build --root %{buildroot}

export PYTHONPATH="$( pwd ):$PYTHONPATH"

# Fix hidden-file-or-dir warnings
%if 0%{?with_doc}
rm -fr doc/build/html/.doctrees doc/build/html/.buildinfo
%endif
rm -f %{buildroot}/usr/share/doc/subject/README.rst

# Setup directories
install -d -m 755 %{buildroot}%{_datadir}/subject
install -d -m 755 %{buildroot}%{_sharedstatedir}/subject/subjects
install -d -m 755 %{buildroot}%{_sysconfdir}/subject/metadefs

# Config file
install -p -D -m 640 etc/subject-api.conf %{buildroot}%{_sysconfdir}/subject/subject-api.conf
install -p -D -m 644 %{SOURCE21} %{buildroot}%{_datadir}/subject/subject-api-dist.conf
install -p -D -m 644 etc/subject-api-paste.ini %{buildroot}%{_datadir}/subject/subject-api-dist-paste.ini
##
#install -p -D -m 640 etc/subject-cache.conf %{buildroot}%{_sysconfdir}/subject/subject-cache.conf
#install -p -D -m 644 %{SOURCE22} %{buildroot}%{_datadir}/subject/subject-cache-dist.conf
##
#install -p -D -m 640 etc/subject-glare.conf %{buildroot}%{_sysconfdir}/subject/subject-glare.conf
#install -p -D -m 644 %{SOURCE23} %{buildroot}%{_datadir}/subject/subject-glare-dist.conf
#install -p -D -m 644 etc/subject-glare-paste.ini %{buildroot}%{_datadir}/subject/subject-glare-dist-paste.ini
##
install -p -D -m 640 etc/subject-registry.conf %{buildroot}%{_sysconfdir}/subject/subject-registry.conf
install -p -D -m 644 %{SOURCE24} %{buildroot}%{_datadir}/subject/subject-registry-dist.conf
install -p -D -m 644 etc/subject-registry-paste.ini %{buildroot}%{_datadir}/subject/subject-registry-dist-paste.ini
##
#install -p -D -m 640 etc/subject-scrubber.conf %{buildroot}%{_sysconfdir}/subject/subject-scrubber.conf
#install -p -D -m 644 %{SOURCE25} %{buildroot}%{_datadir}/subject/subject-scrubber-dist.conf

install -p -D -m 640 etc/policy.json %{buildroot}%{_sysconfdir}/subject/policy.json
#install -p -D -m 640 etc/schema-image.json %{buildroot}%{_sysconfdir}/subject/schema-image.json

# Move metadefs
#install -p -D -m  640 etc/metadefs/*.json %{buildroot}%{_sysconfdir}/subject/metadefs/

# systemd services
install -p -D -m 644 %{SOURCE1} %{buildroot}%{_unitdir}/ojj-subject-api.service
#install -p -D -m 644 %{SOURCE2} %{buildroot}%{_unitdir}/ojj-subject-glare.service
install -p -D -m 644 %{SOURCE3} %{buildroot}%{_unitdir}/ojj-subject-registry.service
#install -p -D -m 644 %{SOURCE4} %{buildroot}%{_unitdir}/ojj-subject-scrubber.service

# Logrotate config
install -p -D -m 644 %{SOURCE10} %{buildroot}%{_sysconfdir}/logrotate.d/ojj-subject

# Install pid directory
install -d -m 755 %{buildroot}%{_localstatedir}/run/subject

# Install log directory
install -d -m 755 %{buildroot}%{_localstatedir}/log/subject

# Install i18n .mo files (.po and .pot are not required)
install -d -m 755 %{buildroot}%{_datadir}
rm -f %{buildroot}%{python2_sitelib}/%{service}/locale/*/LC_*/%{service}*po
rm -f %{buildroot}%{python2_sitelib}/%{service}/locale/*pot

# Find language files
#%find_lang %{service} --all-name

# Cleanup
rm -rf %{buildroot}%{_prefix}%{_sysconfdir}

%pre
getent group subject >/dev/null || groupadd -r subject -g 161
getent passwd subject >/dev/null || \
useradd -u 161 -r -g subject -d %{_sharedstatedir}/subject -s /sbin/nologin \
-c "Ojj Subject Daemons" subject
exit 0

%post
# Initial installation
%systemd_post ojj-subject-api.service
#%systemd_post ojj-subject-glare.service
%systemd_post ojj-subject-registry.service
#%systemd_post ojj-subject-scrubber.service


%preun
%systemd_preun ojj-subject-api.service
#%systemd_preun ojj-subject-glare.service
%systemd_preun ojj-subject-registry.service
#%systemd_preun ojj-subject-scrubber.service

%postun
%systemd_postun_with_restart ojj-subject-api.service
#%systemd_postun_with_restart ojj-subject-glare.service
%systemd_postun_with_restart ojj-subject-registry.service
#%systemd_postun_with_restart ojj-subject-scrubber.service

%files
%doc README.rst
%{_bindir}/subject-api
#%{_bindir}/subject-control
#%{_bindir}/subject-glare
%{_bindir}/subject-manage
%{_bindir}/subject-registry
#%{_bindir}/subject-cache-cleaner
#%{_bindir}/subject-cache-manage
#%{_bindir}/subject-cache-prefetcher
#%{_bindir}/subject-cache-pruner
#%{_bindir}/subject-scrubber
#%{_bindir}/subject-replicator

%{_datadir}/subject/subject-api-dist.conf
#%{_datadir}/subject/subject-cache-dist.conf
#%{_datadir}/subject/subject-glare-dist.conf
%{_datadir}/subject/subject-registry-dist.conf
#%{_datadir}/subject/subject-scrubber-dist.conf
%{_datadir}/subject/subject-api-dist-paste.ini
#%{_datadir}/subject/subject-glare-dist-paste.ini
%{_datadir}/subject/subject-registry-dist-paste.ini

%{_unitdir}/ojj-subject-api.service
#%{_unitdir}/ojj-subject-glare.service
%{_unitdir}/ojj-subject-registry.service
#%{_unitdir}/ojj-subject-scrubber.service

#%if 0%{?with_doc}
#%{_mandir}/man1/subject*.1.gz
#%endif
%dir %{_sysconfdir}/subject
%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/subject-api.conf
#%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/subject-glare.conf
#%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/subject-cache.conf
%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/subject-registry.conf
#%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/subject-scrubber.conf
%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/policy.json
#%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/schema-image.json
#%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/subject/metadefs/*.json
%config(noreplace) %attr(-, root, subject) %{_sysconfdir}/logrotate.d/ojj-subject
%dir %attr(0755, subject, nobody) %{_sharedstatedir}/subject
%dir %attr(0750, subject, subject) %{_localstatedir}/log/subject

#%files -n python-subject -f %{service}.lang
%doc README.rst
%{python2_sitelib}/subject
%{python2_sitelib}/subject-*.egg-info
%exclude %{python2_sitelib}/subject/tests

#%files -n python-%{service}-tests
%license LICENSE
%{python2_sitelib}/%{service}/tests

#%if 0%{?with_doc}
#%files doc
#%doc doc/build/html
#%endif

%changelog
* Thu Oct 06 2016 Haikel Guemar <hguemar@fedoraproject.org> 1:13.0.0-1
- Update to 1.0.0

