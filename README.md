Puppet Modules
==============

These are a set of puppet manifests and modules that are currently being
used to manage the OpenSwitch Project infrastructure.

The main entry point is in manifests/site.pp.

In general, most of the modules here are designed to be able to be run
either in agent or apply mode.

These puppet modules require puppet 2.7 or greater. Additionally, the
site.pp manifest assumes the existence of hiera.

See http://ci.openswitch.fnetor more information.

Documentation
==============

The documentation presented at http://ci.openswitch.net comes from
git://git.openswitch.net/infra/system-config repo's docs/source.  To
build the documentation use

 $ tox -evenv python setup.py build_sphinx
