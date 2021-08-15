project('vunitrunner', 'vala', 'c', version: '0.1', license: 'LGPL')

gnome = import('gnome')

g_deps = [
    dependency('glib-2.0'),
    dependency('gobject-2.0')
]

runner_dependencies = [
    g_deps,
    dependency('gobject-introspection-1.0'),
    dependency('gee-0.8'),
    vunit_dep
]

subdir('src')

sample_deps = [
    g_deps,
    dependency('vunit-0.1')
]
