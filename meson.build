project('nixboutique', 'vala', version: '0.1.0', meson_version: '>= 1.2.0')

gtk = dependency('gtk4')
json = dependency('json-glib-1.0')
gee = dependency('gee-0.8')
gnome = import('gnome')

resources = gnome.compile_resources('nixboutique-resources', 'data/com.soltros.Nixboutique.gresource.xml', source_dir: 'data')

executable('nixboutique',
  ['src/main.vala', 'src/catalog.vala', 'src/nixpkger.vala', resources],
  dependencies: [gtk, json, gee],
  install: true,
)

install_data('data/com.soltros.Nixboutique.desktop', install_dir: get_option('datadir') / 'applications')
install_data('data/nixos_packages_summary.json', install_dir: get_option('datadir') / 'nixboutique')
