%{!?upstream_version: %global upstream_version %{version}%{?milestone}}
%global upstream_name subject_store

Name:           python-subject-store
Version:        0.1.0
Release:        1%{?dist}
Summary:        Ojj Subject Service Store Library

License:        ASL 2.0
URL:            https://github.com/openstack/%{upstream_name}
Source0:        https://tarballs.openstack.org/%{upstream_name}/%{upstream_name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  python2-devel
BuildRequires:  python-setuptools
BuildRequires:  python-pbr
Requires:       python-debtcollector >= 1.2.0
Requires:       python-eventlet
Requires:       python-cinderclient >= 1.0.6
Requires:       python-keystoneclient >= 2.0.0
Requires:       python-iso8601
Requires:       python-requests
Requires:       python-six >= 1.9.0
Requires:       python-stevedore >= 1.16.0
Requires:       python-oslo-concurrency >= 3.8.0
Requires:       python-oslo-config >= 2:3.14.0
Requires:       python-oslo-i18n >= 2.1.0
Requires:       python-oslo-rootwrap
Requires:       python-oslo-serialization >= 1.10.0
Requires:       python-oslo-utils >= 3.16.0
Requires:       python-enum34
Requires:       python-jsonschema


%description
Ojj subject service store library


%prep
%setup -q -n %{upstream_name}-%{upstream_version}


%build
%{__python2} setup.py build
# Remove bundle egg-info
rm -rf %{upstream_name}.egg-info


%install
%{__python2} setup.py install -O1 --skip-build --root %{buildroot}


%files
%doc AUTHORS ChangeLog
%{!?_licensedir:%global license %%doc}
%license LICENSE
%{_bindir}/subject-rootwrap
%{python2_sitelib}/%{upstream_name}
%{python2_sitelib}/%{upstream_name}-*.egg-info


%changelog
* Wed Sep 14 2016 Haikel Guemar <hguemar@fedoraproject.org> 0.18.0-1
- Update to 0.18.0

